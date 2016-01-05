$OBJECT=Form

' Commence RM: Software Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 08-12-2015

Option Explicit


Const fDateGain = "Date gain"
Const fDateProchGain = "Date prochain gain"

Dim oDateGain
Dim oDateProchGain
Dim dDate

'******************************************
'Sets date prochain gain 30 jours après date gainachat
'******************************************
Sub Form_OnSave()
	Set oDateGain = Form.field(fDateGain)
	Set oDateProchGain = Form.field(fDateProchGain)

    If oDateGain.Value <> "" Then
		'et uniqu si type gain est 25 % ou 28 % !!!
        dDate = DateAdd("d", 30, oDateGain.Value)
        oDateProchGain.Value = dDate
	End If
End Sub
'******************************************
