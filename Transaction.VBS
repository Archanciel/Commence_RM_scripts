$OBJECT=Form

' Commence RM -- Factur Assurance Category / Main Form
' Copyright © 2001 Commence Corporation. All Rights Reserved

Option Explicit


Const fType = "Type"
Const fOnLine = "On-Line"

Dim oTypeRadioGrp
Dim oOnLineChkBox

Set oTypeRadioGrp = Form.field(fType)
Set oOnLineChkBox = Form.field(fOnLine)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	If FieldName = fType Then
		If InStr(oTypeRadioGrp.Value,"Ench") Then	'WARN: since accented letter in Enchère prevents str comparison, InStr is used !
			oOnLineChkBox.Value = 1
		End If
	End If
End Sub
'******************************************
