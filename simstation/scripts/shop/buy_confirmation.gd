extends Control

@onready var message_label = $message

func _ready():
	var nom_batiment = Global.batiment_en_cours_achat
	if message_label:
		message_label.bbcode_text = "[center][font_size=56]Voulez-vous vraiment acheter le batiment : " + nom_batiment + " ?"
