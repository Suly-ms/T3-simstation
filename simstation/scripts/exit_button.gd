extends TextureButton


func _on_pressed() -> void:
	var shop = get_tree().current_scene.get_node("Shop")
	shop.get_node("CanvasLayer/background").visible = false
