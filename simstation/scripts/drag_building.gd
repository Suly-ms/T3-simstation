extends TextureRect

var batiment_instance = null
var map = null
var dragging = false
@export var delay = 0.0001
@export var speed_ap = 10
var mouse_offset : Vector2 = Vector2.ZERO
var automatic_placement = false
var global_vector : Vector2 = Vector2(1,1)
var is_square = false

func _process(_delta):
	if map == null:
		map = GameManager.get_current_map()

func _physics_process(delta: float) -> void:
	if dragging and batiment_instance:
		var tween = get_tree().create_tween()
		tween.tween_property(batiment_instance, "position", get_world_mouse_position() - mouse_offset, delay * delta)

	if automatic_placement and batiment_instance and !map.is_placable(batiment_instance)[0]:
		global_vector = (map.is_placable(batiment_instance)[1] + global_vector) / 2
		var tween = get_tree().create_tween()
		tween.tween_property(batiment_instance, "position", batiment_instance.position - global_vector * Vector2(speed_ap, speed_ap), delay * delta)
	else:
		automatic_placement = false

	if not dragging and batiment_instance and is_square:
		map.delete_square()
		is_square = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_rect().has_point(get_local_mouse_position()):
			var nom_batiment = name
			if Global.inventaire[nom_batiment] > 0:
				is_square = true
				map.show_square()

				var batiment = find_building_scene()
				if batiment:
					batiment_instance = batiment.instantiate()
					add_building_map()
					dragging = true
					mouse_offset = Vector2.ZERO

					Global.modifier_batiment(nom_batiment, -1)
			else:
				print("Aucun ", nom_batiment, " disponible dans l'inventaire.")

		elif dragging:
			dragging = false
			place_building()

func get_world_mouse_position() -> Vector2:
	var camera = get_viewport().get_camera_2d()
	if camera:
		return camera.get_global_mouse_position()
	else:
		return get_global_mouse_position()

func find_building_scene() -> Resource:
	var path = "res://batiments/%s.tscn" % name
	if FileAccess.file_exists(path):
		return load(path)
	return null

func place_building():
	if map.is_placable(batiment_instance)[0]:
		batiment_instance.position = get_world_mouse_position() - mouse_offset
	else:
		automatic_placement = true

func add_building_map():
	if map and map.get_child_count() >= 3:
		var folder_buildings = map.get_child(2)
		folder_buildings.add_child(batiment_instance)
