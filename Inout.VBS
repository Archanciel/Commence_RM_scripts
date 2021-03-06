$OBJECT=Form

' Commence RM: In-out Category / GBC Form
' Author: Jean-Pierre Schnyder
' Date: 11-12-2016

Option Explicit

Const fMLM = "MLM"
Const fNom = "Nom"
Const fMBTC = "Co�t BTC"
Const fVCtrat = "Val ctrat BTC"
Const fDExec = "Date ex�cution"
Const fDOrdre = "Date ordre"
Const fMoisOp = "Mois op"
Const fCreerAlarmeChkBox = "Cr�er alarme"
Const fInvDirectChkBox = "Inv direct"
Const fFeesBTC = "Fees BTC"

Const fCoutBTC = "Co�t BTC"
Const fMontantUSD = "Montant USD"
Const fCoursHistUsdChf = "Cours hist USD/CHF"

Const fCoursActBTCUSD = "Cours act BTC/USD"
Const fCoursActUSDCHF = "Cours act USD/CHF"

Dim oMLM
Dim oNom
Dim oMBTC
Dim oVCtrat
Dim oDExec
Dim oDOrdre
Dim oMoisOp
Dim oCreerAlarmeChkBox
Dim oInvDirectChkBox
Dim oFeesBTC

Dim oCoutBTC
Dim oMontantUSD
Dim oCoursHistUsdChf

Dim oCoursActBTCUSD
Dim oCoursActUSDCHF

Set oMLM = Form.field(fMLM)
Set oNom = Form.field(fNom)
Set oMBTC = Form.field(fMBTC)
Set oVCtrat = Form.field(fVCtrat)
Set oDExec = Form.field(fDExec)
Set oDOrdre = Form.field(fDOrdre)
Set oMoisOp = Form.field(fMoisOp)
Set oCreerAlarmeChkBox = Form.field(fCreerAlarmeChkBox)
Set oInvDirectChkBox = Form.field(fInvDirectChkBox)
Set oFeesBTC = Form.field(fFeesBTC)

Set oCoutBTC = Form.field(fCoutBTC)
Set oMontantUSD = Form.field(fMontantUSD)
Set oCoursHistUsdChf = Form.field(fCoursHistUsdChf)

Set oCoursActBTCUSD = Form.field(fCoursActBTCUSD)
Set oCoursActUSDCHF = Form.field(fCoursActUSDCHF)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	Dim oxContrat
	Dim strDateExec
	Set oxContrat = Form.Connection("Concerne", "Contrat")

	If FieldName = fMLM Then
		If oMLM.Value = "GBC" Then
			If oNom.Value = "" Then
				oNom.Value = "Approvionnement btcpourlavie"
				oCreerAlarmeChkBox.Value = 0
			End If
	
			If oxContrat.ConnectedItemCount = 0 Then
				'means we are not editing an existing item, but truly creating a new one !
				'WARNING: due to the fact that the Address category has phone number as complimentary field,
				'the connection to the Address item will not be set if it has a phone number !!!�
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
				'oMoisOp.Value = yyyy-mm
				oMoisOp.Value = Mid(strDateExec,7,4) & "-" & Mid(strDateExec,4,2)
			End If
		End If
	End If
	
	If FieldName = fInvDirectChkBox Then
		If oInvDirectChkBox.Value = 1 Then
			oFeesBTC.Value = 0
		End If
	End If

	If FieldName = fCoutBTC Or _
	   FieldName = fFeesBTC Or _
	   FieldName = fDExec Or _
	   FieldName = fInvDirectChkBox Or _
	   FieldName = fMontantUSD Then
		If mustCalculateMontantUSD() Then
			populateMontantUSDAndUSDCHFRate
		End If
	End If
End Sub
'******************************************

'******************************************
Private function mustCalculateMontantUSD()
	mustCalculateMontantUSD = (oCoutBTC.Value <> "" And _
							   ((oInvDirectChkBox.Value = 0 And oFeesBTC.Value <> "") Or oInvDirectChkBox.Value = 1) And _
							   oDExec.Value <> "" And _
							   (oMontantUSD.Value = "" Or oMontantUSD.Value = "0.00"))
End Function
'******************************************
	
'******************************************
Private Sub populateMontantUSDAndUSDCHFRate()
	'Writing input args for the python file
	Dim fso
	Dim file
	
	Set fso  = CreateObject("Scripting.FileSystemObject")
	Set file = fso.CreateTextFile("c:\temp\input.txt", 1)

	'writing rate date, BTC contract value, BTC fee value
	file.write(oDExec.Value & vbCrLf)
	file.write(oCoutBTC.Value & vbCrLf)
	file.write(oFeesBTC.Value & vbCrLf)

	file.Close

	'executing python file to collect data
	Dim strCommand
	Dim WshShell
	
	strCommand = "D:\Users\Jean-Pierre\OneDrive\Documents\Commence\VBScript\getXRates.bat" 
	Set WshShell = CreateObject("WScript.Shell") 
	WshShell.Run strCommand,0,True
	Set WshShell = Nothing

	'reading data collected by the python file
	Dim usdAmountTotal
	Dim usdChfRate
	Dim statusMsg
	
	Set fso  = CreateObject("Scripting.FileSystemObject")
	Set file = fso.OpenTextFile("c:\temp\output.txt", 1)

	If Not file.AtEndOfStream Then
		statusMsg = file.ReadLine
	End If

	If Not file.AtEndOfStream Then
		usdAmountTotal = file.ReadLine
	End If

	If Not file.AtEndOfStream Then
		usdChfRate = file.ReadLine
	End If

	file.Close
	
	MsgBox statusMsg, vbInformation 
	
	oMontantUSD.Value = usdAmountTotal
	oCoursHistUsdChf.Value = usdChfRate 
End Sub
'******************************************

Sub Form_OnClick(ByVal ControlID)
	If ControlID = "CommandButton1" Then

		'executing python file to collect data
		Dim strCommand
		Dim WshShell
		strCommand = "D:\Users\Jean-Pierre\OneDrive\Documents\Commence\VBScript\getRealTimeXRates.bat" 
		Set WshShell = CreateObject("WScript.Shell") 
		WshShell.Run strCommand,0,True
		Set WshShell = Nothing

		'reading data collected by the python file
		Dim btcUsdRate
		Dim usdChfRate
		Dim statusMsg
		Dim fso
		Dim file
		
		Set fso  = CreateObject("Scripting.FileSystemObject")
		Set file = fso.OpenTextFile("c:\temp\output.txt", 1)

		If Not file.AtEndOfStream Then
			statusMsg = file.ReadLine
		End If

		If Not file.AtEndOfStream Then
			btcUsdRate = file.ReadLine
		End If

		If Not file.AtEndOfStream Then
			usdChfRate = file.ReadLine
		End If

		file.Close
		
		updateAllGBCInOutItems btcUsdRate, usdChfRate
	End If
End Sub

Sub updateAllGBCInOutItems(ByVal btcUsdRate, ByVal usdChfRate)
	Dim CommenceDB	
	Set CommenceDB = Application.Database

	Dim cursorInOut
	Set cursorInOut = CommenceDB.GetCursor(0, "In-Out", 0)

	cursorInOut.SetFilter "[ViewFilter(1,F,,MLM,Equal to,GBC,)]", 0
 
	Dim nInOut
	nInOut = cursorInOut.RowCount()
	
	Dim answer
	answer = MsgBox("Updating " & nInOut & " records with BTC/USD real time xrate = " & btcUsdRate & " and USD/CHF real time xrate = " & usdChfRate & " ?", vbOkCancel + vbQuestion)
	
	if answer = vbOK Then
		Dim rInOut
		Set rInOut = cursorInOut.GetEditRowSet(nInOut, 0)

		Dim idxCoursActBTCUSD: idxCoursActBTCUSD = rInOut.GetColumnIndex(fCoursActBTCUSD, 0)
		Dim idxCoursActUSDCHF: idxCoursActUSDCHF = rInOut.GetColumnIndex(fCoursActUSDCHF, 0)
		Dim i
		
		If nInOut > 0 Then
			For i = 1 To nInOut
				rInOut.ModifyRow i - 1, idxCoursActBTCUSD, btcUsdRate, 0
				rInOut.ModifyRow i - 1, idxCoursActUSDCHF, usdChfRate, 0
			Next

			rInOut.Commit 0
			Set rInOut = Nothing
		Else
			'empty
		End If

		Set cursorInOut = Nothing
		
		MsgBox "" & nInOut & " records updated with BTC/USD real time xrate = " & btcUsdRate & " and USD/CHF real time xrate = " & usdChfRate, vbInformation
	Else
		'empty
	End If
End Sub

