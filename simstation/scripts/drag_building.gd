extends Sprite2D

var batiment = preload("res://batiments/cafet.tscn")
var batiment_instance = null
var map
var dragging = false
var delay = .5 # variable dictant l'animation de drag and drop
var mouse_offset #pour centrer le drop au millieu de la sprite

func _process(_delta):
	if map == null and GameManager.get_current_map():
		map = GameManager.get_current_map()

func _physics_process(delta: float) -> void:
	if dragging:
		var tween = get_tree().create_tween()
		tween.tween_property(batiment_instance, "position",get_world_mouse_position() - mouse_offset , delay * delta)
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_rect().has_point(to_local(event.position)):
				batiment_instance = batiment.instantiate()
				map.add_child(batiment_instance)
				dragging = true
				mouse_offset = batiment_instance.global_position /2
		elif dragging:
			batiment_instance.position = get_world_mouse_position() - mouse_offset
			dragging = false
			
func get_world_mouse_position() -> Vector2:
	var camera = get_viewport().get_camera_2d()
	if camera:
		return camera.get_global_mouse_position()
	else:
		return get_global_mouse_position()
