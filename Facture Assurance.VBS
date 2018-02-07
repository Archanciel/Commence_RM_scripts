$OBJECT=Form

' Commence RM: Facture Assurance Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 31-05-2013

Option Explicit


Const fName = "Name"
Const fMontantRembours = "Montant remb"
Const fMontantAPayer = "A payer"

Dim oName
Dim oMontantRembours
Dim oMontantAPayer

Set oName = Form.field(fName)
Set oMontantRembours = Form.field(fMontantRembours)
Set oMontantAPayer = Form.field(fMontantAPayer)

'******************************************
Sub Form_OnEnterTab(ByVal TabName)
	Dim oxAddress
	Set oxAddress = Form.Connection("Relates to", "Address")
	
	If oxAddress.ConnectedItemCount = 0 Then
		'means we are not editing an existing item, but truly creating a new one !
		'WARNING: due to the fact that the Address category has phone number as complimentary field,
		'the connection to the Address item will not be set if it has a phone number !!!ü
		oxAddress.SetConnection "Supra", ""
	End If
End Sub
'******************************************

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
   If FieldName = fMontantAPayer And oMontantAPayer.Value <> "" And oMontantRembours.Value = "" Then
	    If InStr(UCase(oName.value), "PHARMACIE") Then
			oMontantRembours.Value = oMontantAPayer.Value * 0.75
	    ElseIf InStr(UCase(oName.value), "CMS") Then
			oMontantRembours.Value = oMontantAPayer.Value * 0.90
		Else
			oMontantRembours.Value = oMontantAPayer.Value
		End If
   End If
End Sub
'******************************************

