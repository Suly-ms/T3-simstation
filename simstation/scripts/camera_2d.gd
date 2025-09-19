extends Camera2D

@export var speed := 400.0

func _ready():
	pass

func _process(delta):
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	position += direction.normalized() * speed * delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		if($menu.is_visible_in_tree()):
			$menu.visible = false;
		else:
			$menu.visible = true;
	
