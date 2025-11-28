# GameManager.gd
extends Node

var current_map: Node = null 
var zoom_cam: Vector2
var path_building: Node

func _ready() -> void:
	set_stats(CalculStats.calculer_stats())

func set_current_map(map: Node):
	current_map = map

func get_current_map() -> Node:
	return current_map
	
func set_current_zoom_cam(zoom_cam : Vector2):
	zoom_cam = zoom_cam

func get_zoom_cam() -> Vector2:
	return zoom_cam
	
func set_stats(stats):
	GlobalScript.set_stats(stats)
	
func add_batiment(nomBatiment, nombre):
	GlobalScript.add_batiment(nomBatiment, nombre)
	set_stats(CalculStats.calculer_stats())
