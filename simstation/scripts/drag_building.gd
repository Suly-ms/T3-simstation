extends TextureRect

# DESCRIPTION :
# Script gérant un élément d'interface (TextureRect) qui permet de placer un bâtiment sur la carte via un système de Drag & Drop personnalisé.
# Il s'occupe de l'instanciation visuelle du bâtiment, de son alignement sur la grille (snapping) et de la validation du placement.
# Les fonctions disponibles sont :
# _gui_input : Détecte le clic gauche sur l'icône pour lancer le mode placement si le stock est suffisant.
# _input : Gère les entrées globales pendant le déplacement (clic gauche relâché pour poser, clic droit pour annuler).
# _process : Met à jour en temps réel la position du bâtiment sous la souris et gère le feedback visuel (rouge/normal).
# start_dragging : Crée l'instance temporaire du bâtiment avec un contour de sélection et déduit la ressource de l'inventaire.
# place_building : Valide la position finale, retire le contour de sélection et ancre le bâtiment sur la carte.
# cancel_placement : Annule l'opération, supprime l'instance temporaire et rembourse le bâtiment dans l'inventaire.
# update_visual_feedback : Modifie la couleur du sprite (rouge transparent si la zone est invalide) pour guider le joueur.

@export var grid_size : int = 64 # Adapte à ta TileMap (souvent 32, 64 ou 128)

var batiment_instance : Node2D = null # Ce sera notre Sprite
var map_ref = null
var dragging : bool = false

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _get_drag_data(_at_position):
	return null

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Global.inventaire.get(name, 0) > 0:
			start_dragging()
		else:
			print("Pas assez de ressources !")

func _input(event):
	if dragging and batiment_instance:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				place_building() # Relâchement = Poser
				GameManager.add_batiment(batiment_instance.name, 1)
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				cancel_placement() # Clic droit = Annuler

func _process(_delta):
	if dragging and batiment_instance and map_ref:
		var mouse_global_pos = map_ref.get_global_mouse_position()
		
		# Aimantation à la grille
		var snapped_pos = mouse_global_pos.snapped(Vector2(grid_size, grid_size))
		
		batiment_instance.global_position = snapped_pos
		
		# Rouge si occupé, Blanc si libre
		update_visual_feedback()

func start_dragging():
	var maps = get_tree().get_nodes_in_group("Map")
	if maps.size() > 0:
		map_ref = maps[0]
	else:
		return

	batiment_instance = Sprite2D.new()
	batiment_instance.texture = texture
	batiment_instance.name = name
	batiment_instance.set_meta("type_batiment", name)
	#print("NOM BATIMENT QUI VIENT DETRE PLACE : "+batiment_instance.name)
	
	var contour = ReferenceRect.new()
	contour.name = "ContourDeSelection" # On lui donne un nom pour le retrouver
	contour.editor_only = false 
	contour.border_color = Color.GRAY
	contour.border_width = 2.0 
	contour.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	contour.custom_minimum_size = texture.get_size()
	contour.size = texture.get_size()
	contour.position = -texture.get_size() / 2
	
	batiment_instance.add_child(contour)

	map_ref.add_temp_building(batiment_instance)
	
	dragging = true
	GlobalScript.modifier_batiment(name, -1)

func place_building():
	if not batiment_instance: return
	
	if map_ref.is_placable(batiment_instance):
		batiment_instance.modulate = Color(1, 1, 1, 1)
		
		var contour = batiment_instance.get_node_or_null("ContourDeSelection")
		if contour:
			contour.queue_free() # On détruit juste le cadre gris
		
		map_ref.validate_building(batiment_instance)
		
		batiment_instance = null
		dragging = false
	else:
		cancel_placement()

func cancel_placement():
	if batiment_instance:
		batiment_instance.queue_free() # On détruit le sprite
		batiment_instance = null
		Global.modifier_batiment(name, 1)
	dragging = false

func update_visual_feedback():
	if map_ref.is_placable(batiment_instance):
		batiment_instance.modulate = Color(1, 1, 1, 0.7)
	else:
		batiment_instance.modulate = Color(1, 0.2, 0.2, 0.7) 
