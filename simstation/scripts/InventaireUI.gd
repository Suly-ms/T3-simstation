extends Control

# DESCRIPTION :
# Script gérant l'affichage dynamique de l'inventaire des bâtiments dans l'interface (UI).
# Il peuple une grille (GridContainer) avec les items disponibles dans `Global.inventaire`, 
# affiche les quantités en temps réel et attribue dynamiquement le script de Drag & Drop aux icônes.
# Les fonctions disponibles sont :
# _ready() : Initialise l'interface et s'abonne au signal global pour détecter les changements de stock.
# afficher_inventaire : Vide la grille actuelle et régénère tous les boutons d'items.
# creer_bouton_batiment : Instancie un conteneur avec l'image et la quantité, gère la texture (grisée si stock vide) et attache le script `drag_building.gd`.
# _on_batiment_changed : Met à jour le texte de la quantité et la couleur de l'icône d'un bâtiment spécifique sans recharger toute la liste.

@onready var grid = $ScrollInventaire/MarginInventaire/GridInventaire

func _ready():
	await get_tree().process_frame
	afficher_inventaire()
	
	if Global.has_signal("batiment_changed"):
		Global.connect("batiment_changed", Callable(self, "_on_batiment_changed"))

func afficher_inventaire():
	for child in grid.get_children():
		child.queue_free()

	for nom_batiment in Global.inventaire.keys():
		var quantite = Global.inventaire[nom_batiment]
		var box = creer_bouton_batiment(nom_batiment, quantite)
		if box:
			grid.add_child(box)

func creer_bouton_batiment(nom_batiment: String, quantite: int) -> Control:
	var box = Control.new()
	box.custom_minimum_size = Vector2(100, 100)
	
	var icon = TextureRect.new()
	icon.name = nom_batiment
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var path_img = "res://assets/batiments/%s.png" % nom_batiment
	if ResourceLoader.exists(path_img):
		icon.texture = load(path_img)
		icon.modulate = Color(0.5, 0.5, 0.5) if quantite <= 0 else Color.WHITE
	else:
		icon.texture = PlaceholderTexture2D.new() 
		printerr("Image manquante pour : ", path_img)

	var drag_script = load("res://scripts/drag_building.gd") 
	icon.set_script(drag_script)

	var label = Label.new()
	label.name = "nombre"
	label.text = str(quantite)
	label.position = Vector2(5, 80)
	label.modulate = Color(0.0, 0.0, 0.0, 1.0)
	icon.add_child(label)
	
	box.add_child(icon)
	return box

func _on_batiment_changed(nom_batiment, new_val):
	for box in grid.get_children():
		var icon = box.get_child(0)
		if icon.name == nom_batiment:
			var lbl = icon.get_node("nombre")
			lbl.text = str(new_val)
			icon.modulate = Color(0.5, 0.5, 0.5) if new_val <= 0 else Color.WHITE
