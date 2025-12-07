extends Control

@onready var message_label = $background/message
var batiment = ""

func _ready():
	message_label.bbcode_text = "[center][font_size=56]Voulez-vous vraiment acheter le batiment : \n" + Global.info_batiments[batiment][3] + " ?"

func _on_confirm_button_pressed() -> void:
	var prix = GlobalScript.get_batiment_prix(batiment)
	if(prix!=null and GlobalScript.get_argent() >= GlobalScript.get_batiment_prix(batiment)):
		GlobalScript.modifier_argent(-prix)
		GlobalScript.modifier_batiment(batiment, 1)
		self.queue_free()

func _on_cancel_button_pressed() -> void:
	self.queue_free()
