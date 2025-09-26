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
func is_placable(rect: Rect2) -> bool:
	var children = node_buildings.get_children()
	for i in range(children.size() - 1): 
		var node = children[i]
		if rect.intersects(node.get_rect()):
			return false
	return true

		
