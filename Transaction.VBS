$OBJECT=Form

' Commence RM: Software Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 12-06-2013

Option Explicit


Const fType = "Type"
Const fOnLine = "On-Line"
Const fEtat = "Etat"
Const fAlarm = "Alarm"

Dim oTypeRadioGrp
Dim oOnLineChkBox
Dim oEtatCombo
Dim oAlarmChkBox

Set oTypeRadioGrp = Form.field(fType)
Set oOnLineChkBox = Form.field(fOnLine)
Set oEtatCombo = Form.field(fEtat)
Set oAlarmChkBox = Form.field(fAlarm)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	If FieldName = fType Then
		If InStr(oTypeRadioGrp.Value,"auct") Then	'WARN: since accented letter in Enchère prevents str comparison, InStr is used !
			oOnLineChkBox.Value = 1
		End If
	ElseIf FieldName = fEtat Then
		If InStr(oEtatCombo.Value,"Command") <> 1 Then
			oAlarmChkBox.Value = 0
		End If
	End If
End Sub
'******************************************
