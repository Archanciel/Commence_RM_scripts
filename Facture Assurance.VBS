$OBJECT=Form

' Commence RM: Facture Assurance Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 31-05-2013

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
	
	If oxAddress.ConnectedItemCount = 0 Then
		'means we ar not editing an existing item, but trully creating a new one !
		oxAddress.SetConnection "Maxi.ch Assurances SA", ""
	End If
End Sub
'******************************************

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
   If FieldName = fMontantAssurance Then
       oMontantAPayer.Value = oMontantAssurance.Value
   End If
End Sub
'******************************************
