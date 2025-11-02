extends Node

func are_overlaping(btn1 : TextureButton, btn2 : TextureButton) -> bool:
	var area1 = texture_to_area2d(btn1)
	var area2 = texture_to_area2d(btn2) 
	print("area 1: " + area1.to_string() + "\narea 2: " + area2.to_string())
	return areas_overlap(area1, area2)

func areas_overlap(area_a: Area2D, area_b: Area2D) -> bool:
	var overlapping_areas = area_a.get_overlapping_areas()
	print(overlapping_areas)
	return area_b in overlapping_areas


func texture_to_area2d(btn : TextureButton) -> Area2D:
	var area = Area2D.new()
	# Créer un Sprite2D pour afficher la texture du bouton
	var sprite = Sprite2D.new()
	sprite.texture = btn.texture_normal
	sprite.position = btn.position
	# Ajouter au Area2D
	area.add_child(sprite)

	return area
