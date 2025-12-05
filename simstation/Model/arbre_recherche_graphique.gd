extends Node2D

signal argent_changed(argent)

var tree: SearchTree
var node_positions = {}
var current_menu = null 

# Mise en page
const X_SPACING = 300 # Écarté pour les boutons larges
const Y_SPACING = 150
const NODE_RADIUS = 30
const TREE_SPACING = 800

var roots = []

var dernier_tour_connu = -1

# Références
@onready var scrollContainer = $background/ScrollContainer

# Canvas interne
var tree_canvas = Control.new()

func _ready():
	GlobalScript.connect("tour_change", _on_tour_changed)
		
	#set_process(false) # désactive _process, on économise du CPU !
	
	scrollContainer.add_child(tree_canvas)
	tree_canvas.draw.connect(_on_tree_canvas_draw)
	
	tree = SearchTree.new()

	var root_infra = tree.create_root("Générateurs Diesel", 1, 5000, 0, "Électricité de base.")
	var infra_2a = tree.add_child(root_infra, "Isolation Renforcée", 2, 25000, 10, "Protection -50°C.")
	var infra_3a = tree.add_child(infra_2a, "Dortoirs Modulaires", 3, 60000, 20, "Modules chauffés.")
	var infra_2b = tree.add_child(root_infra, "Garage à Chenilles", 2, 45000, 15, "Hangar véhicules.")
	var infra_3b = tree.add_child(infra_2b, "Rover d'Exploration", 4, 120000, 40, "Accès zones lointaines.")
	var infra_final = tree.add_child(infra_3a, "Centrale Géothermique", 12, 2500000, 100, "Énergie illimitée.")

	var root_science = tree.create_root("Labo de Terrain", 1, 10000, 0, "Le début de la recherche.")
	root_science.debloque = true
	var sci_2 = tree.add_child(root_science, "Forage Superficiel", 2, 35000, 10, "Carottes 0-50m.")
	var sci_3a = tree.add_child(sci_2, "Labo de Chimie", 3, 80000, 25, "Analyse bulles d'air.")
	var sci_4a = tree.add_child(sci_3a, "Données Climatiques", 4, 200000, 50, "Reconstitution climat.")
	var sci_3b = tree.add_child(sci_2, "Cryobiologie", 3, 90000, 30, "Bactéries dormantes.")
	var sci_4b = tree.add_child(sci_3b, "Séquençage ADN", 6, 500000, 80, "Nouvelles formes de vie.")
	var sci_final = tree.add_child(sci_4a, "Forage Profond (3km)", 20, 15000000, 200, "Le socle rocheux.")

	var root_comms = tree.create_root("Antenne Radio", 1, 8000, 0, "Lien radio basique.")
	root_comms.debloque = true
	var com_2 = tree.add_child(root_comms, "Lien Satellite", 1, 150000, 20, "Haut débit.")
	var com_3a = tree.add_child(com_2, "Reportage TV", 2, 500000, 30, "Droits TV.")
	var com_4a = tree.add_child(com_3a, "Sponsoring Privé", 4, 2000000, 60, "Contrat Red Bull.")
	var com_3b = tree.add_child(com_2, "Partenariat Univ.", 3, 400000, 40, "Fonds de recherche.")

	roots = [root_infra, root_science, root_comms]

	for r in roots:
		_update_tree_state_recursive(r)

	var start_x = 0
	for r in roots:
		_calculate_positions(r, Vector2(start_x, 0), 0)
		start_x += TREE_SPACING 

	_setup_scroll_area()
	
	for r in roots:
		_create_buttons_recursive(r)

func _on_tour_changed():
	_check_research_completion()

# Vérifie si des recherches en cours sont finies
func _check_research_completion():
	var current_turn = GlobalScript.get_tour()
	var changes_made = false
	
	# 1. Vérification des recherches terminées
	var recherches_names = GlobalScript.get_recherche_en_cours().keys()
	
	for nom_recherche in recherches_names:
		var tour_fin = GlobalScript.get_recherche_en_cours()[nom_recherche]
		
		if current_turn >= tour_fin:
			_complete_research(nom_recherche)
			changes_made = true
	
	# 2. Logique de Refresh optimisée
	# On refresh SI une recherche est finie OU SI le tour a changé (pour mettre à jour les textes)
	if changes_made or current_turn != dernier_tour_connu:
		_refresh_ui()
		print("UI Mise à jour. Tour : ", current_turn)
		
		# TRES IMPORTANT : On met à jour la mémoire pour ne pas refresh à la frame suivante !
		dernier_tour_connu = current_turn

func _complete_research(nom_recherche: String):
	print("Recherche terminée : ", nom_recherche)
	
	var node = null
	
	for root_node in roots:
		node = _find_node_by_name(root_node, nom_recherche)
		if node != null:
			break # On a trouvé le bon noeud, on arrête de chercher
	
	if node:
		# 2. Appliquer les gains
		GlobalScript.modifier_argent(GlobalScript.get_argent() + node.money)
		node.debloque = true
	
	# 3. Mettre à jour Global
	GlobalScript.add_recherche_debloque(nom_recherche)
	GlobalScript.erase_recherche_en_cours(nom_recherche)

# Fonction helper pour retrouver un noeud par son nom
func _find_node_by_name(node, name_to_find):
	if node.nom == name_to_find: return node
	for child in node.children:
		var res = _find_node_by_name(child, name_to_find)
		if res: return res
	return null

# Met à jour l'état local (debloque/pas debloque) en fonction du Global au démarrage
func _update_tree_state_recursive(node):
	if node == null: return
	
	# Est-ce que c'est déjà fini ?
	if node.nom in GlobalScript.get_recherche_debloque():
		node.debloque = true
	else:
		node.debloque = false
		
	for child in node.children:
		_update_tree_state_recursive(child)

# --- LOGIQUE D'INTERFACE ---

func _create_buttons_recursive(node: SearchTree.NodeData):
	if node == null: return
	
	var pos = node_positions[node]
	var btn = TextureButton.new() 
	var texte = Label.new()
	var margin_container = MarginContainer.new()
	
	var texture_path_normal = "res://assets/arbre_recherche/bouton_recherche.png"
	var texture_img_normal = load(texture_path_normal)
	
	var texture_path_hover = "res://assets/arbre_recherche/bouton_recherche_hover.png"
	var texture_img_hover = load(texture_path_hover)
	
	var texture_path_clic = "res://assets/arbre_recherche/bouton_recherche_clic.png"
	var texture_img_clic = load(texture_path_clic)
	
	var font_path_normal = "res://font/Minecraftia-Regular.ttf"
	var font_normal = load(font_path_normal)
	
	texte.text = str(node.nom)
	texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texte.set_anchors_preset(Control.PRESET_FULL_RECT)
	texte.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texte.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texte.add_theme_color_override("font_color", Color.WHITE)
	texte.add_theme_font_override("font", font_normal)
	texte.add_theme_font_size_override("font_size", 14)
	texte.add_theme_constant_override("outline_size", 10)
	texte.add_theme_color_override("font_outline_color", Color.BLACK)
	
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var button_size = Vector2(150, 70)
	
	btn.texture_normal = texture_img_normal
	btn.texture_hover = texture_img_hover
	btn.texture_pressed = texture_img_clic
	
	btn.custom_minimum_size = button_size
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_SCALE
	btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	btn.set_size(button_size)
	
	btn.set_position(pos - button_size / 2) 
	
	margin_container.add_child(texte)
	btn.add_child(margin_container)
	tree_canvas.add_child(btn)
	# --- LOGIQUE ETAT DU BOUTON ---
	
	# Cas 1 : Recherche en cours
	if node.nom in GlobalScript.get_recherche_en_cours():
		btn.disabled = true
		btn.modulate = Color(1.0, 0.569, 0.0, 0.553) # JAUNE = En cours
		dernier_tour_connu = GlobalScript.get_recherche_en_cours()[node.nom] - GlobalScript.get_tour()
		texte.text += "\n(" + str(dernier_tour_connu) + " tours)"
		
	# Cas 2 : Parent non débloqué (Grisé)
	elif node.parent and not node.parent.debloque:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5) # GRIS
		
	# Cas 3 : Déjà acheté (Vert)
	elif node.debloque:
		btn.disabled = false # On laisse actif pour pouvoir relire la description
		btn.modulate = Color(0.0, 1.0, 0.0, 0.745) # VERT
		btn.pressed.connect(func(): ajouter_retirer_menu_node(btn.position + Vector2(0, btn.size.y), node))
		
	# Cas 4 : Disponible à l'achat (Bleu/Blanc)
	else:
		btn.disabled = false
		btn.modulate = Color(1, 1, 1) # NORMAL
		btn.pressed.connect(func(): ajouter_retirer_menu_node(btn.position + Vector2(0, btn.size.y), node))
	
	for child in node.children:
		_create_buttons_recursive(child)

func ajouter_retirer_menu_node(pos: Vector2, node: SearchTree.NodeData):
	if current_menu: current_menu.queue_free()
	
	var menu = Panel.new()
	var nom = RichTextLabel.new()
	var bouton_recherche = Button.new()
	
	nom.bbcode_enabled = true
	menu.set_size(Vector2(300, 145))
	tree_canvas.add_child(menu) 
	menu.set_position(pos)
	
	nom.size = Vector2(280, 100)
	nom.position = Vector2(10, 10)
	
	if node.debloque:
		nom.text = "[b]" + node.nom + "[/b]\n" + node.description + "\n[color=green]RECHERCHE TERMINÉE[/color]"
	else:
		# Bouton Lancer Recherche
		bouton_recherche.text = "Lancer (" + str(node.tour) + " tours)"
		bouton_recherche.set_size(Vector2(280, 30))
		bouton_recherche.set_position(Vector2(10, 105))
		bouton_recherche.pressed.connect(func(): lancer_recherche(node))
		menu.add_child(bouton_recherche)
		
		nom.text = "[b]" + node.nom + "[/b]\n" + node.description + \
			"\n[b]Gain :[/b] " + str(node.money) + "$ " + \
			"\n[b]Durée :[/b] " + str(node.tour * 3) + " mois"
	
	menu.add_child(nom)
	current_menu = menu

func lancer_recherche(node):
	if current_menu: current_menu.queue_free()
	
	# Calcul du tour de fin
	var tour_actuel = GlobalScript.get_tour()
	var tour_fin = tour_actuel + node.tour
	
	# Enregistrement dans le Global
	GlobalScript.set_recherche_en_cours(node.nom, tour_fin)
	
	print("Recherche lancée : " + node.nom + ". Fin au tour " + str(tour_fin))
	
	# Mise à jour de l'interface
	_refresh_ui()

func _refresh_ui():
	# On supprime tout
	for child in tree_canvas.get_children():
		child.queue_free()
	
	# On attend que Godot nettoie la mémoire
	await get_tree().process_frame 
	
	# SECURITÉ : Si le joueur a fermé le menu pendant l'attente, on arrête tout
	if not is_inside_tree():
		return
	
	# On recrée
	for r in roots:
		_create_buttons_recursive(r)
		
	tree_canvas.queue_redraw()

# --- FONCTIONS MATHEMATIQUES INCHANGEES ---
func _calculate_positions(node, pos, depth):
	if node == null: return
	var x_offset = _get_subtree_width(node) * X_SPACING * -0.5
	node_positions[node] = Vector2(pos.x, depth * Y_SPACING)
	var child_x = pos.x + x_offset
	for child in node.children:
		node_positions[child] = Vector2(child_x, (depth + 1) * Y_SPACING)
		_calculate_positions(child, Vector2(child_x, (depth + 1) * Y_SPACING), depth + 1)
		child_x += _get_subtree_width(child) * X_SPACING

func _setup_scroll_area():
	var min_x = INF; var max_x = -INF; var min_y = INF; var max_y = -INF
	for pos in node_positions.values():
		min_x = min(min_x, pos.x); max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y); max_y = max(max_y, pos.y)
	var padding = Vector2(100, 100)
	var shift_vector = Vector2(-min_x, -min_y) + padding
	for node in node_positions.keys(): node_positions[node] += shift_vector
	tree_canvas.custom_minimum_size = Vector2((max_x - min_x) + padding.x * 2, (max_y - min_y) + padding.y * 2)
	tree_canvas.queue_redraw()

func _get_subtree_width(node) -> int:
	if node.children.size() == 0: return 1
	var width = 0
	for child in node.children: width += _get_subtree_width(child)
	return width

func _on_tree_canvas_draw():
	if tree == null or tree.root == null: return
	for root in roots:
		_draw_lines_recursive(root)

func _draw_lines_recursive(node):
	if node == null: return
	var pos = node_positions[node]
	for child in node.children:
		var child_pos = node_positions[child]
		tree_canvas.draw_line(pos + Vector2(0, NODE_RADIUS), child_pos - Vector2(0, NODE_RADIUS), Color(0.6, 0.6, 0.6), 2)
		_draw_lines_recursive(child)

func _on_exit_button_pressed() -> void:
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")
	if hud.has_node("ArbreRecherche"):
		hud.get_node("ArbreRecherche").visible = false
		GlobalScript.set_camera(!GlobalScript.get_camera())
