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

func _on_pressed() -> void:
	load_scene("res://scenes/shop.tscn", "Shop")

func _on_pressed_recherches():
	load_scene("res://scenes/arbre_recherche.tscn", "ArbreRecherche")
	
func load_scene(chemin_scene, nom_node):
	var arbre_scene = load(chemin_scene)
	var current_scene = get_tree().current_scene

	if not current_scene.has_node(nom_node):  
		var instance = arbre_scene.instantiate()
		instance.name = nom_node       
		current_scene.add_child(instance)
	else:
		var node = current_scene.get_node(nom_node)
		node.queue_free()
	Global.camera_enable = !Global.camera_enable
