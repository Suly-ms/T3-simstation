extends Sprite2D

func _update_bar(value: int):
	var ratio = value / 100.0
	region_enabled = true
	region_rect = Rect2(33.999, 45.353, ratio * 83.872, 54.51)

func _process(_delta):

	# match = switch/case de godot
	match name: # name c'est le nom du truc appelant
		"FilledBarHealth":
			_update_bar(Global.stats["sante"])
		"FilledBarEfficiency":
			_update_bar(Global.stats["efficacite"])
		"FilledBarHappiness":
			_update_bar(Global.stats["bonheur"])
		"FilledBarPollution":
			_update_bar(Global.stats["pollution"])
		_: # default
			print ("Erreur : Pas le bon appelant")
