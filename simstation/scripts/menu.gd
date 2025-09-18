extends Control


func _on_quitter_pressed() -> void:
	get_tree().quit()


func _on_jouer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/play.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
