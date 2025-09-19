extends Control

@onready var santeLabel = $barreEtat/sante/LabelSante
@onready var mentaleLabel = $barreEtat/santeMentale/LabelSanteMentale
@onready var efficaciteLabel = $barreEtat/efficacite/LabelEfficacite
@onready var pollutionLabel = $barreEtat/pollution/LabelPollution

func _ready() -> void:
	miseAJourHUD()

func _process(_delta):
	miseAJourHUD()
	
func miseAJourHUD():
	efficaciteLabel.text = str(Global.efficacite) + "/100"
	mentaleLabel.text = str(Global.santeMentale) + "/100"
	pollutionLabel.text = str(Global.pollution) + "/100"
	santeLabel.text = str(Global.sante) + "/100"
