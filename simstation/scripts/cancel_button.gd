extends TextureButton

func _on_pressed() -> void:
	var node = self
	while node.get_parent() != get_tree().current_scene:
		node = node.get_parent()
	node.queue_free()  # ferme la popup
