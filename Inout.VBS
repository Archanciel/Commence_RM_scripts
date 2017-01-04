$OBJECT=Form

' Commence RM: In-out Category / GBC Form
' Author: Jean-Pierre Schnyder
' Date: 11-12-2016

Option Explicit


Const fMLM = "MLM"
Const fNom = "Nom"
Const fMBTC = "Coût BTC"
Const fVCtrat = "Val ctrat BTC"
Const fDExec = "Date exécution"
Const fDOrdre = "Date ordre"
Const fMoisOp = "Mois op"

Dim oMLM
Dim oNom
Dim oMBTC
Dim oVCtrat
Dim oDExec
Dim oDOrdre
Dim oMoisOp

Set oMLM = Form.field(fMLM)
Set oNom = Form.field(fNom)
Set oMBTC = Form.field(fMBTC)
Set oVCtrat = Form.field(fVCtrat)
Set oDExec = Form.field(fDExec)
Set oDOrdre = Form.field(fDOrdre)
Set oMoisOp = Form.field(fMoisOp)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	Dim oxContrat
	Dim strDateExec
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
			strDateExec = oDExec.Value
			If oDOrdre.Value = "" Then
				oDOrdre.Value = strDateExec
			End If
			If oMoisOp.Value = "" Then
				oMoisOp.Value = Mid(strDateExec,7,4) & Mid(strDateExec,4,2)
			End If
		End If
	End If
End Sub
'******************************************
