extends Button

const BASE_RES = Vector2(1920, 1080)

func _ready():
	_resize()
	get_viewport().connect("size_changed", Callable(self, "_resize"))

func _resize():
	var screen_size = get_viewport_rect().size
	var scale_factor = min(screen_size.x / BASE_RES.x, screen_size.y / BASE_RES.y)
	self.scale = Vector2(scale_factor, scale_factor)

func _on_pressed_shop() -> void:
	load_scene("res://scenes/shop.tscn", "Shop")

func _on_pressed_recherches():
	load_scene("res://scenes/arbre_recherche.tscn", "ArbreRecherche")

func load_scene(chemin_scene, nom_node):
	var arbre_scene = load(chemin_scene)
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")

	if not hud.has_node(nom_node):
		var instance = arbre_scene.instantiate()
		instance.name = nom_node
		hud.add_child(instance)
		
		instance.connect("exit_button", Callable(self, "exit_button"))

	else:
		var node = hud.get_node(nom_node)
		node.visible = !node.visible  

	Global.camera_enable = !Global.camera_enable


func exit_button(nom_node):
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")

	if hud.has_node(nom_node):
		hud.get_node(nom_node).visible = false
		Global.camera_enable = !Global.camera_enable
