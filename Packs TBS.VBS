$OBJECT=Form

'******************************************
' Packs TBS.VBS
'******************************************

'******************************************
' Commence RM: Software Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 08-12-2015
'******************************************

Option Explicit


Const fDateAchat = "Date achat"
Const fHeureAchat = "Heure achat"
Const fDatePremGain = "Date prem. gain"
Const fHeurePremGain = "Heure prem. gain"

Dim oDateAchat
Dim oHeureAchat
Dim oDatePremGain
Dim oHeurePremGain
Dim dDate
Dim dHeure
Dim a

'******************************************
'Sets date premier gain 30 jours après date achat si l'heure d'achat
'est <= 18.00. Sinon, date premier gain est settée 31 jours après 
'date achat et l'heure du premier gain à 6.00 !
'******************************************
Sub Form_OnSave()
	Set oDateAchat = Form.field(fDateAchat)
	Set oHeureAchat = Form.field(fHeureAchat)
	Set oDatePremGain = Form.field(fDatePremGain)
	Set oHeurePremGain = Form.field(fHeurePremGain)

    If oDateAchat.Value <> "" Then
		'conversion d'un string 19:32 en un double 19.32 afin de pouvoir 
		'comparer avec le nombre 18 !
		a = Split(oHeureAchat.Value,":")
		dHeure = CDbl(a(0) & "." & a(1))
		'Un pack acheté entre 5.00 H et 17.00 -> gain 30 j + tard à 17.00 H
		'Un pack acheté entre 17.00 H et minuit -> gain 31 j + tard à 5.00 H
		'Un pack acheté entre minuit et 5.00 H -> gain 30 j + tard à 5.00 H
		If dHeure >= 17 And dHeure <= 23.59 Then
			dHeure = 5
			dDate = DateAdd("d", 31, oDateAchat.Value)
		ElseIf dHeure >= 0 And dHeure < 5 Then
			dHeure = 5
			dDate = DateAdd("d", 30, oDateAchat.Value)
		ElseIf dHeure >= 5 And dHeure < 17 Then
			dHeure = 17
			dDate = DateAdd("d", 30, oDateAchat.Value)
		End If
        oDatePremGain.Value = dDate
        oHeurePremGain.Value = dHeure
	End If
End Sub
'******************************************
