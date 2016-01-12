$OBJECT=Form

' Commence RM: Software Category / Main Form
' Author: Jean-Pierre Schnyder
' Date: 08-12-2015

Option Explicit


Const fDateGain = "Date gain"
Const fDateProchGain = "Date prochain gain"
Const fTypeGain = "Type gain"
Const fNoGain = "No gain"
Const GAIN_TYPE_BONUS_ACHAT_PACK_PAR_FILLEUL = "Bonus achat pack par filleul"
Const GAIN_TYPE_BONUS_FILLEUL_UPGR_PREMIUM = "Bonus filleul upgr Premium"
Const GAIN_TYPE_BONUS_FILLEUL_UPGR_SE = "Bonus filleul upgr SE"


Dim oDateGain
Dim oDateProchGain
Dim dDate
Dim oTypeGain
Dim oNoGain

'******************************************
'Sets date prochain gain 30 jours après date gainachat
'******************************************
Sub Form_OnSave()
	Set oDateGain = Form.field(fDateGain)
	Set oDateProchGain = Form.field(fDateProchGain)
	Set oTypeGain = Form.field(fTypeGain)
	Set oNoGain = Form.field(fNoGain)

    If oDateGain.Value <> "" And oNoGain.Value < 12 Then
		'si le no de gain est 12, c'est le dernier pour ce pack --> pas de prochain gain !
		'pour les autres gains qui ne sont pas des gains de pack, le champ No de gain n'est pas utilisé et reste à 0.
		If oTypeGain.Value = GAIN_TYPE_BONUS_FILLEUL_UPGR_SE Then
			'l'affiliation SE se renouvelle 360 j plus tard
			'dDate = DateAdd("d", 360, oDateGain.Value)
			'le renouvellement de l'affiliation SE n'apporte pas de nouvesu bonus !
			dDate = ""
		Elseif oTypeGain.Value <> GAIN_TYPE_BONUS_ACHAT_PACK_PAR_FILLEUL And oTypeGain.Value <> GAIN_TYPE_BONUS_FILLEUL_UPGR_PREMIUM Then
			'les gain dus à l'achat d'un pack par un filleul ne se produisent qu'une seule fois ! Idem pour l'upgrade en Premium !
			'Ainsi, seul les gains 25 %, 28 % et les bonus des matrices Premium et SE ont une date de prochain gain !
			dDate = DateAdd("d", 30, oDateGain.Value)
		Else
			dDate = ""
		End if
	Else
		dDate = ""
	End If
    oDateProchGain.Value = dDate
End Sub
'******************************************
