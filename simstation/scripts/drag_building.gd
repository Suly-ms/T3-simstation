extends Sprite2D

var batiment_instance = null
var map = null
var dragging = false
@export var delay = 0.0001 # variable dictant l'animation de drag and drop
@export var speed_ap = 10 #vitesse de l'animation de automatic placement
var mouse_offset # pour centrer le drop au millieu de la sprite
var global_vector : Vector2 = Vector2(1,1)
var is_square = false


#on recupere la map actuelle
func _process(_delta):
	if map == null and GameManager.get_current_map():
		map = GameManager.get_current_map()

#place automatiquement le batiement
func _physics_process(delta: float) -> void:
	if dragging:
		grid_placement(delta)
	if !dragging and  batiment_instance and is_square:
		map.remove_square()
		GridDrawer.disable_grid()
		is_square = false
		if !map.is_placable(self):
			map.remove_last_building()


#detecte le clic de la souris et gere le drag
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print(get_world_mouse_position())
			if get_rect().has_point(to_local(event.position)):
				is_square = true
				map.show_square()
				GridDrawer.enable_grid()
				add_building_map()
				dragging = true
				mouse_offset = Vector2(0,0)
		elif dragging:
			dragging = false


#fonction qui renvoie la position general du pointeur de la souris 
#sans prendre le zoom ou le deplacement de la camera
func get_world_mouse_position() -> Vector2:
	var camera = get_viewport().get_camera_2d()
	if camera:
		return camera.get_global_mouse_position()
	else:
		return get_global_mouse_position()

#fonction pour ajouter le batiment dans la map et le mettre dans le bon dossiers des batiments
func add_building_map():
	batiment_instance = map.add_building(self.name)

#gere quand le batiment est glisser sur la map
func grid_placement(delta) -> void:
	batiment_instance.set_position(get_grid_point())
	
 

 #fixe un des coordonée sur la grille
func get_grid_point() -> Vector2:
	var offset = GridDrawer.get_offset()
	var start_pos = GridDrawer.get_start_position()
	
	var mouse = get_world_mouse_position()
	var new_point = Vector2()

	new_point.x = start_pos.x + int((mouse.x - start_pos.x) / offset) * offset
	new_point.y = start_pos.y + int((mouse.y - start_pos.y) / offset) * offset

	return new_point
