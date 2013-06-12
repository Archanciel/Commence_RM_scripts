' Commence RM  -- Activity Category / Appointment Form
' Copyright © 2005 Commence Corporation. All Rights Reserved

Option Explicit

' Field Name Constants
Const fName = "activityKey"
Const fDate = "Date"
Const fAlarm = "Alarm"
Const fStartTime = "startTime"
Const fAlarmTime = "alarmTime"
Const fConfirmation = "Confirmation"
Const fConfirmationType = "confirmationType"
Const fConfirmationDate = "confirmationDate"
Const fConfirmationTime = "confirmationTime"
Const fTravelAlarm = "travelAlarm"
Const fTravelDate = "travelDate"
Const fTravelStart = "travelStart"
Const fTravelEnd = "travelEnd"
Const fType = "Type"
Const fAlarmInterval = "alarmInterval"
Const fAlarmUnits = "alarmUnits"
Const fAlarmDate = "alarmDate"
Const fLeadTime = "leadTime"
Const fComplete = "complete"
Const fCompletedDate = "completedDate"
Const fNotes = "Notes"
Const fSecure = "activityKey"

' Connection Name Constants
Const r = "Relates to"
Const xAccount = "Account"
Const xContact = "Contact"
'Const xTicket = "Ticket"
Const xOpportunity = "Opportunity"
'Const xDW = "dataWarehouse"

Dim oxAccount
Set oxAccount = Form.Connection(r, xAccount)
Dim oxContact
Set oxContact = Form.Connection(r, xContact)
'Dim oxTicket
'Set oxTicket = Form.Connection(r, xTicket)
Dim oxOpportunity
Set oxOpportunity = Form.Connection(r, xOpportunity)
'Dim oxDW
'Set oxDW = Form.Connection(r, xDW)

' Form Object Name Constants
Const InitialTab = "Appointment"

' Field Object Declarations
Dim oDate
Dim oAlarm
Dim oLeadTime
Dim oStartTime
Dim oAlarmTime
Dim oConfirmation
Dim oConfirmationType
Dim oConfirmationDate
Dim oConfirmationTime
Dim oTravelAlarm
Dim oTravelDate
Dim oTravelStartTime
Dim oTravelEndTime
Dim oType
Dim oIsAdd
Dim oAlarmInterval
Dim oAlarmUnits
Dim oAlarmDate
Dim oName

Set oDate = Form.Field(fDate)
Set oAlarm = Form.Field(fAlarm)
Set oStartTime = Form.Field(fStartTime)
Set oAlarmTime = Form.Field(fAlarmTime)
Set oConfirmation = Form.Field(fConfirmation)
Set oConfirmationType = Form.Field(fConfirmationType)
Set oConfirmationDate = Form.Field(fConfirmationDate)
Set oConfirmationTime = Form.Field(fConfirmationTime)
Set oTravelAlarm = Form.Field(fTravelAlarm)
Set oTravelDate = Form.Field(fTravelDate)
Set oTravelStartTime = Form.Field(fTravelStart)
Set oTravelEndTime = Form.Field(fTravelEnd)
Set oType = Form.Field(fType)
Set oAlarmInterval = Form.Field(fAlarmInterval)
Set oAlarmUnits = Form.Field(fAlarmUnits)
Set oAlarm = Form.Field(fAlarm)
Set oAlarmDate = Form.Field(fAlarmDate)
Set oLeadTime = Form.Field(fLeadTime)
Set oName = Form.Field(fName)

Dim CommenceDB
        Set CommenceDB = Application.Database 'CreateObject("Commence.DB")
Dim Conv
        Set Conv = CommenceDB.GetConversation("Commence", "GetData")

' Variables
Dim M
Dim dDate
Dim lAlarm
Dim selLeadTime
Dim tStartTime
Dim tAlarmTime
Dim lConfirmation
Dim selConfirmationType
Dim dConfirmationDate
Dim tConfirmationTime
Dim lTravelAlarm
Dim dTravelDate
Dim tTravelStartTime
Dim tTravelEndTime
Dim selType
Dim sReturn
Dim c
Dim sHour
Dim sMinutes
Dim sAlarmInterval
Dim sStartTime
Dim sEndTime
Dim sAlarmDate
Dim sDiff
Dim sTime
Dim sTime1
Dim sTime3
Dim Msg
Dim sView
Dim MyArray
Dim u, i, xSecure, xLoad, xPrompt
Dim sName, sClarify, sTicket, sTicketClarify, sDue, sEmp, sAccount, sAccountClarify, sContact, sLong, sOpp, sOppClarify, sNotes, sType, sContactClarify
'Dim sName, sClarify, sTicket, sTicketClarify, sDue, sEmp, sAccount, sAccountClarify, sContact, sLong, sOpp, sOppClarify, sNotes, sType, sContactClarify
'Dim sDW, sDWClarify
        
c = 1
sReturn = Chr(13) + Chr(10)

'--------------------------------

Sub Form_OnLoad()
        If IsAdd() Then
                xLoad = Empty
        Else
                xLoad = 1
        End If
        xSecure = Empty
        Form.MoveToTab (InitialTab)
        xPrompt = 1
End Sub


'--------------------------------
Sub Form_OnSave()
On Error Resume Next
        lConfirmation = oConfirmation.Value()
        dConfirmationDate = oConfirmation.Value()
        tConfirmationTime = oConfirmationTime.Value()
        lTravelAlarm = oTravelAlarm.Value()
        lAlarm = oAlarm.Value()
        dTravelDate = oTravelDate.Value()
        tTravelStartTime = oTravelStartTime.Value()
        tTravelEndTime = oTravelEndTime.Value()
        If lConfirmation = "1" Then
                If dConfirmationDate = "" Or tConfirmationTime = "" Then
                        MsgBox "You checked off the confirmation box, but haven't entered a date and/or a time." & _
                        " Please complete the record.", vbOKOnly, "Commence"
                        Form.Abort
                        Form.MoveToTab ("Alarms")
                        Form.MoveToField ("confirmationTime")
                End If

                oConfirmation.Value = 0
                Field("confirmationSet").Value = 1
        End If
        
        If lTravelAlarm = "1" Then
                If dTravelDate = "" Or tTravelStartTime = "" Or tTravelEndTime = "" Then
                        MsgBox "You checked off the Travel Alarm, but haven't entered either a date or times." & _
                        " Please complete the record.", vbOKOnly, "Commence"
                        Form.Abort
                        Form.MoveToTab ("Alarms")
                        Form.MoveToField ("travelDate")
                End If
        End If
        
        If lAlarm = 1 Then

                oLeadTime.Value = oAlarmInterval.Value & " " & oAlarmUnits.Value
                sStartTime = Field(fStartTime).Value

                Select Case (oAlarmUnits.Value)
                        Case "Minutes"
                                If sStartTime <> "" Then
                                        sHour = Hour(TimeValue(oStartTime.Value))       'Capture hour value of Start Time
                                        sMinutes = Minute(TimeValue(oStartTime.Value))  'Capture minute value of Start Time
                                        sAlarmInterval = oAlarmInterval.Value()         'Capture alarm interval value

                                        If sAlarmInterval <> "" Then
        
                                                ' Convert Time to Day/Minutes
                                                sHour = sHour * 60                                                                      'Convert the hour to minutes
                                                sTime1 = sMinutes + sHour                                                       'Add the minutes to the result
        
                                                ' Subtract minute interval from Day/Minutes
                                                sTime1 = sTime1 - sAlarmInterval                                        'Day/Minutes less interval

                                                If sTime1 > -1 Then
                                                        '--Convert back to Time format
                                                        sHour = sTime1 / 60                                                             'Build fractional time value
                                                        sMinutes = (sHour - Int(sHour)) * 60    'Remove hours
                                                        sTime = Int(sHour) & ":" & sMinutes     'Build basic new time
                                                        sTime = TimeValue(sTime)                                                'Convert to proper format
                                                        oAlarmTime.Value = sTime                                                'Post result
                                                        oAlarmDate.Value = oDate.Value
                                
                                                Else
                                                        Msg = "Your interval places the alarm time in a previous day." _
                                                        & " Please use the 'Day' Alarm Unit."
                                                        M = MsgBox(Msg, vbOKOnly, "Commence")
                                                        Form.Abort
                                                        oAlarmTime.Value = ""
                                                End If

                                        Else
                                                Msg = "Please enter a valid alarm interval."
                                                M = MsgBox(Msg, vbOKOnly, "Commence")
                                                Form.Abort
                                                Form.MoveToField (fAlarmInterval)
                                        End If

                                Else

                                        MsgBox "Please provide a Start Time, or uncheck the Alarm box.", vbOKOnly, "Commence"
                                        MoveToTab ("Alarms")
                                        MoveToField ("startTime")
                                        Form.Abort
                                        Exit Sub
                                End If
        
                        Case "Hours"
                                If sStartTime <> "" Then
                                        ' Test that hours won't take us to yesterday
                                        sHour = Hour(TimeValue(oStartTime.Value))       'Capture hour value of Start Time
                                        sMinutes = Minute(TimeValue(oStartTime.Value))  'Capture minute value of Start Time
                                        sAlarmInterval = CInt(oAlarmInterval.Value())   'Capture alarm interval value
        
                                        If sAlarmInterval <> "" Then
                                                If sAlarmInterval < (sHour + 1) Then    ' add one for test because sHour is zero based 0-23
                                                        sHour = sHour - sAlarmInterval
                                                        sTime = sHour & ":" & sMinutes
                                                        sTime = TimeValue(sTime)
                                                        oAlarmTime.Value = sTime
                                                        oAlarmDate.Value = oDate.Value
                                                Else
                                                        Msg = "Your interval places the alarm time in a previous day." _
                                                        & " Please use the 'Day' Alarm Unit."
                                                        M = MsgBox(Msg, vbOKOnly, "Commence")
                                                        Form.Abort
                                                        oAlarmTime.Value = ""
                                                End If
                                        Else
                                                Msg = "Please enter a valid alarm interval."
                                                M = MsgBox(Msg, vbOKOnly, "Commence")
                                                Form.Abort
                                                Form.MoveToField (fAlarmInterval)
                                        End If
                                Else
                                        MsgBox "Please provide a Start Time, or uncheck the Alarm box.", vbOKOnly, "Commence"
                                        MoveToTab ("Alarms")
                                        MoveToField ("startTime")
                                        Form.Abort
                                        Exit Sub
                                End If
                        Case "Days"

                                ' We have to deal with a date field
                                If oAlarmInterval.Value <> "" And oDate.Value <> "" Then
                                        dDate = DateAdd("d", (-1 * oAlarmInterval.Value), oDate.Value)
                                        If Err.Number = 5 Then
                                                MsgBox "The Alarm Interval is too large.", vbCritical, "Commence"
                                                Form.Abort
                                                MoveToTab ("Alarms")
                                                MoveToField ("alarmInterval")
                                        Else
                                                oAlarmDate.Value = dDate
                                                oAlarmTime.Value = oStartTime.Value
                                        End If
                                ElseIf oAlarmInterval.Value = "" Then
                                        Msg = "Please enter a valid alarm interval."
                                        M = MsgBox(Msg, vbOKOnly, "Commence")
                                        Form.Abort
                                        Form.MoveToField (fAlarmInterval)
                                ElseIf oDate.Value = "" Then
                                        Msg = "Please enter a value in the Date field."
                                        MsgBox Msg, vbOKOnly, "Commence"
                                        Form.Abort
                                        Form.MoveToField (fDate)
                                End If
                End Select
        End If
        ' complete Appt and add History completed on form
        If Field(fComplete).Value = 1 And xSecure <> 1 Then
                ' complete the to do and add history
                ' pickup values to add history
                Field(fCompletedDate).Value = "Today"
                'Call AddHistory
                Call AddHistoryRecord(True, 0)
                Form.Save
        'Else
                'Dim sTicket, sTicketClarify
                'RefreshConnection (oxTicket)
                'sTicket = oxTicket.ItemName()
                'sTicketClarify = oxTicket.ItemClarifyField()
                'If oxTicket.ConnectedItemCount > 0 Then
                 '       Conv.Execute ("[AssignConnection(""History"", """ + sLong + """, ""Relates to"", ""Ticket"", """ + sTicket + vbTab + sTicketClarify + """)]")
                'End If


        End If


End Sub
'--------------------------------

'--------------------------------

Sub Form_OnCancel()
        On Error Resume Next

End Sub

'--------------------------------

'--------------------------------

Sub Form_OnEnterTab(ByVal TabName)
        On Error Resume Next

        Set oType = Form.Field("TYPE")
        selType = oType.Value()

                        ' if completed, edit todo and lock all fields
                        If xSecure = Empty Then
                                If Field(fComplete).Value = 1 Then
                                        xSecure = 1     ' we check for this on enter field to see if we should lock fields
                                End If
                        End If


        If IsAdd() Then
                Call Link
                Field(factivityType).Value = "Appointment"
        
                If (TabName = "Internal Meeting") Then
                        oType.Value = "Internal Meeting"
                End If
                If (TabName = "Travel Planner") Then
                        oType.Value = "Travel"
                End If
        End If

        ' on add/edit - init connection filtering
        RefreshActiveAccount
        
        'If (IsAdd = "False") Then
                'If (TabName = "Appointment") Then
                        'If (c < 2) Then
                                'Select Case (selType)
                                        'Case "Internal Meeting" : Form.MoveToTab("Internal Meeting")
                                        'Case "Meeting" : Form.MoveToTab(InitialTab)
                                        'Case "Travel" : Form.MoveToTab("Travel Planner")
                                        'Case "Phone Call" : Form.MoveToTab(InitialTab)
                                        'Case "Work on Task" : Form.MoveToTab(InitialTab)
                                        'Case "To-Do" : Form.MoveToTab(InitialTab)
                                        'Case "Vacation" : Form.MoveToTab(InitialTab)
                                        'Case "Holiday" : Form.MoveToTab(InitialTab)
                                        'Case "Other" : Form.MoveToTab(InitialTab)
                                        'Case "Confirmation" : Form.MoveToTab(InitialTab)
                                'End Select
                                'c = c + 1
                                'Exit sub
                        'End if
                'End if
        'End if

        If xPrompt = 1 Then
                        ' if not completed, prompt to edit or complete
                        If Field(fComplete).Value <> 1 And xLoad = 1 Then
                                If MsgBox("Would you like to complete this Appointment?", vbYesNo, "Commence") = vbNo Then
                                        xPrompt = 0
                                        Select Case (selType)
                                                Case "Internal Meeting": Form.MoveToTab ("Internal Meeting")
                                                'Case "Meeting": Form.MoveToTab (InitialTab)
                                                Case "Travel": Form.MoveToTab ("Travel Planner")
                                                Case "Phone Call": Form.MoveToTab (InitialTab)
                                                Case "Work on Task": Form.MoveToTab (InitialTab)
                                                Case "To-Do": Form.MoveToTab (InitialTab)
                                                Case "Vacation": Form.MoveToTab (InitialTab)
                                                Case "Holiday": Form.MoveToTab (InitialTab)
                                                Case "Other": Form.MoveToTab (InitialTab)
                                                Case "Confirmation": Form.MoveToTab (InitialTab)
                                        End Select
                                        c = c + 1
                                        Exit Sub
                                Else
                                        Field(fComplete).Value = "True"
                                        Field(fCompletedDate).Value = "Today"

                                        'Call AddHistory
                                        Call AddHistoryRecord(True, 0)
                                        Save
                                End If
                        End If
        End If
End Sub

'--------------------------------

'--------------------------------

Sub Form_OnLeaveTab(ByVal TabName)
On Error Resume Next

End Sub

'--------------------------------

'--------------------------------

Sub Form_OnEnterField(ByVal FieldName)
On Error Resume Next

        Select Case FieldName
                Case fAlarmTime, fAlarmDate
                        SecureField (fSecure)
        End Select

        'If xSecure = 1 Then
                ' if we allow user to uncomplete a todo, then we need to deal with any associated history that
                ' was created.

                ' msgbox for prompt for reopening the todo and right an audit to history
                'If FieldName = (fComplete) Then
                '       Call ReOpen()
                'End if

        'End if

End Sub

'--------------------------------

'--------------------------------

Sub Form_OnLeaveField(ByVal FieldName)
On Error Resume Next
      If FieldName = (r & " " & xAccount) Then
         ' update with selected account
         RefreshActiveAccount
      End If
End Sub

'--------------------------------

'--------------------------------

Sub ReOpen()
On Error Resume Next

'Dim MyArray, sTicket, sTicketClarify, sAccount, sAccountClarify, s2Name, sLong, sName, sDue, sEmp, sNotes
Dim MyArray, sAccount, sAccountClarify, s2Name, sLong, sName, sDue, sEmp, sNotes
Dim sContact, sContactClarify

        Msg = "Are you sure you'd like to re-open this Appointment?"
        If MsgBox(Msg, vbYesNo, "Commence") = vbYes Then
                MyArray = Conv.request("[GetPreference(Me,¦)]")
                MyArray = Split(MyArray, "¦")

                Field(fComplete).Value = "False"

                'RefreshConnection (oxTicket)
                RefreshConnection (oxAccount)
                RefreshConnection (oxContact)

                'sTicket = oxTicket.ItemName()
                'sTicketClarify = oxTicket.ItemClarifyField()
                sAccount = oxAccount.ItemName()
                sAccountClarify = oxAccount.ItemClarifyField()

                sName = Field(fName).Value
                If Len(sName) > 40 Then
                        s2Name = Left(sName, 40)
                        sLong = s2Name & "-" & "Completed"
                Else
                        sLong = sName & "-" & "Completed"
                End If

                sName = Field(fName).Value
                sDue = Field("Date").Value              'todo clarify

                sEmp = MyArray(1)

                sNotes = "Appointment " + Field(fName).Value + " was reopened by " + MyArray(1)

                Dim vNumber
                vNumber = RandomNumber(2) & RandomLetter(2)
                If Len(Month(Date)) < 2 Then
                        ' Add zero in front of month
                        vNumber = "0" & Month(Date) & Right(Year(Date), 2) & "-" & vNumber
                Else
                        ' Don't add zero in front of month
                        vNumber = Month(Date) & Right(Year(Date), 2) & "-" & vNumber
                End If

                Conv.Execute ("[AddItem(""History"", " + sLong + "," + vNumber + ")]")
                ' ("[EditItem(,, ""Billable"", ""True"")]")
                'Conv.Execute ("[EditItem(,, ""techSupport"", ""True"")]")
                Conv.Execute ("[EditItem(, , ""Notes"", """ + sNotes + """)]")
                sNotes = ""
                'If oxTicket.ConnectedItemCount > 0 Then
                '        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Ticket"", """ + sTicket + vbTab + sTicketClarify + """)]")
                'End If

                Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Employee"", """ + sEmp + """)]")
                'sName = sName & vbTab & sClarify
                Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Activity"", " + sName + ",)]")
                sName = ItemName()

                If oxAccount.ConnectedItemCount > 0 Then
                        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Account"", """ + sAccount + vbTab + sAccountClarify + """)]")
                End If
                
                For i = 1 To oxContact.ConnectedItemCount()
                        oxContact.CurrentSelection = i
                        sContact = oxContact.ItemName()
                        sContactClarify = oxContact.ItemClarifyField()

                        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Contact"", """ + sContact + vbTab + sContactClarify + """)]")
                Next
                
                Conv.Execute ("[PromoteItemToShared(,)]")
                Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""History"")]")
                Save
        Else
                Field(fComplete).Value = "True"
                Call SecureField(fSecure)
        End If
End Sub

'--------------------
Sub AddHistory()

On Error Resume Next

'Dim MyArray, sTicket, sTicketClarify, sAccount, sAccountClarify, sOpp, sOppClarify
Dim MyArray, sAccount, sAccountClarify, sOpp, sOppClarify
Dim s2Name, sLong, sDue, sNotes, sEmp, sName, sContact, sType, u, sContactClarify

                Field(fName).Value = DelimFix(Field(fName).Value)

                MyArray = Conv.request("[GetPreference(Me,¦)]")
                MyArray = Split(MyArray, "¦")
                ' MyArray(1) = the (-Me-) item
                
                'RefreshConnection (oxTicket)
                RefreshConnection (oxAccount)
                RefreshConnection (oxContact)
                RefreshConnection (oxOpportunity)
                'RefreshConnection (oxDW)
                
                'sTicket = oxTicket.ItemName()
                'sTicketClarify = oxTicket.ItemClarifyField()

                sAccount = oxAccount.ItemName()
                sAccountClarify = oxAccount.ItemClarifyField()
                sOpp = oxOpportunity.ItemName()
                sOppClarify = oxOpportunity.ItemClarifyField()

                sName = Field(fName).Value

                If Len(sName) > 40 Then
                        s2Name = Left(sName, 40)
                        sLong = s2Name & "-" & "Completed"
                Else
                        sLong = sName & "-" & "Completed"
                End If

                sDue = Field("Date").Value              'Appt clarify
                sNotes = Field(fNotes).Value
                'sEmp = oxEmployee.ItemName()
                sEmp = MyArray(1)
                sNotes = "Appointment " & Field(fName).Value & " completed by " & MyArray(1) & vbCrLf & sNotes
                sType = oType.Value

                If Len(sNotes) > 255 Then
                        sNotes = Left(sNotes, 255)
                End If

                Dim vNumber
                vNumber = RandomNumber(2) & RandomLetter(2)
                If Len(Month(Date)) < 2 Then
                        ' Add zero in front of month
                        vNumber = "0" & Month(Date) & Right(Year(Date), 2) & "-" & vNumber
                Else
                        ' Don't add zero in front of month
                        vNumber = Month(Date) & Right(Year(Date), 2) & "-" & vNumber
                End If

                Conv.Execute ("[AddItem(""History"", " + sLong + "," + vNumber + ")]")
                'Conv.Execute ("[EditItem(,, ""Billable"", ""True"")]")
                Conv.Execute ("[EditItem(,, ""Notes"", """ + sNotes + """)]")
                Conv.Execute ("[EditItem(,, ""Session"", ""True"")]")
                
                'Set the type of the History based upon the Appointment type
                Select Case sType
                        Case "Meeting": u = "Meeting"
                        Case "Travel": u = "Other"
                        Case "Phone Call": u = "Phone Log"
                        Case "Work on Task": u = "Task"
                        Case "To-Do": u = "Task"
                        Case "Vacation": u = "None"
                        Case "Holiday": u = "None"
                        Case "Other": u = "Other"
                        Case Else: u = "Meeting"
                End Select
                Conv.Execute ("[EditItem(,, ""Type"", """ + u + """)]")

                'If oxTicket.ConnectedItemCount > 0 Then
                '        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Ticket"", """ + sTicket + vbTab + sTicketClarify + """)]")
                '        Conv.Execute ("[EditItem(,, ""techSupport"", ""True"")]")
                'End If

                If oxOpportunity.ConnectedItemCount > 0 Then
                        sOpp = sOpp & vbTab & sOppClarify
                        Conv.Execute ("[AssignConnection(,,""Relates to"", ""Opportunity"",""" + sOpp + """)]")
                End If

                'If oxDW.ConnectedItemCount > 0 Then
                '        sOpp = oxDW.ItemName() & vbTab & oxDW.ItemClarifyField()
                '        Conv.Execute ("[AssignConnection(,,""Relates to"", ""dataWarehouse"",""" + sOpp + """)]")
                'End If

                Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Employee"", """ + sEmp + """)]")

                oxHistory.SetConnection sLong, Date

                If oxAccount.ConnectedItemCount > 0 Then
                        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Account"", """ + sAccount + vbTab + sAccountClarify + """)]")
                End If
                
                For i = 1 To oxContact.ConnectedItemCount()
                        oxContact.CurrentSelection = i
                        sContact = oxContact.ItemName()
                        sContactClarify = oxContact.ItemClarifyField()

                        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Contact"", """ + sContact + vbTab + sContactClarify + """)]")
                Next
                
                Conv.Execute ("[PromoteItemToShared(,)]")
		Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""History"")]")

                'If oxTicket.ConnectedItemCount > 0 Then
                '        Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""Support"")]")
                'Else
                '        Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""History"")]")
                'End If


End Sub

'------------------------------
Sub Link()

On Error Resume Next
Dim sView
Dim MyArray
Dim u
Dim CommenceDB
Set CommenceDB = Application.Database 'CreateObject("Commence.DB")
Dim Conv
Set Conv = CommenceDB.GetConversation("Commence", "GetData")
Dim s
Dim vAccount, vClarify, cAccount, nAccount, rAccount, iAccount, iClarify
Dim vContact, cContact, nContact, rContact, iContact
s = Conv.request("[ClarifyItemNames(True)]")
Dim oxOpportunity
Set oxOpportunity = Form.Connection("Relates to", "Opportunity")
'Dim oxTicket
'Set oxTicket = Form.Connection("Relates to", "Ticket")
'Dim oxTicket
'Set oxTicket = Form.Connection(r, xTicket)
Dim keyClarify


        If TabName = InitialTab Then
                If IsAdd() Then

                        ' Find out if we're in a subsidiary view via DDE
                        sView = Conv.request("[GetActiveViewInfo(|)]")  ' grabs a bunch of view related information
                        MyArray = Split(sView, "|")             ' sticks view info into an array
                        sView = MyArray(0)                      ' this grabs the view name from the array
                        Select Case sView

                                Case "DWLinkToActivity"         ' this is a view that we need to autolink
                                        u = CreateLink("Data Warehouse")
                                        oxDW.SetConnection u(0), u(1)

                                Case "MktgDWLinkToActivity"
                                        u = CreateLink("Marketing Datawarehouse")
                                        oxDW.SetConnection u(0), u(1)

                                Case "MyAccountLinkToActivity"          ' this is a view that we need to autolink
                                        u = CreateLink("My Accounts Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "AccountLinkToActivity"
                                        u = CreateLink("All Accounts Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MyLeadLinkToActivity"             ' this is a view that we need to autolink
                                        u = CreateLink("My Leads Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "LeadLinkToActivity"
                                        u = CreateLink("Leads Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MyContactLinkToActivity"
                                        u = CreateLink("My Contacts Review")
                                        oxContact.SetConnection u(0), u(1)
                                        
                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Contact"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next
                                        oxAccount.SetConnection vAccount, vClarify
                                        
                                        

                                Case "ContactLinkToActivity"
                                        u = CreateLink("All Contacts Review")
                                        oxContact.SetConnection u(0), u(1)
                                        
                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Contact"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next
                                        oxAccount.SetConnection vAccount, vClarify
                                        

                                Case "MyOppLinkToActivity"
                                        u = CreateLink("My Opportunities Review")
                                        oxOpportunity.SetConnection u(0), u(1)

                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Opportunity"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next
                                        oxAccount.SetConnection vAccount, vClarify

                                Case "OppLinkToActivity"
                                        u = CreateLink("All Opportunities Review")
                                        oxOpportunity.SetConnection u(0), u(1)

                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Opportunity"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next

                                        oxAccount.SetConnection vAccount, vClarify

                                Case "VendorLinkToActivity"
                                        u = CreateLink("All Vendors")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "SupportAccountLinkToActivity"
                                        u = CreateLink("All Support Accounts")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "SupportContactLinkToActivity"
                                        u = CreateLink("Support Contacts Review")
                                        oxContact.SetConnection u(0), u(1)
                                        
                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Contact"",""" + keyClarify + """,)]", 0
                                        'cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Contact"",""" + Trim(u(0)) + vbTab + Trim(u(1)) + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next
                                        oxAccount.SetConnection vAccount, vClarify
                                        
                                        

                                Case "MySupportAccountLinkToActivity"
                                        u = CreateLink("My Support Account Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MySupportContactLinkToActivity"
                                        u = CreateLink("My Support Contacts")
                                        oxContact.SetConnection u(0), u(1)
                                        
                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Contact"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next
                                        oxAccount.SetConnection vAccount, vClarify
                                        
                                        

                                Case "MyVendorLinkToActivity"
                                        u = CreateLink("My Vendors")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MyTicketLinkToActivity"
                                        u = CreateLink("My Tickets")
                                        oxTicket.SetConnection u(0), u(1)

                                        ' need to pick up Contact and Account
                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Ticket"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next

                                        oxAccount.SetConnection vAccount, vClarify

                                        ' connect Contact
                                        Set cContact = CommenceDB.GetCursor(0, "Contact", 0)
                                        cContact.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Ticket"",""" + keyClarify + """,)]", 0
                                        nContact = cContact.rowCount()

                                        Set rContact = cContact.GetQueryRowSet(nContact, 0)
                                        iContact = rContact.GetColumnIndex("contactKey", 0)
                                        iClarify = rContact.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nContact
                                                vContact = rContact.GetRowValue(i - 1, iContact, 0)
                                                vClarify = rContact.GetRowValue(i - 1, iClarify, 0)
                                        Next

                                        oxContact.SetConnection vContact, vClarify

                                Case "TicketLinkToActivity"
                                        u = CreateLink("All Tickets Review")
                                        oxTicket.SetConnection u(0), u(1)

                                        ' connect account
                                        keyClarify = u(0) + vbTab + u(1)
                                        Set cAccount = CommenceDB.GetCursor(0, "Account", 0)
                                        cAccount.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Ticket"",""" + keyClarify + """,)]", 0
                                        nAccount = cAccount.rowCount()

                                        Set rAccount = cAccount.GetQueryRowSet(nAccount, 0)
                                        iAccount = rAccount.GetColumnIndex("accountKey", 0)
                                        iClarify = rAccount.GetColumnIndex("businessNumber", 0)


                                        For i = 1 To nAccount
                                                vAccount = rAccount.GetRowValue(i - 1, iAccount, 0)
                                                vClarify = rAccount.GetRowValue(i - 1, iClarify, 0)
                                        Next

                                        oxAccount.SetConnection vAccount, vClarify

                                        ' connect Contact
                                        Set cContact = CommenceDB.GetCursor(0, "Contact", 0)
                                        cContact.SetFilter "[ViewFilter(1,CTI,,""Relates to"",""Ticket"",""" + keyClarify + """,)]", 0
                                        nContact = cContact.rowCount()

                                        Set rContact = cContact.GetQueryRowSet(nContact, 0)
                                        iContact = rContact.GetColumnIndex("contactKey", 0)
                                        'Contact Clarify field changes from businessNumber to ID
                                        'iClarify = rContact.GetColumnIndex("businessNumber", 0)
                                        iClarify = rContact.GetColumnIndex("ID", 0)


                                        For i = 1 To nContact
                                                vContact = rContact.GetRowValue(i - 1, iContact, 0)
                                                vClarify = rContact.GetRowValue(i - 1, iClarify, 0)
                                        Next

                                        oxContact.SetConnection vContact, vClarify

                        End Select
                        Else
                End If
        End If
End Sub

'----------------------

Function CreateLink(pMultiViewName)
' this function will build help build a link to the parent record of a multiview
' when the user uses the add item click menu

        Const sDelim = "!"              ' GetActiveView Delimiter
        Const cDelim = " | "              ' Clarify Delimiter - this can change for each category
        Dim sView
        Dim MyArray
        Dim sItem
        Dim sClarify
        Dim CommenceDB
                Set CommenceDB = Application.Database 'CreateObject("Commence.DB")
        Dim Conv
                Set Conv = CommenceDB.GetConversation("Commence", "GetData")
        Dim s
                s = Conv.request("[ClarifyItemNames(True)]")

                                ' this will make the header view the active view even though we're referencing the multiview
                                Conv.Execute "[ShowView(""" + pMultiViewName + """, 0)]"
                                sView = Conv.request("[GetActiveViewInfo(""" + sDelim + """)]")
                                MyArray = Split(sView, sDelim)
                                sView = MyArray(3)

                                ' we need to parse out the results
                                ' get the item name first
                                MyArray = Split(sView, cDelim)
                                MyArray(0) = RTrim(MyArray(0))
                                MyArray(1) = RTrim(MyArray(1))
        CreateLink = MyArray
End Function

'--------------------------

Sub SecureField(ByVal MoveTo)
                Form.MoveToField (MoveTo)
End Sub

'------------------

Function DelimFix(ByVal Var)
        ' This function will find double quotes and replace them with single quotes
        ' to allow proper filtering using Commence API filters
        DelimFix = Replace(Var, Chr(34), "")
End Function

'------------------

Sub RefreshConnection(ByVal obj)
On Error Resume Next
   If obj.ConnectedItemCount > 0 Then
      obj.CurrentSelection = 1
   Else
      obj.CurrentSelection = 0
   End If
End Sub

'--------------------

Function RandomLetter(ByVal Digits)
        Randomize Timer
        Dim Rand, i, x, Rand2, y
        Dim Index(26)
                Index(0) = "A"
                Index(1) = "B"
                Index(2) = "C"
                Index(3) = "D"
                Index(4) = "E"
                Index(5) = "F"
                Index(6) = "G"
                Index(7) = "H"
                Index(8) = "I"
                Index(9) = "J"
                Index(10) = "K"
                Index(11) = "L"
                Index(12) = "M"
                Index(13) = "N"
                Index(14) = "O"
                Index(15) = "P"
                Index(16) = "Q"
                Index(17) = "R"
                Index(18) = "S"
                Index(19) = "T"
                Index(20) = "U"
                Index(21) = "V"
                Index(22) = "W"
                Index(23) = "X"
                Index(24) = "Y"
                Index(25) = "Z"

        For i = 1 To Digits
                Rand2 = Int((25 - 1 + 1) * Rnd + 1)
                RandomLetter = RandomLetter & Index(Rand2)
        Next

End Function

' -----------------------------------------------------------------------------

Function RandomNumber(ByVal Digits)
RandomNumber = ""
Randomize Timer
Dim Rand
Dim i
        For i = 1 To Digits
                Rand = Rand & Int(Rnd * 9)
        Next
        RandomNumber = Rand
End Function


' set the active account item for connection filtering
Sub RefreshActiveAccount()
On Error Resume Next

    Dim sKey, sClarify
    RefreshConnection (oxAccount)
    
    sKey = oxAccount.ItemName()
    sClarify = oxAccount.ItemClarifyField()

    If oxAccount.ConnectedItemCount > 0 Then
        ' set the active account item for connection filtering
        Form.Connection(r, "Contact").SetActiveItem xAccount, sKey, sClarify, 0
        Form.Connection(r, "Opportunity").SetActiveItem xAccount, sKey, sClarify, 0
        'Form.Connection(r, "Ticket").SetActiveItem xAccount, sKey, sClarify, 0
    End If
End Sub

Sub AddHistoryRecord(flag, Msg)
    ' Use the values the user entered as the History record.
    ' Must run when item is marked completed
    
    On Error Resume Next
    
  Dim iHistoryKey ' History Record index
  Dim iHistoryID ' History Record index
  Dim iBillable
  Dim iNotes
  Dim iSession
  Dim iType
  
  Dim cHistory
  Dim rHistory
  Dim result

' prepare some data from the Appointment item
    Field(fName).Value = DelimFix(Field(fName).Value)

    MyArray = Conv.request("[GetPreference(Me,¦)]")
    MyArray = Split(MyArray, "¦")
    
    'RefreshConnection (oxTicket)
    RefreshConnection (oxAccount)
    RefreshConnection (oxContact)
    RefreshConnection (oxOpportunity)
    'RefreshConnection (oxDW)

    'sTicket = oxTicket.ItemName()
    'sTicketClarify = oxTicket.ItemClarifyField()
    sAccount = oxAccount.ItemName()
    sAccountClarify = oxAccount.ItemClarifyField()
    sOpp = oxOpportunity.ItemName
    sOppClarify = oxOpportunity.ItemClarifyField()
    'sDW = oxDW.ItemName
    'sDWClarify = oxDW.ItemClarifyField()

    Dim s2Name
    sName = Field(fName).Value
    If Len(sName) > 40 Then
            s2Name = Left(sName, 40)
            sLong = s2Name & "-" & "Completed"
    Else
            sLong = sName & "-" & "Completed"
    End If
    
    sDue = Field("Date").Value              'Appt clarify
    sNotes = Field(fNotes).Value
    sEmp = MyArray(1)
    
    If flag = True Then
        sNotes = "Appointment " & Field(fName).Value & " completed by " & MyArray(1) & vbCrLf & sNotes
    Else
        sNotes = Msg
    End If
    
    sType = oType.Value
    'Set the type of the History based upon the Appointment type
    Select Case sType
            Case "Meeting": sType = "Meeting"
            Case "Travel": sType = "Other"
            Case "Phone Call": sType = "Phone Log"
            Case "Work on Task": sType = "Task"
            Case "To-Do": sType = "Task"
            Case "Vacation": sType = "None"
            Case "Holiday": sType = "None"
            Case "Other": sType = "Other"
            Case Else: sType = "Meeting"
    End Select
    
    Dim vNumber
    vNumber = RandomNumber(2) & RandomLetter(2)
    If Len(Month(Date)) < 2 Then
            ' Add zero in front of month
            vNumber = "0" & Month(Date) & Right(Year(Date), 2) & "-" & vNumber
    Else
            ' Don't add zero in front of month
            vNumber = Month(Date) & Right(Year(Date), 2) & "-" & vNumber
    End If
    

    ' prepare db and row, set row shared
    Set cHistory = CommenceDB.GetCursor(0, "History", 0)
    Set rHistory = cHistory.GetAddRowSet(1, 0)

    ' get column indexes
    iHistoryKey = rHistory.GetColumnIndex("historyKey", 0)
    iHistoryID = rHistory.GetColumnIndex("historyID", 0)
    'iBillable = rHistory.GetColumnIndex("Billable", 0)
    iNotes = rHistory.GetColumnIndex("Notes", 0)
    iSession = rHistory.GetColumnIndex("Session", 0)
    iType = rHistory.GetColumnIndex("Type", 0)
    
  
   ' set row values
    result = rHistory.ModifyRow(0, iHistoryKey, sLong, 0)
    result = rHistory.ModifyRow(0, iHistoryID, vNumber, 0)

    'result = rHistory.ModifyRow(0, iBillable, "True", 0)
    '    If result < 0 Then MsgBox "error on billable"

    result = rHistory.ModifyRow(0, iNotes, sNotes, 0)
        If result < 0 Then MsgBox "error  on inotes"
    sNotes = rHistory.GetRowValue(0, iNotes, 0) ' WTP

    rHistory.ModifyRow 0, iSession, "True", 0
    rHistory.ModifyRow 0, iType, sType, 0
    
    rHistory.Commit 0
    
    Conv.request ("[GetMarkItem(""History"", """ + sLong + """ , """ + vNumber + """)]")
    Conv.request ("[ClarifyItemNames(True)]")
    
    'If oxTicket.ConnectedItemCount > 0 Then
    '    Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Ticket"", """ + sTicket + vbTab + sTicketClarify + """)]")
    '    Conv.Execute ("[EditItem(,, ""techSupport"", ""True"")]")
    'End If

   
    If oxOpportunity.ConnectedItemCount > 0 Then
        sOpp = sOpp & vbTab & sOppClarify
        Conv.Execute ("[AssignConnection(,,""Relates to"", ""Opportunity"",""" + sOpp + """)]")
    End If

    'If oxDW.ConnectedItemCount > 0 Then
    '    Conv.Execute ("[AssignConnection(,,""Relates to"", ""dataWarehouse"",""" + sDW + vbTab + sDWClarify + """)]")
    'End If
    
    Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Employee"", """ + sEmp + """)]")
    
    'set history connection from activity to new history
    oxHistory.SetConnection sLong, vNumber

    If oxAccount.ConnectedItemCount > 0 Then
        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Account"", """ + sAccount + vbTab + sAccountClarify + """)]")
    End If


    For i = 1 To oxContact.ConnectedItemCount()
        oxContact.CurrentSelection = i
        sContact = oxContact.ItemName()
        sContactClarify = oxContact.ItemClarifyField()

        Conv.Execute ("[AssignConnection(,, ""Relates to"", ""Contact"", """ + sContact + vbTab + sContactClarify + """)]")
    Next

    Conv.Execute ("[PromoteItemToShared(,)]")
    Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""History"")]")

    'If oxTicket.ConnectedItemCount > 0 Then
    '        Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""Support"")]")
    'Else
    '        Conv.Execute ("[ShowItem(""History"", """ + sLong + """,""History"")]")
    'End If
    
    Set rHistory = Nothing
    Set cHistory = Nothing
End Sub

