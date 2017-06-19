$OBJECT=Form

' Commence RM -- Report Category / Report Form
' Copyright © 2001 Commence Corporation. All Rights Reserved

Option Explicit

Const InitialTab = "Initial Tab"
Const fName = "reportKey"


Dim CommenceDB          ' commence database object
Dim Conv                                ' commence DDE conversation object
Dim sReportName ' report name
Dim Msg, M

Set CommenceDB = Application.Database  'CreateObject("Commence.DB")
Set Conv = CommenceDB.GetConversation("Commence", "GetData")

Sub Form_OnLoad()

        ' We have to generate another event in order to
        ' handle data. This will initiate the OnEnterTab Event.
        Form.MoveToTab (InitialTab)

End Sub

Sub Form_OnSave()
End Sub

Sub Form_OnCancel()
End Sub

Sub Form_OnEnterTab(ByVal TabName)
On Error Resume Next

Dim sView
Dim MyArray
Dim u

        If Not IsAdd() Then

                ' Find out if we're in a subsidiary view via DDE
                sView = Conv.Request("[GetActiveViewInfo(|)]")  ' grabs a bunch of view related information
                MyArray = Split(sView, "|")             ' sticks view info into an array
                sView = MyArray(0)                              ' this grabs the view name from the array

                Select Case sView

                Case "Admin - Reports"
                ' edit the item if using the admin view.
                Case Else
                        ' User opens form. We capture the report name, open it and close this form
                        If TabName = InitialTab Then
                                sReportName = Form.Field(fName).Value
                                Conv.Execute ("[ShowView(""" + sReportName + """, 1)]")
                                If Err.Number < 1 Then
                                        Form.Cancel
                                        ' If we generate an error it's because the report name doesn't exist
                                ElseIf Err.Number > 0 Then
                                        Msg = "This report does not exist. Would you like to fix this?"
                                        M = MsgBox(Msg, vbYesNo, "Commence")
                                        If M = vbNo Then
                                                Form.Cancel
                                        ElseIf M = vbYes Then
                                        End If
                                End If
                        End If
                End Select
        End If

        Call Link
End Sub

Sub Form_OnLeaveTab(ByVal TabName)
End Sub

Sub Form_OnEnterField(ByVal FieldName)
End Sub

Sub Form_OnLeaveField(ByVal FieldName)
End Sub

Sub Link()
On Error Resume Next
Dim sView
Dim MyArray
Dim u
Dim cAccount, nAccount, rAccount, iAccount, iClarify, vAccount, vClarify
Dim CommenceDB
Set CommenceDB = Application.Database 'CreateObject("Commence.DB")
Dim Conv
Set Conv = CommenceDB.GetConversation("Commence", "GetData")
Dim s
s = Conv.Request("[ClarifyItemNames(True)]")

Dim oxType
Set oxType = Form.Connection("Relates to", "reportType")
Set cAccount = CommenceDB.GetCursor(0, "Account", 0)


        If TabName = InitialTab Then
                ' Find out if we're in a subsidiary view via DDE
                sView = Conv.Request("[GetActiveViewInfo(|)]")  ' grabs a bunch of view related information
                MyArray = Split(sView, "|")             ' sticks view info into an array
                sView = MyArray(0)                              ' this grabs the view name from the array

                If IsAdd() Then
                        Select Case sView
                                Case "Report List Rep"
                                        u = CreateLink("Reports (Sales Rep)")
                                        oxType.SetConnection u(0), ""

                                Case "Report List Mgr"
                                        u = CreateLink("Reports (Sales Mgr)")
                                        oxType.SetConnection u(0), ""

                                Case "Report List Supp Mgr"
                                        u = CreateLink("Reports (Support Mgr)")
                                        oxType.SetConnection u(0), ""

                        End Select
                Else

                
                End If
        End If
Set Conv = Nothing
Set CommenceDB = Nothing

End Sub


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
                s = Conv.Request("[ClarifyItemNames(True)]")

                                ' this will make the header view the active view even though we're referencing the multiview
                                Conv.Execute "[ShowView(""" + pMultiViewName + """, 0)]"
                                sView = Conv.Request("[GetActiveViewInfo(""" + sDelim + """)]")
                                MyArray = Split(sView, sDelim)
                                sView = MyArray(3)

                                ' we need to parse out the results
                                ' get the item name first
                                MyArray = Split(sView, cDelim)
                                MyArray(0) = RTrim(MyArray(0))
                                MyArray(1) = RTrim(MyArray(1))
        CreateLink = MyArray
End Function

