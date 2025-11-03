extends Camera2D

# --- Config Zoom ---
@export var zoom_step: float = 0.1
@export var min_zoom: Vector2 = Vector2(0.1, 0.1)
@export var max_zoom: Vector2 = Vector2(5, 5)

# --- Variables Drag ---
var dragging: bool = false
var last_mouse_pos: Vector2 = Vector2.ZERO
var current_mouse_pos: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	GameManager.set_current_zoom_cam(zoom)


func _unhandled_input(event: InputEvent) -> void:
	
	if Global.camera_enable : # desactivation possible (notemment quand on ouvre la boutique)
		# --- ZOOM ---
		var old_zoom: Vector2 = zoom
		var mouse_pos: Vector2 = get_global_mouse_position()

		if event is InputEventMouseButton:
			# Molette vers le haut → zoom avant
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				zoom += Vector2(zoom_step*zoom.x, zoom_step*zoom.y)
			# Molette vers le bas → zoom arrière
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				zoom -= Vector2(zoom_step*zoom.x, zoom_step*zoom.y)

			# Clic gauche → activer/désactiver drag
			elif event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					dragging = true
					last_mouse_pos = get_viewport().get_mouse_position() 
				else:
					dragging = false
					last_mouse_pos = Vector2.ZERO
					current_mouse_pos = Vector2.ZERO

		# --- DÉPLACEMENT PAR DRAG ---
		elif event is InputEventMouseMotion and dragging:
			current_mouse_pos = get_viewport().get_mouse_position()
			var delta: Vector2 = current_mouse_pos - last_mouse_pos
			position -= delta / zoom   # tenir compte du niveau de zoom
			last_mouse_pos = current_mouse_pos

		# Clamp du zoom
		zoom = zoom.clamp(min_zoom, max_zoom)

		# Ajuster la position pour garder le point sous la souris
		position += (mouse_pos - position) - (mouse_pos - position) * (old_zoom / zoom)
