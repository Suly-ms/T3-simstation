extends Control


func _on_btn_jouer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play.tscn")


func _on_btn_quitter_pressed() -> void:
	get_tree().quit()
