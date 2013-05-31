$OBJECT=Form

' Commence RM -- Factur Assurance Category / Main Form
' Copyright © 2001 Commence Corporation. All Rights Reserved

Option Explicit


Const fMontantAssurance = "Montant ass"
Const fMontantAPayer = "A payer"

Dim oMontantAssurance
Dim oMontantAPayer

Set oMontantAssurance = Form.field(fMontantAssurance)
Set oMontantAPayer = Form.field(fMontantAPayer)

'******************************************
Sub Form_OnEnterTab(ByVal TabName)
	Dim oxAddress
	Set oxAddress = Form.Connection("Relates to", "Address")
	oxAddress.SetConnection "Maxi.ch Assurances SA", ""
End Sub
'******************************************

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
   If FieldName = fMontantAssurance Then
       oMontantAPayer.Value = oMontantAssurance.Value
   End If
End Sub
'******************************************
