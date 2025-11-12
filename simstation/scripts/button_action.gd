extends Button

func _on_pressed_shop() -> void:
	load_scene("res://scenes/shop.tscn", "Shop")

func _on_pressed_recherches():
	load_scene("res://scenes/arbre_recherche.tscn", "ArbreRecherche")

func _on_pressed_pause():
	load_scene("res://scenes/pause.tscn", "Pause")

func _physics_process(_delta):
	if Input.is_action_just_pressed("pause"):
		_on_pressed_pause()

func load_scene(chemin_scene, nom_node):
	var arbre_scene = load(chemin_scene)
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud") 

	if not hud.has_node(nom_node):
		var instance = arbre_scene.instantiate()
		instance.name = nom_node
		hud.add_child(instance)
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
