extends Sprite2D

var batiment_instance = null
var map = null
var dragging = false
@export var delay = 0.0001 # variable dictant l'animation de drag and drop
@export var speed_ap = 10 #vitesse de l'animation de automatic placement
var mouse_offset # pour centrer le drop au millieu de la sprite
var automatic_placement = false
var global_vector : Vector2 = Vector2(1,1)
var is_square = false
#on recupere la map actuelle
func _process(_delta):
	if map == null and GameManager.get_current_map():
		map = GameManager.get_current_map()

#permet au batiment de suivre le pointeur de la souris lorsqu'il est deplace
#et place automatiquement le batiement
func _physics_process(delta: float) -> void:
	if dragging:
		grid_placement(delta)
	else:
		automatic_placement = false
	if !dragging and  batiment_instance and is_square:
		map.delete_square()
		is_square = false


#detecte le clic de la souris et gere le drag
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_rect().has_point(to_local(event.position)):
				is_square = true
				map.show_square()
				var batiment = find_building_scene()
				batiment_instance = batiment.instantiate()
				add_building_map()
				dragging = true
				mouse_offset = Vector2(0,0)
				GridDrawer.enable_grid()
		elif dragging:
			GridDrawer.disable_grid()
			dragging = false


#fonction qui renvoie la position general du pointeur de la souris 
#sans prendre le zoom ou le deplacement de la camera
func get_world_mouse_position() -> Vector2:
	var camera = get_viewport().get_camera_2d()
	if camera:
		return camera.get_global_mouse_position()
	else:
		return get_global_mouse_position()


#fonction qui cherche le fichier contenant la scene du batiment selectione
func find_building_scene() -> Resource:
	if FileAccess.file_exists("res://batiments/"+ self.name +".tscn"):
		return load("res://batiments/"+ self.name +".tscn")
	else:
		return null


#fonction pour ajouter le batiment dans la map et le mettre dans le bon dossiers des batiments
func add_building_map():
	var folder_buildings = map.get_child(2)
	folder_buildings.add_child(batiment_instance)

#attendre les secondes en parametre
func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout
	
#gere quand le batiment est glisser sur la map il doit suivre l'aimentation de la grille
func grid_placement(delta) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(batiment_instance, "position",get_grid_point() , delay * delta)
 

 #fise un des coordonée sur la grille
func get_grid_point() -> Vector2:
	var new_point : Vector2
	new_point.x = int(get_world_mouse_position().x) - int(get_world_mouse_position().x) % GridDrawer.get_offset() 
	new_point.y = int(get_world_mouse_position().y) - int(get_world_mouse_position().y) % GridDrawer.get_offset() 
	return new_point
