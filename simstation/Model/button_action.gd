extends Button

# DESCRIPTION :
# Script de gestion de l'interface utilisateur (UI) et de la navigation entre les différents menus.
# Il permet de charger dynamiquement des scènes (Shop, Arbre de recherche, Pause) dans le HUD,
# ou de basculer leur visibilité si elles sont déjà instanciées, tout en gérant l'activation de la caméra.
# Les fonctions disponibles sont :
# _on_pressed_shop, _on_pressed_recherches, _on_pressed_pause : Fonctions liées aux boutons pour ouvrir les menus correspondants.
# _physics_process : Surveille les entrées joueur pour déclencher le menu pause via le clavier.
# load_scene : Fonction générique qui instancie une scène dans le HUD ou inverse sa visibilité (toggle), et bloque/débloque la caméra.
# exit_button : Force la fermeture d'un menu spécifique (le rend invisible) et réactive la caméra.

func _on_pressed_shop() -> void:
	load_scene("res://View/shop.tscn", "Shop")

func _on_pressed_pause():
	load_scene("res://View/pause.tscn", "Pause")

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

	GlobalScript.set_camera(!GlobalScript.get_camera())

func exit_button(nom_node):
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")

	if hud.has_node(nom_node):
		hud.get_node(nom_node).visible = false
		GlobalScript.set_camera(!GlobalScript.get_camera())
