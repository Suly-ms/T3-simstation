extends Node2D

# DESCRIPTION :
# Script principal de la gestion de la carte (Map). Il sert de conteneur pour les bâtiments 
# et gère la logique de placement (collisions) ainsi que les interactions (clics) sur les bâtiments existants.
# La variable `buildings_layer` référence le nœud parent où sont stockés tous les bâtiments.
# Les fonctions disponibles sont :
# _ready() : Ajoute ce nœud au groupe "Map" pour qu'il soit détectable par les outils de construction.
# add_temp_building : Ajoute visuellement le bâtiment en cours de déplacement (ghost) à la scène.
# validate_building : Confirme le placement final d'un bâtiment (point d'entrée pour la logique de persistance).
# is_placable : Vérifie si le bâtiment en cours chevauche un bâtiment existant via des calculs d'intersection de rectangles (Rect2).
# _unhandled_input : Détecte les clics gauche pour sélectionner un bâtiment et émettre le signal global d'information.
# get_building_under_mouse : Identifie et retourne le bâtiment situé sous le curseur de la souris.
# get_global_rect_of : Fonction utilitaire qui calcule la zone rectangulaire globale (bounding box) d'un nœud.

@onready var buildings_layer = $Batiments 

func _ready():
	add_to_group("Map")

func add_temp_building(node: Node2D):
	buildings_layer.add_child(node)

func validate_building(node: Node2D):
	print("Bâtiment placé : ", node.name)

func is_placable(ghost_building: Node2D) -> bool:
	var ghost_rect = get_global_rect_of(ghost_building).grow(-2.0)
	
	for building in buildings_layer.get_children():
		if building == ghost_building: continue 
		
		if building.has_method("get_rect"):
			var other_rect = get_global_rect_of(building).grow(-2.0)
			
			if ghost_rect.intersects(other_rect):
				return false
				
	return true
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		var batiment_clique = get_building_under_mouse()
		
		if batiment_clique:
			var nom_a_envoyer = batiment_clique.name

			# On vérifie si une étiquette "type_batiment" a été collée sur le sprite
			if batiment_clique.has_meta("type_batiment"):
				nom_a_envoyer = batiment_clique.get_meta("type_batiment")
			
			print("Clic détecté sur : ", batiment_clique.name, " -> Envoi signal : ", nom_a_envoyer)
			Global.demande_ouverture_info.emit(nom_a_envoyer)

func get_building_under_mouse() -> Node2D:
	var mouse_pos = get_global_mouse_position()
	var enfants = buildings_layer.get_children()
	enfants.reverse() 
	
	for batiment in enfants:
		if get_global_rect_of(batiment).has_point(mouse_pos):
			return batiment
	return null

func get_global_rect_of(node: Node2D) -> Rect2:
	return node.get_global_transform() * node.get_rect()
