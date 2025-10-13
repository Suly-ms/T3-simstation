extends Control

var rng := RandomNumberGenerator.new()

func _on_starter_pack_1_pressed() -> void:
	var batiments_nombre = {
		"dortoir": 2, 
		"cantine": 1, 
		"labo_recherche": 2, 
		"salle_sport": 1, 
		"salle_repos": 1, 
		"panneaux solaires": 3,
	}
	var argent = 2000000
	var population = 5
	change_scene_to_play(batiments_nombre, argent, population)

func change_scene_to_play(batiments_nombre, argent, population) :
	Global.batiments_nombre = batiments_nombre
	var population_list = []
	for i in range(population) :
		population_list.append({"sante": rng.randi_range(20, 100), "efficacite": rng.randi_range(20, 100), "bonheur": rng.randi_range(20, 100)})
	Global.population = population_list
	Global.stats["argent"] = argent
	get_tree().change_scene_to_file("res://scenes/play.tscn")


func _on_starter_pack_2_pressed() -> void:
	var batiments_nombre = {
		"dortoir": 4, 
		"cantine": 1, 
		"labo_recherche": 2, 
		"salle_repos": 2, 
		"panneaux solaires": 4,
	}
	var argent = 2000000
	var population = 4
	change_scene_to_play(batiments_nombre, argent, population)


func _on_starter_pack_3_pressed() -> void:
	var batiments_nombre = {
		"dortoir": 2, 
		"cantine": 1, 
		"labo_recherche": 2, 
		"salle_sport": 1, 
		"salle_repos": 1, 
		"generateur_petrole": 2,
	}
	var argent = 2000000
	var population = 3
	change_scene_to_play(batiments_nombre, argent, population)
