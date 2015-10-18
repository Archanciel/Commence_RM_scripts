$OBJECT=Form

Option Explicit

' Modèle de base VBScript pour masques COMMENCE
' Reportez-vous à votre documentation COMMENCE pour en savoir plus sur la mise en place de scripts.
Const fMontantUSD = "Montant USD"
Const fMontantUSDTotal = "Montant USD total"
Const fMontantCHF = "Montant CHF"
Const fType = "Type"

Dim oMontantUSD
Dim oMontantUSDTotal
Dim oMontantCHF
Dim oType

Set oMontantUSD = Form.field(fMontantUSD)
Set oMontantUSDTotal = Form.field(fMontantUSDTotal)
Set oMontantCHF = Form.field(fMontantCHF)
Set oType = Form.field(fType)

'******************************************
Sub Form_OnSave()
	If oType.Value = "Apport" Or oType.Value = "Transfert de" Then
		If oMontantUSD.Value >= 0 Then
			MsgBox "Le champs " & fMontantUSD & " doit être négatif si le type est 'Apport' ou 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantUSD)
		ElseIf oMontantUSDTotal.Value >= 0 Then
			MsgBox "Le champs " & fMontantUSDTotal & " doit être négatif si le type est 'Apport' ou 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantUSDTotal)
		ElseIf oMontantCHF.Value >= 0 Then
			MsgBox "Le champs " & fMontantCHF & " doit être négatif  si le type est 'Apport' ou 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantCHF)
		End If
	Else
		If oMontantUSD.Value <= 0 Then
			MsgBox "Le champs " & fMontantUSD & " doit être positif si le type est différent de 'Apport' ou de 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantUSD)
		ElseIf oMontantUSDTotal.Value <= 0 Then
			MsgBox "Le champs " & fMontantUSDTotal & " doit être positif si le type est différent de 'Apport' ou de 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantUSDTotal)
		ElseIf oMontantCHF.Value <= 0 Then
			MsgBox "Le champ " & fMontantCHF & " doit être positif  si le type est différent de 'Apport' ou de 'Transfert de' !", vbOKOnly + vbCritical, "*** ERREUR ***"
			Form.MoveToField (fMontantCHF)
		End If
	End If
End Sub
'******************************************
