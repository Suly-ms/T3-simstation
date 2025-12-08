extends TextureRect

# DESCRIPTION GLOBALE DU SCRIPT
# Ce script gère l'interface utilisateur (UI) pour le placement de bâtiments via un système de
# "Drag & Drop" (Glisser-Déposer) manuel.
#
# Fonctionnalités principales :
# 1. Détection du clic sur l'icône dans l'inventaire pour commencer le placement.
# 2. Instanciation visuelle d'un bâtiment temporaire ("fantôme") qui suit la souris.
# 3. Affichage automatique d'une grille visuelle (lignes) sur la carte pendant le déplacement.
# 4. Système d'aimantation (Snapping) pour aligner parfaitement le bâtiment sur la grille (64x64).
# 5. Gestion des collisions : le bâtiment devient rouge si l'emplacement est invalide.
# 6. Validation (Clic Gauche) : Place le bâtiment, met à jour les stats et retire la grille.
# 7. Annulation (Clic Droit) : Annule l'opération et rembourse le coût.

@export var grid_size : int = 64

var batiment_instance : PackedScene = null
var map_ref = null
var dragging : bool = false
var grid_visual_instance : Node2D = null

# Configure le curseur de la souris au survol de l'icône dans l'interface.
func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

# Surcharge la fonction native de drag & drop pour éviter le comportement par défaut de Godot.
func _get_drag_data(_at_position):
	return null

# Détecte le clic initial sur l'interface pour lancer le mode construction si les ressources sont suffisantes.
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GlobalScript.get_batiment_inventaire(name) > 0:
			start_dragging()
		else:
			print("Pas assez de ressources !")

# Gère les clics globaux pendant le déplacement (Clic gauche pour poser, Clic droit pour annuler).
func _input(event):
	if dragging and batiment_instance:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				place_building()
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				cancel_placement()

# Met à jour la position du bâtiment à chaque frame, gère l'aimantation à la grille et le feedback visuel (couleur).
func _process(_delta):
	if dragging and batiment_instance and map_ref:
		var mouse_global_pos = map_ref.get_global_mouse_position()
		var snapped_pos = mouse_global_pos.snapped(Vector2(grid_size, grid_size))
		
		batiment_instance.global_position = snapped_pos
		update_visual_feedback()

# Initialise le processus de drag : crée le visuel du bâtiment, active la grille et déduit le stock.
func start_dragging():
	var maps = get_tree().get_nodes_in_group("Map")
	if maps.size() > 0:
		map_ref = maps[0]
	else:
		return

	grid_visual_instance = GridDrawer.new()
	grid_visual_instance.cell_size = grid_size
	grid_visual_instance.z_index = 1 
	map_ref.add_child(grid_visual_instance)

	batiment_instance.size = texture
	batiment_instance.name = name
	batiment_instance.set_meta("type_batiment", name)
	batiment_instance.z_index = 2
	
	var contour = ReferenceRect.new()
	contour.name = "ContourDeSelection"
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

# Tente de valider la position du bâtiment. Si valide, finalise le placement, sinon annule.
func place_building():
	if not batiment_instance: return
	
	if map_ref.is_placable(batiment_instance):
		batiment_instance.modulate = Color(1, 1, 1, 1)
		
		var contour = batiment_instance.get_node_or_null("ContourDeSelection")
		if contour:
			contour.queue_free()
		
		map_ref.validate_building(batiment_instance)
		CalculStats._ajouter_stats_nouveau_batiment(name)
		
		batiment_instance = null
		dragging = false
		remove_grid()
	else:
		cancel_placement()

# Annule le placement en cours, détruit l'instance temporaire et rembourse l'inventaire.
func cancel_placement():
	if batiment_instance:
		batiment_instance.queue_free()
		batiment_instance = null
		GlobalScript.modifier_batiment(name, 1)
	
	dragging = false
	remove_grid()

# Supprime proprement l'instance de la grille visuelle de la scène.
func remove_grid():
	if grid_visual_instance:
		grid_visual_instance.queue_free()
		grid_visual_instance = null

# Change la couleur du bâtiment (Normal ou Rouge) selon s'il peut être placé à l'endroit actuel.
func update_visual_feedback():
	if map_ref.is_placable(batiment_instance):
		batiment_instance.modulate = Color(1, 1, 1, 0.7)
	else:
		batiment_instance.modulate = Color(1, 0.2, 0.2, 0.7)

# Classe interne utilitaire servant uniquement à dessiner les lignes de la grille via la fonction _draw().
class GridDrawer extends Node2D:
	var cell_size = 64
	var grid_color = Color(0.0, 0.0, 0.0, 1.0)
	var draw_area = Rect2(-5000, -5000, 10000, 10000)

	func _draw():
		var left = int(draw_area.position.x / cell_size) * cell_size
		var right = int(draw_area.end.x)
		var top = int(draw_area.position.y / cell_size) * cell_size
		var bottom = int(draw_area.end.y)

		for x in range(left, right, cell_size):
			draw_line(Vector2(x, top), Vector2(x, bottom), grid_color)

		for y in range(top, bottom, cell_size):
			draw_line(Vector2(left, y), Vector2(right, y), grid_color)
