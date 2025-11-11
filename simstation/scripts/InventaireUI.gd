extends Control

@onready var grid = $ScrollInventaire/MarginInventaire/GridInventaire

func _ready():
	afficher_inventaire()
	Global.connect("batiment_changed", Callable(self, "_on_batiment_changed"))

func afficher_inventaire():
	for child in grid.get_children():
		child.queue_free()

	for nom_batiment in Global.inventaire.keys():
		var quantite = Global.inventaire[nom_batiment]
		var box = creer_bouton_batiment(nom_batiment, quantite)

		var icon = box.get_node(nom_batiment)
		if quantite == 0:
			if ResourceLoader.exists("res://assets/batiments/%s.png" % nom_batiment):
				icon.texture = load("res://assets/batiments/%s.png" % nom_batiment)

			var voile = ColorRect.new()
			voile.color = Color(0, 0, 0, 0.5)
			voile.anchor_left = 0
			voile.anchor_top = 0
			voile.anchor_right = 1
			voile.anchor_bottom = 1
			voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.add_child(voile)
		grid.add_child(box)

func creer_bouton_batiment(nom_batiment: String, quantite: int) -> Control:
	var box = Control.new()
	box.custom_minimum_size = Vector2(128,128)

	var icon = TextureRect.new()
	icon.name = nom_batiment
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
	icon.size_flags_vertical = Control.SIZE_FILL | Control.SIZE_EXPAND

	if ResourceLoader.exists("res://assets/batiments/%s.png" % nom_batiment):
		icon.texture = load("res://assets/batiments/%s.png" % nom_batiment)

	# drag script sur l’icône
	var drag_script = load("res://scripts/drag_building.gd")
	icon.set_script(drag_script)

	# Label quantité
	var label_nb = Label.new()
	label_nb.name = "nombre"
	label_nb.text = str(quantite)
	label_nb.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label_nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_nb.anchor_right = 1
	icon.add_child(label_nb)

	box.add_child(icon)
	return box
	
func _on_batiment_changed(nom_batiment: String, new_value: int):
	# Trouver le bouton correspondant
	for box in grid.get_children():
		var icon = box.get_node_or_null(nom_batiment)
		if icon:
			# Mettre à jour le label
			var label = icon.get_node_or_null("nombre")
			if label:
				label.text = str(new_value)
			
			# Ajouter ou enlever le voile gris
			var voile = icon.get_node_or_null("voile")
			if new_value <= 0:
				if voile == null:
					voile = ColorRect.new()
					voile.name = "voile"
					voile.color = Color(0,0,0,0.5)
					voile.anchor_left = 0
					voile.anchor_top = 0
					voile.anchor_right = 1
					voile.anchor_bottom = 1
					voile.mouse_filter = Control.MOUSE_FILTER_IGNORE
					icon.add_child(voile)
			else:
				if voile:
					voile.queue_free()
			break
