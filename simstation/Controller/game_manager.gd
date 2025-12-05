extends Node

var current_map: Node = null 
var zoom_cam: Vector2
var path_building: Node

func set_current_map(map: Node):
	current_map = map

func get_current_map() -> Node:
	return current_map
	
func set_current_zoom_cam(zoom_cam : Vector2):
	zoom_cam = zoom_cam

func get_zoom_cam() -> Vector2:
	return zoom_cam
	
func add_batiment(nomBatiment, nombre):
	GlobalScript.add_batiment(nomBatiment, nombre)
	
func ouvrir_recherche():
	load_scene("res://View/arbre_recherche.tscn", "ArbreRecherche")
	
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
