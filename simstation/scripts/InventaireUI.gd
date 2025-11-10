extends Control

@onready var grid = $MarginContainer/GridContainer

func _ready():
	afficher_inventaire()
	# Écoute le signal global quand l’inventaire change
	Global.connect("batiment_changed", Callable(self, "_on_batiment_changed"))

func afficher_inventaire():
	for child in grid.get_children():
		child.queue_free()

	# Parcours de l’inventaire global
	for nom_batiment in Global.inventaire.keys():
		var quantite = Global.inventaire[nom_batiment]
		var bouton = creer_bouton_batiment(nom_batiment, quantite)
		if quantite == 0:
			bouton.disabled = true
			bouton.modulate = Color(0.5, 0.5, 0.5)
		grid.add_child(bouton)

func creer_bouton_batiment(nom_batiment: String, quantite: int) -> Button:
	var sprite2d = Sprite2D.new()

	var label_nb = Label.new()
	label_nb.name = "nombre"
	label_nb.text = str(quantite)
	label_nb.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label_nb.anchor_right = 1
	sprite2d.add_child(label_nb)

	if ResourceLoader.exists("res://assets/batiments/%s.png" % nom_batiment):
		sprite2d.texture = load("res://batiments/%s.png" % nom_batiment)

	sprite2d.pressed.connect(func():
		var scene = load("res://scripts/drag_building.gd")
		if scene:
			var drag = scene.instantiate()
			drag.name = nom_batiment
			get_tree().current_scene.add_child(drag)
		else:
			push_warning("Impossible de trouver la scène pour %s" % nom_batiment)
	)

	return sprite2d

func _on_batiment_changed(nom_batiment: String, new_value: int):
	afficher_inventaire()
