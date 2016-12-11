$OBJECT=Form

' Commence RM: Letter Log Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 10-06-2013

Option Explicit


Const fMLM = "MLM"
Const fNom = "Nom"
Const fMBTC = "Montant BTC"
Const fVCtrat = "Valeur contrat"
Const fDExec = "Date exécution"
Const fDOrdre = "Date ordre"

Dim oMLM
Dim oNom
Dim oMBTC
Dim oVCtrat
Dim oDExec
Dim oDOrdre

Set oMLM = Form.field(fMLM)
Set oNom = Form.field(fNom)
Set oMBTC = Form.field(fMBTC)
Set oVCtrat = Form.field(fVCtrat)
Set oDExec = Form.field(fDExec)
Set oDOrdre = Form.field(fDOrdre)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	Dim oxContrat
	Set oxContrat = Form.Connection("Concerne", "Contrat")

	If FieldName = fMLM Then
		If oMLM.Value = "GBC" Then
			If oNom.Value = "" Then
				oNom.Value = "Approvionnement btcpourlavie"
			End If
	
			If oxContrat.ConnectedItemCount = 0 Then
				'means we are not editing an existing item, but truly creating a new one !
				'WARNING: due to the fact that the Address category has phone number as complimentary field,
				'the connection to the Address item will not be set if it has a phone number !!!ü
				oxContrat.SetConnection "GBC JPS btcpourlavie", ""
			End If
		End If
	End If

	If oMLM.Value = "GBC" Then
		If FieldName = fMBTC Then
			If oVCtrat.Value = "" Then
				oVCtrat.Value = oMBTC.Value
			End If
		End If

		If FieldName = fDExec Then
			If oDOrdre.Value = "" Then
				oDOrdre.Value = oDExec.Value
			End If
		End If
	End If
End Sub
'******************************************
