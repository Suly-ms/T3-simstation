extends Control

@onready var santeLabel = $barreEtat/sante/LabelSante
@onready var bonheurLabel = $barreEtat/bonheur/Labelbonheur
@onready var efficaciteLabel = $barreEtat/efficacite/LabelEfficacite
@onready var pollutionLabel = $barreEtat/pollution/LabelPollution

func miseAJourHUD():
	efficaciteLabel.text = str(Global.stats["efficacite"]) + "/100"
	bonheurLabel.text = str(Global.stats["bonheur"]) + "/100"
	pollutionLabel.text = str(Global.stats["pollution"]) + "/100"
	santeLabel.text = str(Global.stats["sante"]) + "/100"
	
func _ready() -> void:
	miseAJourHUD()

func _process(delta):
	miseAJourHUD()
