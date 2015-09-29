$OBJECT=Form

Option Explicit

' Modèle de base VBScript pour masques COMMENCE
' Reportez-vous à votre documentation COMMENCE pour en savoir plus sur la mise en place de scripts.
Const fMontantUSD = "Montant USD"
Const fMontantCHF = "Montant CHF"
Const fType = "Type"

Dim oMontantUSD
Dim oMontantCHF
Dim oType

Set oMontantUSD = Form.field(fMontantUSD)
Set oMontantCHF = Form.field(fMontantCHF)
Set oType = Form.field(fType)

'******************************************
Sub Form_OnSave()
	If oType.Value = "Apport" Or oType.Value = "Transfert de" Then
		If oMontantUSD.Value >= 0 Then
			MsgBox "Le champs 'Montant USD' doit être négatif si le type est 'Apport' ou 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantUSD)
		ElseIf oMontantCHF.Value >= 0 Then
			MsgBox "Le champ 'Montant CHF' doit être négatif  si le type est 'Apport' ou 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantCHF)
		End If
	Else
		If oMontantUSD.Value <= 0 Then
			MsgBox "Le champs 'Montant USD' doit être positif si le type est différent de 'Apport' ou de 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantUSD)
		ElseIf oMontantCHF.Value <= 0 Then
			MsgBox "Le champ 'Montant CHF' doit être positif  si le type est différent de 'Apport' ou de 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantCHF)
		End If
	End If
End Sub
'******************************************
