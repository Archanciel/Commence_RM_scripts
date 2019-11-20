$OBJECT=Form

' Commence RM: Facture Assurance Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 31-05-2013

Option Explicit


Const fName = "Name"
Const fMontantRembours = "Montant remb"
Const fMontantAPayer = "A payer"
Const fRefuseChkBox = "Refusé" 'é requires ANSI file encoding !

Dim oName
Dim oMontantRembours
Dim oMontantAPayer
Dim oRefuseChkBox 

Set oName = Form.field(fName)
Set oMontantRembours = Form.field(fMontantRembours)
Set oMontantAPayer = Form.field(fMontantAPayer)
Set oRefuseChkBox = Form.field(fRefuseChkBox)

Const fRemboursChkBox = "Remboursé" 'é requires ANSI file encoding !
Dim oRemboursChkBox
Set oRemboursChkBox = Form.field(fRemboursChkBox)

Const fFranchise300ChkBox = "Franchise 300" 'é requires ANSI file encoding !
Dim oFranchise300ChkBox
Set oFranchise300ChkBox = Form.field(fFranchise300ChkBox)

Const fFranchise750ChkBox = "Franchise 750" 'é requires ANSI file encoding !
Dim oFranchise750ChkBox
Set oFranchise750ChkBox = Form.field(fFranchise750ChkBox)

'******************************************
Sub Form_OnEnterTab(ByVal TabName)
	Dim oxAddress
	Set oxAddress = Form.Connection("Relates to", "Address")
	
	If oxAddress.ConnectedItemCount = 0 Then
		'means we are not editing an existing item, but truly creating a new one !
		'WARNING: due to the fact that the Address category has phone number as complimentary field,
		'the connection to the Address item will not be set if it has a phone number !!!Ã¼
		oxAddress.SetConnection "Supra", ""
	End If
End Sub
'******************************************

'******************************************
Sub computeReimbursedAmount()
	If oMontantAPayer.Value <> "" Then
		If oMontantRembours.Value = "" Then
			If InStr(UCase(oName.value), "PHARMACIE") Then
				oMontantRembours.Value = oMontantAPayer.Value * 0.75
			ElseIf InStr(UCase(oName.value), "CMS") Then
				oMontantRembours.Value = oMontantAPayer.Value * 0.90
			ElseIf oFranchise300ChkBox.Value <> 0 Then
				oMontantRembours.Value = 0
			ElseIf oFranchise750ChkBox.Value <> 0 Then
				oMontantRembours.Value = oMontantAPayer.Value * 0.90
			Else
				oMontantRembours.Value = oMontantAPayer.Value
			End If
		Else
			If oFranchise300ChkBox.Value <> 0 Then
				oMontantRembours.Value = 0
			ElseIf oFranchise750ChkBox.Value <> 0 Then
				oMontantRembours.Value = oMontantAPayer.Value * 0.90
			End If
		End If
	End If
End Sub
'******************************************

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
   If FieldName = fMontantAPayer Then
		Call computeReimbursedAmount()
   ElseIf FieldName = fRemboursChkBox Then
	    If oRemboursChkBox.Value <> 0 Then
			oRefuseChkBox.Value = 0
		End If
   ElseIf FieldName = fRefuseChkBox Then
	    If oRefuseChkBox.Value <> 0 Then
		    oMontantRembours.Value = 0
			oRemboursChkBox.Value = 0
		Else
			oMontantRembours.Value = ""
			Call computeReimbursedAmount()
		End If			
   ElseIf FieldName = fFranchise300ChkBox Then
	    If oFranchise300ChkBox.Value <> 0 Then
			oFranchise750ChkBox.Value = 0
			Call computeReimbursedAmount()
		Else
			oMontantRembours.Value = oMontantAPayer.Value
		End If			
   ElseIf FieldName = fFranchise750ChkBox Then
	    If oFranchise750ChkBox.Value <> 0 Then
			oFranchise300ChkBox.Value = 0
			Call computeReimbursedAmount()
		Else
			oMontantRembours.Value = oMontantAPayer.Value
		End If			
   End If
End Sub
'******************************************

