$OBJECT=Form

' Commence RM -- Factur Assurance Category / Main Form
' Copyright © 2001 Commence Corporation. All Rights Reserved

Option Explicit


Const fRegistered = "Registered"
Const fInstDate = "Date inst/updt"
Const fRegDate = "Registration date"

Dim oRegisteredChkBox
Dim oInstDateField
Dim oRegDateField

Set oRegisteredChkBox = Form.field(fRegistered)
Set oInstDateField = Form.field(fInstDate)
Set oRegDateField = Form.field(fRegDate)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	If FieldName = fRegistered Then
		If oRegisteredChkBox.Value = 1 Then
			oRegDateField.Value = oInstDateField.Value
		Else
			oRegDateField.Value = ""
		End If
	End If
End Sub
'******************************************
