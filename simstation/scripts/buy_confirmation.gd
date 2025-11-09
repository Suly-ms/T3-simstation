extends Control

@onready var message_label = $background/message
var batiment = ""

func _ready():
	message_label.bbcode_text = "[center][font_size=56]Voulez-vous vraiment acheter ce batiment ?"

func _on_confirm_button_pressed() -> void:
	var prix = Global.batiments_prix.get(batiment)
	if(prix!=null and Global.argent >= Global.batiments_prix[batiment]):
		Global.modifier_argent(-prix)
		Global.modifier_batiment(batiment, 1)
		self.queue_free()  

func _on_cancel_button_pressed() -> void:
	self.queue_free()
