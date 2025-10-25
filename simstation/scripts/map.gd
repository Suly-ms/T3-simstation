extends Node

@onready var node_buildings : Node = $buildings
@onready var node_decorations : Node = $decor
@onready var folder_buildings = $buildings

func _ready():
	GameManager.set_current_map(self)
	automatic_shadow()


#on parcour tous les enfant de node_building sauf le dernier qui est le batiment que l'on vient de placer
func is_placable(btn1 : Sprite2D) -> bool:
	var children = node_buildings.get_children()
	for i in range(children.size() - 1): 
		var btn2 : TextureButton = children[i]
		if btn1.get_rect().intersects(btn2.get_rect()):
			return false
	return true

#retourne le vecteur de deplacement si les batiments se superpose
func get_vector(btn1 : Node2D, btn2 : Node2D):
	var center1 = btn1.get_rect().get_center()
	var center2 = btn2.get_rect().get_center()
	var vector = Vector2(center2.x - center1.x, center2.y - center1.y)
	vector /= 100
	return vector
	
#affiche pour tout les batiments les  carré deffinissant leurs zones placable
func show_square():
	var children = node_buildings.get_children()
	for btn in children:
		if(btn.get_child(0)):
			btn.get_child(0).visible = true


#supprime l'affichage pour tout les batiments les carré deffinissant leurs zones placable
func remove_square():
	var children = node_buildings.get_children()
	for btn in children: 
		if(btn.get_child(0)):
			btn.get_child(0).visible = false


#ajoute un batiment au jeu en spécifiant le type de batiment
func add_building(type_batiment : String) -> Node:
	var batiment_scene = find_building_scene(type_batiment)
	if batiment_scene == null:
		push_error("Impossible de trouver la scène pour le bâtiment : %s" % type_batiment)
		return null
	
	var batiment_instance = batiment_scene.instantiate() # <- on instancie la PackedScene
	folder_buildings.add_child(batiment_instance)        # <- on ajoute le Node instancié
	return batiment_instance
	
#fonction qui cherche le fichier contenant la scene du batiment selectione
func find_building_scene(type_batiment) -> Resource:
	if FileAccess.file_exists("res://batiments/"+ type_batiment +".tscn"):
		return load("res://batiments/"+ type_batiment +".tscn")
	else:
		return null


#fonction qui retire le dernier batiment posé donc le premier dans folder_buidings
func remove_last_building():
	if(folder_buildings.get_child(-1)):
		folder_buildings.remove_child(folder_buildings.get_child(-1))
		
		
func automatic_shadow():
	
	
