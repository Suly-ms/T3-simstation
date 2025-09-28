extends Sprite2D

@export_range(0, 100, 1) var percent: float = 100.0 : set = set_percent

func _ready():
	region_enabled = true
	set_percent(percent)

func set_percent(value: float) -> void:
	percent = clamp(value, 0.0, 100.0)
	if texture:
		var tex_size = texture.get_size()
		var new_width = int(tex_size.x * (percent / 100.0))
		region_rect = Rect2(Vector2.ZERO, Vector2(new_width, tex_size.y))
