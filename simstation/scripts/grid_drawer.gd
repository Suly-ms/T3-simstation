extends Node2D

var rows = 100
var collumns = 100
var width_line = 20
var offset = 300
var lenght_x = 10000
var lenght_y = 10000
var start_position = Vector2(-20000, -20000)

func _process(delta):
	#queue_redraw() # Demande à redessiner chaque frame
	pass

func _draw():
	
	#dessine les lignes et les collones 
	var center_y = Vector2(start_position.x, -lenght_y)
	var end_y = Vector2(start_position.x,lenght_y )
	for i in collumns:
		draw_line(center_y, end_y , Color.BLACK, 5)
		center_y += Vector2(offset,0)
		end_y += Vector2(offset,0)
		
	var center_x = Vector2(-lenght_x, start_position.x)
	var end_x = Vector2(lenght_x,start_position.x )
	for i in collumns:
		draw_line(center_x, end_x , Color.BLACK, 5)
		center_x += Vector2(0, offset)
		end_x += Vector2(0, offset)

func enable_grid():
	self.visible = true

func disable_grid():
	self.visible = false
	
func get_offset() -> int:
	return offset
	
func get_start_position() -> Vector2:
	return start_position
