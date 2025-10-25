extends Node2D

@export var rows := 100
@export var columns := 100
@export var line_width := 1.0
@export var offset := 100.0
@export var start_position := Vector2.ZERO
@export var line_color := Color.BLACK

func _ready() -> void:
	z_index = 1000
	visible = false
	queue_redraw()

func _draw():
	if not visible:
		return
	
	var half_width = columns * offset * 0.5
	var half_height = rows * offset * 0.5
	
	# Draw columns
	for i in range(columns + 1):
		var x = start_position.x - half_width + i * offset
		draw_line(Vector2(x, start_position.y - half_height),
				  Vector2(x, start_position.y + half_height),
				  line_color, line_width)
	
	# Draw rows
	for j in range(rows + 1):
		var y = start_position.y - half_height + j * offset
		draw_line(Vector2(start_position.x - half_width, y),
				  Vector2(start_position.x + half_width, y),
				  line_color, line_width )

func enable_grid():
	visible = true
	queue_redraw()

func disable_grid():
	visible = false
	queue_redraw()

func get_offset() -> float:
	return offset

func get_start_position() -> Vector2:
	return start_position
