extends TextureRect

# --- PARAMÈTRES ---
@export var grid_size : int = 64 # Adapte à ta TileMap (souvent 32, 64 ou 128)

# --- VARIABLES ---
var batiment_instance : Node2D = null # Ce sera notre Sprite
var map_ref = null
var dragging : bool = false

func _ready():
	# Optionnel : changer le curseur quand on survole
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _get_drag_data(_at_position):
	# Fonction native de Godot pour le Drag&Drop UI, mais ici on fait un système custom
	# On retourne l'info pour bloquer le drag natif si besoin, ou on laisse vide.
	return null

func _gui_input(event):
	# Détection du clic gauche sur le bouton de l'inventaire
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# On vérifie s'il y a du stock
		if Global.inventaire.get(name, 0) > 0:
			start_dragging()
		else:
			print("Pas assez de ressources !")

func _input(event):
	# Gestion globale (quand on lâche la souris n'importe où)
	if dragging and batiment_instance:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				place_building() # Relâchement = Poser
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				cancel_placement() # Clic droit = Annuler

func _process(_delta):
	if dragging and batiment_instance and map_ref:
		# 1. Récupérer la position souris dans le monde (coordonnées Map)
		var mouse_global_pos = map_ref.get_global_mouse_position()
		
		# 2. Snapping (Aimantation à la grille)
		var snapped_pos = mouse_global_pos.snapped(Vector2(grid_size, grid_size))
		
		# 3. Appliquer la position
		batiment_instance.global_position = snapped_pos
		
		# 4. Feedback visuel (Rouge si occupé, Blanc si libre)
		update_visual_feedback()

func start_dragging():
	var maps = get_tree().get_nodes_in_group("Map")
	if maps.size() > 0:
		map_ref = maps[0]
	else:
		return

	# Création du Sprite (inchangé)
	batiment_instance = Sprite2D.new()
	batiment_instance.texture = texture
	batiment_instance.name = name
	
	# --- AJOUT DU CONTOUR GRIS ---
	var contour = ReferenceRect.new()
	contour.name = "ContourDeSelection" # On lui donne un nom pour le retrouver
	contour.editor_only = false # Important : par défaut c'est visible que dans l'éditeur
	contour.border_color = Color.GRAY # Couleur grise
	contour.border_width = 2.0 # Épaisseur du trait
	contour.mouse_filter = Control.MOUSE_FILTER_IGNORE # Très important : pour ne pas bloquer les clics !
	
	# On adapte la taille à l'image
	contour.custom_minimum_size = texture.get_size()
	contour.size = texture.get_size()
	# On centre le rectangle (car le Sprite est centré par défaut, mais pas le Rect)
	contour.position = -texture.get_size() / 2
	
	batiment_instance.add_child(contour)
	# -----------------------------

	map_ref.add_temp_building(batiment_instance)
	
	dragging = true
	Global.modifier_batiment(name, -1)

func place_building():
	if not batiment_instance: return
	
	if map_ref.is_placable(batiment_instance):
		# SUCCÈS
		batiment_instance.modulate = Color(1, 1, 1, 1)
		
		# --- AJOUT : SUPPRESSION DU CONTOUR ---
		var contour = batiment_instance.get_node_or_null("ContourDeSelection")
		if contour:
			contour.queue_free() # On détruit juste le cadre gris
		# --------------------------------------
		
		map_ref.validate_building(batiment_instance)
		
		batiment_instance = null
		dragging = false
	else:
		cancel_placement()

func cancel_placement():
	if batiment_instance:
		batiment_instance.queue_free() # On détruit le sprite
		batiment_instance = null
		Global.modifier_batiment(name, 1) # On rend la ressource
	dragging = false

func update_visual_feedback():
	if map_ref.is_placable(batiment_instance):
		batiment_instance.modulate = Color(1, 1, 1, 0.7) # Transparent normal
	else:
		batiment_instance.modulate = Color(1, 0.2, 0.2, 0.7) # Rouge transparent
