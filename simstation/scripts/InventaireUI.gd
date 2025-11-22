extends Control

@onready var grid = $ScrollInventaire/MarginInventaire/GridInventaire

func _ready():
	# Attendre que Global soit prêt
	await get_tree().process_frame
	afficher_inventaire()
	
	# Connexion au signal global (assure-toi que ce signal existe dans Global.gd)
	if Global.has_signal("batiment_changed"):
		Global.connect("batiment_changed", Callable(self, "_on_batiment_changed"))

func afficher_inventaire():
	# Nettoyage
	for child in grid.get_children():
		child.queue_free()

	for nom_batiment in Global.inventaire.keys():
		var quantite = Global.inventaire[nom_batiment]
		var box = creer_bouton_batiment(nom_batiment, quantite)
		if box:
			grid.add_child(box)

func creer_bouton_batiment(nom_batiment: String, quantite: int) -> Control:
	# 1. Conteneur
	var box = Control.new()
	box.custom_minimum_size = Vector2(100, 100) # Taille de la case
	
	# 2. Icône / Bouton interaction
	var icon = TextureRect.new()
	icon.name = nom_batiment # IMPORTANT : le script drag se base sur ce nom
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Chargement de l'image PNG
	var path_img = "res://assets/batiments/%s.png" % nom_batiment
	if ResourceLoader.exists(path_img):
		icon.texture = load(path_img)
		icon.modulate = Color(0.5, 0.5, 0.5) if quantite <= 0 else Color.WHITE
	else:
		# Image par défaut si pas trouvée (pour éviter le crash)
		icon.texture = PlaceholderTexture2D.new() 
		printerr("Image manquante pour : ", path_img)

	# 3. Attacher le script de DRAG
	# Assure-toi que le chemin est bon
	var drag_script = load("res://scripts/drag_building.gd") 
	icon.set_script(drag_script)
	
	# Paramètres du script (si besoin de changer la grille par script)
	# icon.grid_size = 128 

	# 4. Label quantité
	var label = Label.new()
	label.name = "nombre"
	label.text = str(quantite)
	label.position = Vector2(5, 80) # En bas à gauche
	label.modulate = Color(0.0, 0.0, 0.0, 1.0)
	icon.add_child(label)
	
	box.add_child(icon)
	return box

func _on_batiment_changed(nom_batiment, new_val):
	# Met à jour juste le label sans tout reconstruire
	for box in grid.get_children():
		var icon = box.get_child(0)
		if icon.name == nom_batiment:
			var lbl = icon.get_node("nombre")
			lbl.text = str(new_val)
			# Optionnel : Griser l'icône si quantité = 0
			icon.modulate = Color(0.5, 0.5, 0.5) if new_val <= 0 else Color.WHITE
