extends Node
@onready var square = self.get_child(0)

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	if self.texture_normal:
		self.size = self.texture_normal.get_size()
		var img = self.texture_normal.get_image()
		var mask = BitMap.new()
		mask.create_from_image_alpha(img, 0.5) # seuil entre 0.0 et 1.0
		self.texture_click_mask = mask
	if square:
		#square.size = Vector2(GridDrawer.get_offset() , GridDrawer.get_offset() )
		self.position = Vector2(0,0)
		#square.position = Vector2(0,0)


func _on_pressed() -> void:
	print(self.name)

func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	pass
	
func get_size_building():
	return self.size

func get_size_square():
	return square.size

func get_center_square():
	var center : Vector2
	center.x = square.size.x / 2
	center.y = square.size.y / 2
	return center
	
func get_center_building():
	var center : Vector2
	center.x = self.size.x / 2
	center.y = self.size.y / 2
	return center
	
func set_position(position):
	self.position = position
