extends Control

@onready var argent_label = $CanvasLayer/background/argent

func _ready():
	GlobalScript.connect("argent_changed", Callable(self, "_on_argent_changed"))
	_on_argent_changed(GlobalScript.get_argent())
	
func _on_argent_changed(new_value):
	if argent_label:
		argent_label.bbcode_text = "[right][font_size=24]" + GlobalScript.format_money(new_value) + " €"

func _on_passer_tour_pressed():
	pass # Replace with function body.
