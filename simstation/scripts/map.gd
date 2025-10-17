extends Node

@onready var node_buildings : Node = $buildings
@onready var node_decorations : Node = $decor

func _ready():
	GameManager.set_current_map(self)


'''func place_building(name : String, position : Vector2):
	var batiment = load("res://batiments/"+ self.name +".tscn")
	var batiment_instance = batiment.instantiate()
	node_buildings.add_child(batiment_instance)
	batiment_instance.position = position'''


#on parcour tous les enfant de node_building sauf le dernier qui est le batiment que l'on vient de placer
func is_placable(btn1 : TextureButton) -> Array:
	var children = node_buildings.get_children()
	for i in range(children.size() - 1): 
		var btn2 : TextureButton = children[i]
		if btn1.get_rect().intersects(btn2.get_rect()):
			var vector = get_vector(btn1, btn2)
			return [false, vector]
	return [true, Vector2(0,0)]

#retourne le vecteur de deplacement si les batiments se superpose
func get_vector(btn1 : TextureButton, btn2 : TextureButton):
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
func delete_square():
	var children = node_buildings.get_children()
	for btn in children: 
		if(btn.get_child(0)):
			btn.get_child(0).visible = false
