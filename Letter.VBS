$OBJECT=Form

' Commence RM -- Factur Assurance Category / Main Form
' Copyright © 2001 Commence Corporation. All Rights Reserved

Option Explicit


Const fType = "Type"
Const fModeEnvoi = "Mode d'envoi"

Dim oType
Dim oModeEnvoi

Set oType = Form.field(fType)
Set oModeEnvoi = Form.field(fModeEnvoi)

'******************************************
Sub Form_OnLeaveField(ByVal FieldName)
	If FieldName = fType Then
		If oType.Value <> "Lettre" And oType.Value <> "Paquet" Then
			oModeEnvoi.Value = "N/A"
		ElseIf oType.Value = "Lettre" Then
			oModeEnvoi.Value = "Courrier A"
		ElseIf oType.Value = "Paquet" Then
			oModeEnvoi.Value = "Inscrit"
		End If
	End If
End Sub
'******************************************
