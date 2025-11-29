extends Control   # Control est la classe parente de RichTextLabel, HBoxContainer, Button, etc.

const BASE_RES = Vector2(1920, 1080)

func _ready():
	_resize()
	get_viewport().connect("size_changed", Callable(self, "_resize"))

func _resize():
	var screen_size = get_viewport_rect().size
	var scale_factor = min(
		screen_size.x / BASE_RES.x,
		screen_size.y / BASE_RES.y
	)
	self.scale = Vector2(scale_factor, scale_factor)
