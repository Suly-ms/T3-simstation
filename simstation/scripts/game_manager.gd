# GameManager.gd
extends Node

var current_map: Node = null  # Changé de Node2D à Node
var zoom_cam: Vector2
var path_building: Node

func set_current_map(map: Node):  # Changé de Node2D à Node
	current_map = map

func get_current_map() -> Node:  # Changé de Node2D à Node
	return current_map
	
func set_current_zoom_cam(zoom_cam : Vector2):
	zoom_cam = zoom_cam

func get_zoom_cam() -> Vector2:
	return zoom_cam
	
