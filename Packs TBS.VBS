$OBJECT=Form

' Commence RM: Software Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 08-12-2015

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
		
		If dHeure > 18 Then
			dDate = DateAdd("d", 31, oDateAchat.Value)
			dHeure = 6
		Else
			dDate = DateAdd("d", 30, oDateAchat.Value)
		End If
		
        oDatePremGain.Value = dDate
        oHeurePremGain.Value = dHeure
	End If
End Sub
'******************************************
