extends Control

@onready var argent_label = $CanvasLayer/background/argent

func _ready():
	Global.connect("argent_changed", Callable(self, "_on_argent_changed"))	
	_on_argent_changed(Global.argent)

func _on_argent_changed(new_value):
	if argent_label:
		argent_label.bbcode_text = "[right][font_size=24]" + Global.format_money(new_value) + " €"
