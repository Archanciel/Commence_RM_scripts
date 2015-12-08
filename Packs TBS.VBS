$OBJECT=Form

' Commence RM: Software Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 08-12-2015

Option Explicit


Const fDateAchat = "Date achat"
Const fDatePremGain = "Date prem. gain"

Dim oDateAchat
Dim oDatePremGain
Dim dDate

'******************************************
'Sets date premier gain 30 jours après date achat
'******************************************
Sub Form_OnSave()
	Set oDateAchat = Form.field(fDateAchat)
	Set oDatePremGain = Form.field(fDatePremGain)

    If oDateAchat.Value <> "" Then
        dDate = DateAdd("d", 30, oDateAchat.Value)
        oDatePremGain.Value = dDate
	End If
End Sub
'******************************************
