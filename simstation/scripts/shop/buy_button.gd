extends TextureButton

"""
# Resize
const BASE_RES = Vector2(1920, 1080)

func _ready():
	_resize()
	get_viewport().connect("size_changed", Callable(self, "_resize"))

func _resize():
	var screen_size = get_viewport_rect().size
	var scale_factor = min(
		screen_size.x / BASE_RES.x,
		screen_size.y / BASE_RES.y
	)
	self.scale = Vector2(scale_factor, scale_factor)

"""
# Ouverture d'une fenetre
const SHOP_SCENE = preload("res://scenes/buy_confirmation.tscn")

func _on_pressed() -> void:
	Global.batiment_en_cours_achat = get_parent().name
	
	# Verifie si il a les tales
	if (Global.argent - Global.batiments_prix[Global.batiment_en_cours_achat] >= 0):
		print("Bouton cliqué : ", get_parent().name)  # test pour vérifier que ça fonctionne
		# Instancie la scène
		var shop_instance = SHOP_SCENE.instantiate()

		# Ajoute la scène à l’arbre
		get_tree().current_scene.add_child(shop_instance)
	else :
		print("Vous n'avez pas les fonds nécessaires")
