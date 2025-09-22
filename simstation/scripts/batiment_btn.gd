extends Node

func _ready():
	connect("pressed", Callable(self, "_on_pressed"))
	if self.texture_normal:
		var img = self.texture_normal.get_image()
		var mask = BitMap.new()
		mask.create_from_image_alpha(img, 0.5) # seuil entre 0.0 et 1.0
		self.texture_click_mask = mask

func _on_pressed() -> void:
	print(self.name)

func _on_mouse_entered() -> void:
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	pass
