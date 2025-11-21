extends Node2D

# Assure-toi que ce chemin pointe bien vers le nœud parent de tes bâtiments
@onready var buildings_layer = $Batiments 

func _ready():
	add_to_group("Map")

# Ajoute le bâtiment temporairement
func add_temp_building(node: Node2D):
	buildings_layer.add_child(node)

# Valide le placement
func validate_building(node: Node2D):
	print("Bâtiment placé : ", node.name)
	# Ici, tu pourras ajouter la sauvegarde

func is_placable(ghost_building: Node2D) -> bool:
	# 1. On calcule le rectangle global du fantôme via notre fonction helper
	var ghost_rect = get_global_rect_of(ghost_building).grow(-2.0)
	
	for building in buildings_layer.get_children():
		if building == ghost_building: continue 
		
		# On vérifie si l'objet est un Sprite ou un truc qui a une texture
		if building.has_method("get_rect"):
			var other_rect = get_global_rect_of(building).grow(-2.0)
			
			if ghost_rect.intersects(other_rect):
				return false # Collision !
				
	return true
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		var batiment_clique = get_building_under_mouse()
		
		if batiment_clique:
			# ON EMET LE SIGNAL VIA GLOBAL
			print("Clic détecté, envoi du signal pour : ", batiment_clique.name)
			Global.demande_ouverture_info.emit(batiment_clique.name)

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
