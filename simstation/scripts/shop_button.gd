extends Button

# Resize
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


# Ouverture d'une fenetre
const SHOP_SCENE = preload("res://scenes/shop.tscn")

func _on_pressed() -> void:
	var current_scene = get_tree().current_scene

	if not current_scene.has_node("Shop"):   # évite les doublons
		var shop_instance = SHOP_SCENE.instantiate()
		shop_instance.name = "Shop"         # important pour l’identifier
		current_scene.add_child(shop_instance)
	else:
		var shop_node = current_scene.get_node("Shop")
		var shop_background = shop_node.get_node("CanvasLayer/background")
		shop_background.visible = !shop_background.visible
	Global.camera_enable = !Global.camera_enable
