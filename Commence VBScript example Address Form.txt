$OBJECT=Form

' Commence RM -- Address Category / Main Form
' Copyright © 2001 Commence Corporation. All Rights Reserved

Option Explicit


Const fisPrimary = "isPrimary"
Const fAccount = "Account"
Const fStreet = "Street"
Const fState = "stateProvince"
Const fCity = "City"
Const fZip = "postalCode"
Const fCountry = "Country"
Const faddressID = "addressID"
Const fCSZ = "combineCSZ"
Const fBusinessNumber = "businessPhone"
Const fFaxNumber = "businessFax"

Dim oCity
Dim oStreet
Dim oState
Dim oZip
Dim oCountry
Dim oAddressID
Dim sAddressID
Dim oAddressName
Dim sAddressName
Dim oCSZ
Dim oBusPhone
Dim oBusFax
Dim Msg, Input
Dim CommenceDB
Dim cAddress    'Address Cursor
Dim fAddress    'Address Filter
Dim rAddress    'Address Rowset
Dim mAddress    'Address Mod
Dim cmAddress   'Address Commit
Dim i
Dim Conv

Dim sAccount    'Contains connected Account Name
Dim sClarifyField       'Contains connected Account Clarify
Dim oAccount    'Connection Object to Account
Dim oContact
Dim nAccount    'Connected Item Count
Dim oPrimary
Dim sPrimary
Dim nAddress
Dim iPrimary    'Column Index for the field "Primary"

Dim r, xAccount
r = "Relates to"
xAccount = "Account"

Set oAccount = Form.Connection("Relates to", "Account")
Set oContact = Form.Connection("Relates to", "Contact")
Set oPrimary = Form.field(fisPrimary)
Set oAddressID = Form.field(faddressID)
Set oStreet = Form.field(fStreet)
Set oCity = Form.field(fCity)
Set oState = Form.field(fState)
Set oZip = Form.field(fZip)
Set oCountry = Form.field(fCountry)
Set oCSZ = Form.field(fCSZ)
Set oBusPhone = Form.field(fBusinessNumber)
Set oBusFax = Form.field(fFaxNumber)
Set CommenceDB = Application.Database
Set Conv = CommenceDB.GetConversation("Commence", "GetData")

'******************************************
Sub Form_OnLoad()

        'Generate an event that will expose data
        If IsAdd() Then
                Form.MoveToTab ("Initial Tab")
        End If

End Sub
'******************************************

'******************************************
Sub Form_OnSave()

        Dim nContact, sContact, fContact, nCont, i, cContact

        ' ensure this object is valid; will be set to Nothing on Cmc validation
        ' error (missing name field, invalid date string, etc.) -wtp 07/24/2001
        Set CommenceDB = Application.Database

        'Check to see if Contact is connected to more than 1 address

        sAddressName = ItemName()

        'There can only be one address marked as Primary attached to an Account

        ' build the CSZ field
        oCSZ.Value = oCity.Value & ", " & oState.Value & " " & oZip.Value

        'Step 1.....How many connected Accounts are there
                nAccount = oAccount.ConnectedItemCount()

        'Step 2.....Apply Logic based on Count of connected items
                If nAccount < 1 Then
                   If InStr(1, sAddressName, "Do Not Use") > 0 Then
                        'do nothing
                   Else
                        'this address is orphaned
                        Msg = "You have not connected this Address record to "
                        Msg = Msg & vbCrLf & "an Account. Would you like to do so now? "
                        Msg = Msg & vbCrLf & "Answering No will delete the Address."
        
                        Input = MsgBox(Msg, vbYesNo, "Commence")
                        'Yes = 6 No = 7
                        If Input = 6 Then
                                Form.Abort
                                Form.MoveToField ("relates to Account")
                        Elseif Input = 7 Then
                                'If this is Add Item, we can remove by canceling
                                If IsAdd() Then
                                        Form.Cancel
                                Else
                                        'We need to use API to delete
                                        sAddressName = ItemName()
                                        sAddressID = oAddressID.Value
                                        Set cAddress = CommenceDB.GetCursor(0, "Address", 0)
        
                                        'This filter assumes the Address Name wasn't edited in this form session
                                        'The Name field HAS been secured on edit items to prevent problems
                                        fAddress = cAddress.SetFilter("[ViewFilter(1,F,,Name,Equal to,""" + sAddressName + """,)]", 0)
                                        fAddress = cAddress.SetFilter("[ViewFilter(2,F,,addressID,Equal to,""" + sAddressID + """,)]", 0)
        
                                        'Create Rowsetfor deletion
                                        Set rAddress = cAddress.GetDeleteRowSet(1, 0)
        
                                        'Delete record
                                        mAddress = rAddress.DeleteRow(0, 0)
        
                                        'Commit changes to database
                                        cmAddress = rAddress.Commit(0)
                                        Set cAddress = Nothing
                                        Form.Cancel
                                End If
                        End If
                   End If
                ElseIf nAccount > 1 Then
                        'Too many accounts connected
                        Msg = "There are too many Accounts connected to "
                        Msg = Msg & vbCrLf & "record. Only one is allowed. "
                        Msg = Msg & vbCrLf & "Please make sure only one is selected."

                        MsgBox Msg
                        Form.MoveToField ("Relates to Account")
                ElseIf nAccount = 1 Then
                        If oPrimary.Value = "1" Then
                                'This is what we want so let's make sure there is only one address marked as primary
                                RefreshConnection (oAccount) ' added 7/24/01 by MAB
                                sAccount = oAccount.ItemName()
                                sClarifyField = oAccount.ItemClarifyField()
                                ' must have a clarify field.
                                sAddressName = ItemName()
                                sAddressID = oAddressID.Value
                                Dim sAddClar
                                sAddClar = sAddressName & vbTab & sAddressID

                                Set cAddress = CommenceDB.GetCursor(0, "Address", 0)
                                'Create Filter
                                If Not IsAdd() Then
                                        fAddress = cAddress.SetFilter("[ViewFilter(1,CTI,,Relates to,Account,""" + sAccount + """,)]", 0)
                                        fAddress = cAddress.SetFilter("[ViewFilter(2,CTCF,,Relates to,Account,businessNumber,Equal to,""" + sClarifyField + """,)]", 0)
                                        'the last two will exclude the current record
                                        fAddress = cAddress.SetFilter("[ViewFilter(3,F,NOT,addressName,Equal to,""" + sAddressName + """,)]", 0)
                                        fAddress = cAddress.SetFilter("[ViewFilter(4,F,NOT,addressID,Equal to,""" + sAddressID + """,)]", 0)
                                Else
                                        fAddress = cAddress.SetFilter("[ViewFilter(1,CTI,,Relates to,Account,""" + sAccount + """,)]", 0)
                                        fAddress = cAddress.SetFilter("[ViewFilter(2,CTCF,,Relates to,Account,businessNumber,Equal to,""" + sClarifyField + """,)]", 0)
                                End If
                                nAddress = cAddress.RowCount()

                                If nAddress > 0 Then
                                        'Create Rowset
                                        Set rAddress = cAddress.GetEditRowSet(nAddress, 0)
                                        iPrimary = rAddress.GetColumnIndex("isPrimary", 0)
                                        For i = 1 To nAddress
                                                mAddress = rAddress.ModifyRow(i - 1, iPrimary, "False", 0)
                                                cmAddress = rAddress.Commit(0)
                                        Next
                                End If
                                Set cAddress = Nothing
                         UpdateAccountFields()
                        End If
                End If
                UpdateContactFields()
        Set CommenceDB = Nothing

End Sub
'******************************************

'******************************************
Sub Form_OnCancel()
End Sub
'******************************************

'******************************************
Sub Form_OnEnterTab(ByVal TabName)

        sAddressID = oAddressID.Value()
        If Len(sAddressID) < 12 Then
                sAddressID = RandomLetter(4)
                sAddressID = sAddressID & RandomNumber(8)
                oAddressID.Value = sAddressID
        End If
  If IsAdd() Then
        Call Link
  End If
  ' on add/edit - init connection filtering
  RefreshActiveAccount
End Sub
'******************************************
'******************************************
Sub Form_OnEnterField(ByVal FieldName)
        If FieldName = "addressID" Then
                Call SecureField("Street")
        End If

        If Not IsAdd() Then
                If FieldName = "addressName" Then
                        Call SecureField("Relates to Account")
                End If
        End If
End Sub
'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
   If FieldName = (r & " " & xAccount) Then
       ' update with selected account
       RefreshActiveAccount
   End If

'-------Begin Phone Number Formatting------------
Dim lenPhone
Dim pharea
Dim phxchange
Dim phsuf
Dim phonenumber
Dim strPhone
Dim i, a, b, ph
Dim strChar(4)
Dim txtPhone
Dim field
Dim M
Dim Msg

strChar(0) = " "
strChar(1) = ")"
strChar(2) = "("
strChar(3) = "-"
                
        If FieldName = "businessPhone" Or FieldName = "businessFax" Or FieldName = "tollfreePhone" Then
                field = FieldName
                Set txtPhone = Form.field(field)
                strPhone = txtPhone.Value
                lenPhone = Len(strPhone)
                
                For i = 0 To 3
                        Do While InStr(1, strPhone, strChar(i)) <> 0
                                a = InStr(1, strPhone, strChar(i))
                                ph = Mid(strPhone, 1, a - 1) & Mid(strPhone, a + 1)
                                strPhone = ph
                        Loop
                Next
                
                lenPhone = Len(strPhone)
                        If lenPhone = 10 Then
                                pharea = Mid(strPhone, 1, 3)
                                phxchange = Mid(strPhone, 4, 3)
                                phsuf = Mid(strPhone, 7, 4)
                                phonenumber = pharea &"-"&phxchange&"-"&phsuf
                                txtPhone.Value = phonenumber
                        ElseIf lenPhone > 0 And lenPhone < 10 Then
                                Msg = "Please enter a 10 digit phone number!"
                                M = MsgBox(Msg, 48, "Commence")
                                Form.MoveToField (field)
                        End If
        End If
'--------End Phone Number Formatting

End Sub
'******************************************

'******************************************
Sub SecureField(ByVal MoveTo)
        'This sub allows you to secure a field
                Form.MoveToField (MoveTo)
End Sub
'******************************************

'******************************************
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
'*****************************************

'*****************************************
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
'*****************************************


Sub Link()
On Error Resume Next
Dim sView
Dim MyArray
Dim u
'Dim sTicket
Dim CommenceDB
        Set CommenceDB = Application.Database  'CreateObject("Commence.DB")
Dim Conv
        Set Conv = CommenceDB.GetConversation("Commence", "GetData")
Dim s
        s = Conv.request("[ClarifyItemNames(True)]")
Dim oxAccount
        Set oxAccount = Form.Connection("Relates to", "Account")

Dim oxContact
        Set oxContact = Form.Connection("Relates to", "Contact")

'       If TabName = InitialTab Then
                        ' Find out if we're in a subsidiary view via DDE
                        sView = Conv.request("[GetActiveViewInfo(|)]")  ' grabs a bunch of view related information
                        MyArray = Split(sView, "|")             ' sticks view info into an array
                        sView = MyArray(0)                              ' this grabs the view name from the array
                        Select Case sView
                                Case "AccountLinkToAddress"             ' this is a view that we need to autolink
                                        u = CreateLink("All Accounts Review")
                                        oxAccount.SetConnection u(0), u(1)
                                Case "MyAccountLinkToAddress"           ' this is a view that we need to autolink
                                        u = CreateLink("My Accounts Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "SupportAccountLinkToAddress"              ' this is a view that we need to autolink
                                        u = CreateLink("All Support Accounts")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MySupportAccountLinkToAddress"            ' this is a view that we need to autolink
                                        u = CreateLink("My Support Account Review")
                                        oxAccount.SetConnection u(0), u(1)
                        
                                Case "LeadLinkToAddress"                ' this is a view that we need to autolink
                                        u = CreateLink("Leads Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MyLeadLinkToAddress"              ' this is a view that we need to autolink
                                        u = CreateLink("My Leads Review")
                                        oxAccount.SetConnection u(0), u(1)

                                Case "MyContactLinkToAddress"
                                        u = CreateLink("My Contacts Review")
                                        oxContact.SetConnection u(0), u(1)

                                Case "ContactLinkToAddress"
                                        u = CreateLink("All Contacts Review")
                                        oxContact.SetConnection u(0), u(1)
                                
                                Case "MySupportContactLinkToAddress"
                                        u = CreateLink("My Support Contacts")
                                        oxContact.SetConnection u(0), u(1)

                                Case "SupportContactLinkToAddress"
                                        u = CreateLink("Support Contacts Review")
                                        oxContact.SetConnection u(0), u(1)


                        End Select
'       End if
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
                Set CommenceDB = Application.Database
        Dim Conv
                Set Conv = CommenceDB.GetConversation("Commence", "GetData")
        Dim s
                s = Conv.request("[ClarifyItemNames(True)]")

                                ' this will make the header view the active view even though we're referencing the multiview
                                Conv.execute "[ShowView(""" + pMultiViewName + """, 0)]"
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


Sub UpdateAccountFields()
        On Error Resume Next
        Dim vAcc, oxAcct, vClar
        Set oxAcct = Form.Connection("Relates to", "Account")

        RefreshConnection (oxAcct)      'add by MAB 7/23/01
        vAcc = oxAcct.ItemName
        vClar = oxAcct.ItemClarifyField

        Dim cAcc, rAcc, nAcc

        Set cAcc = CommenceDB.GetCursor(0, "Account", 0)

        cAcc.SetFilter "[ViewFilter(1,F,,""accountKey"",Equal To,""" + vAcc + """)]", 0
        cAcc.SetFilter "[ViewFilter(2,F,,""businessNumber"",Equal To,""" + vClar + """)]", 0
        nAcc = cAcc.RowCount()

        If nAcc = 1 Then
                Set rAcc = cAcc.GetEditRowSet(nAcc, 0)
        
                Dim iStreet: iStreet = rAcc.GetColumnIndex("Address", 0)
                Dim iCity: iCity = rAcc.GetColumnIndex("City", 0)
                Dim iState: iState = rAcc.GetColumnIndex("stateProvince", 0)
                Dim iZip: iZip = rAcc.GetColumnIndex("zipPostal", 0)
                Dim iCSZ: iCSZ = rAcc.GetColumnIndex("cityStateZip", 0)
                Dim iCountry: iCountry = rAcc.GetColumnIndex("Country", 0)
                Dim iFax: iFax = rAcc.GetColumnIndex("faxNumber", 0)
                Dim iBus: iBus = rAcc.GetColumnIndex("businessNumber", 0)
        
                For i = 1 To nAcc
                        rAcc.ModifyRow i - 1, iStreet, oStreet.Value, 0
                        rAcc.ModifyRow i - 1, iCity, oCity.Value, 0
                        rAcc.ModifyRow i - 1, iState, oState.Value, 0
                        rAcc.ModifyRow i - 1, iZip, oZip.Value, 0
                        rAcc.ModifyRow i - 1, iCSZ, oCSZ.Value, 0
                        rAcc.ModifyRow i - 1, iCountry, oCountry.Value, 0
                        rAcc.ModifyRow i - 1, iFax, oBusFax.Value, 0
                        rAcc.ModifyRow i - 1, iBus, oBusPhone.Value, 0

                        rAcc.Commit 0
                Next
        Else

        End If

End Sub

Sub UpdateContactFields()
        On Error Resume Next
        Dim vCon, oxCont, vClar
        Dim nCon
        Set oxCont = Form.Connection("Relates to", "Contact")

        RefreshConnection (oxCont)      'add by MAB 7/23/01
        nCon = oxCont.ConnectedItemCount
        If nCon > 0 Then

                Dim cAcc, rAcc, nAcc

                Set cAcc = CommenceDB.GetCursor(0, "Contact", 0)
                cAcc.SetFilter "[ViewFilter(1,CTCF,,Relates to,Address,addressID,Contains," + Trim(oAddressID.Value) + ")]", 0
                nAcc = cAcc.RowCount()
                If nAcc > 0 Then
                        Set rAcc = cAcc.GetEditRowSet(nAcc, 0)
        
                        Dim iStreet: iStreet = rAcc.GetColumnIndex("busStreet", 0)
                        Dim iCity: iCity = rAcc.GetColumnIndex("busCity", 0)
                        Dim iState: iState = rAcc.GetColumnIndex("busState", 0)
                        Dim iZip: iZip = rAcc.GetColumnIndex("busZip", 0)
                        Dim iCountry: iCountry = rAcc.GetColumnIndex("busCountry", 0)
                        Dim iCSZ: iCSZ = rAcc.GetColumnIndex("cityStateZip", 0)
                        Dim iFax: iFax = rAcc.GetColumnIndex("faxNumber", 0)
                        'Dim iBus: iBus = rAcc.GetColumnIndex("businessNumber", 0)
                        Dim iBus: iBus = rAcc.GetColumnIndex("mainTelephone", 0)
        
                        For i = 1 To nAcc
                                rAcc.ModifyRow i - 1, iStreet, oStreet.Value, 0
                                rAcc.ModifyRow i - 1, iCity, oCity.Value, 0
                                rAcc.ModifyRow i - 1, iState, oState.Value, 0
                                rAcc.ModifyRow i - 1, iZip, oZip.Value, 0
                                rAcc.ModifyRow i - 1, iCountry, oCountry.Value, 0
                                rAcc.ModifyRow i - 1, iCSZ, oCSZ.Value, 0
                                rAcc.ModifyRow i - 1, iFax, oBusFax.Value, 0
                                rAcc.ModifyRow i - 1, iBus, oBusPhone.Value, 0
                        Next
                        rAcc.Commit 0
                        rAcc = Nothing
                Else

                End If
                cAcc = Nothing
        End If
End Sub

Sub RefreshConnection(ByVal obj)
'  On Error Resume Next
        If obj.ConnectedItemCount > 0 Then
                obj.CurrentSelection = 1
        Else
                obj.CurrentSelection = 0
        End If
End Sub

' set the active account item for connection filtering
Sub RefreshActiveAccount()
On Error Resume Next

    Dim sKey, sClarify
    RefreshConnection (oAccount)
    'MsgBox "# of related accounts = " & oAccount.ConnectedItemCount
    
    sKey = oAccount.ItemName()
    sClarify = oAccount.ItemClarifyField()

    'MsgBox "key/clarify = " & sKey & "/" & sClarify
    If oAccount.ConnectedItemCount > 0 Then
        ' set the active account item for connection filtering
        Form.Connection(r, "Contact").SetActiveItem xAccount, sKey, sClarify, 0
    End If
End Sub

