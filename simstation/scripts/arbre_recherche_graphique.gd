extends Node2D

# DESCRIPTION :
# Script gérant l'affichage visuel et les interactions de l'interface d'arbre de recherche (UI).
# Il initialise une instance de SearchTree, définit la structure des recherches (parents/enfants),
# et gère le rendu graphique (lignes de connexion, boutons) ainsi que la logique de gameplay (temps de recherche, coûts).
# Les variables principales sont `tree` (la logique de données), `node_positions` (coordonnées visuelles) et `timer` (gestion du temps).
# Les fonctions disponibles sont :
# _ready() : Initialise l'arbre, crée les nœuds de recherche spécifiques et lance le calcul des positions.
# _process(_delta) : Met à jour l'affichage du temps restant lors d'une recherche active.
# _calculate_positions, _center_tree, _get_subtree_width : Algorithmes pour placer les nœuds visuellement de manière centrée et hiérarchique.
# _draw et _draw_node_recursive : Dessinent les lignes de connexion et instancient les boutons interactifs pour chaque nœud.
# ajouter_retirer_menu_node : Affiche un panneau contextuel avec la description et le bouton "Rechercher" lors du clic sur un nœud.
# faire_recherche : Lance le timer, débloque la recherche à la fin, met à jour l'argent global et rafraîchit l'affichage.
# _on_exit_button_pressed : Gère la fermeture de l'interface de l'arbre de recherche.

signal argent_changed(argent)

var tree: SearchTree
var node_positions = {}
var current_menu = null 

const X_SPACING = 300
const Y_SPACING = 100
const NODE_RADIUS = 15

var timer = Timer.new()
@onready var timer_label = $background/time_recherche
@onready var scrollContainer = $background/ScrollContainer
@onready var tree_canvas = $background/ScrollContainer/tree_canvas

func _ready():
	tree_canvas.draw.connect(_on_tree_canvas_draw)
	
	tree = SearchTree.new()
	# (Nom, Temps, Argent gagné, Description)
	var root = tree.create_root("Déploiement Base", 5, 15000, "Atterrissage et installation du module de survie temporaire.")

	# ==========================================
	# BRANCHE 1 : INFRASTRUCTURE & SURVIE (Gauche)
	# ==========================================
	# Les infrastructures coûtent cher mais assurent la survie
	var infra_1 = tree.add_child(root, "Générateurs Diesel", 10, 5000, "Mettre en place l'alimentation électrique d'urgence.")
	
	var infra_2a = tree.add_child(infra_1, "Isolation Renforcée", 15, 25000, "Améliorer les murs contre les vents catabatiques (-50°C).")
	var infra_3a = tree.add_child(infra_2a, "Dortoirs Modulaires", 20, 60000, "Remplacer les tentes par des modules chauffés permanents.")
	
	var infra_2b = tree.add_child(infra_1, "Garage à Chenilles", 25, 45000, "Construction d'un hangar pour protéger les véhicules du gel.")
	var infra_3b = tree.add_child(infra_2b, "Rover d'Exploration", 35, 120000, "Débloque l'accès aux zones éloignées pour de nouveaux forages.")
	
	# Jackpot énergétique
	var infra_final = tree.add_child(infra_3a, "Centrale Géothermique", 60, 2500000, "Source d'énergie illimitée : Budget énergétique excédentaire revendu.")

	# ==========================================
	# BRANCHE 2 : SCIENCE & FORAGE (Centre - Cœur du jeu)
	# ==========================================
	# La science rapporte progressivement, avec un énorme gain final
	var sci_1 = tree.add_child(root, "Sondage Radar", 12, 10000, "Scanner l'épaisseur de la glace pour trouver le site idéal.")
	
	var sci_2 = tree.add_child(sci_1, "Forage Superficiel", 15, 35000, "Extraire les premières carottes de glace (0-50m).")
	
	var sci_3a = tree.add_child(sci_2, "Labo de Chimie", 20, 80000, "Analyser la composition des bulles d'air emprisonnées.")
	var sci_4a = tree.add_child(sci_3a, "Données Climatiques", 30, 200000, "Reconstituer le climat d'il y a 10 000 ans.")
	
	var sci_3b = tree.add_child(sci_2, "Cryobiologie", 25, 90000, "Chercher des traces de bactéries dormantes dans la glace.")
	var sci_4b = tree.add_child(sci_3b, "Séquençage ADN", 40, 500000, "Identifier de nouvelles formes de vie. Brevets pharmaceutiques.")
	
	# Le Saint Graal (15 Millions)
	var sci_final = tree.add_child(sci_4a, "Forage Profond (3km)", 80, 15000000, "Atteindre le socle rocheux. Découverte historique majeure.")

	# ==========================================
	# BRANCHE 3 : COMMS & FINANCEMENT (Droite)
	# ==========================================
	# Cette branche est faite pour gagner de l'argent pur (Subventions)
	var com_1 = tree.add_child(root, "Antenne Satellite", 8, 8000, "Rétablir le lien haut débit avec le continent.")
	
	var com_2 = tree.add_child(com_1, "Demande de Subvention", 5, 150000, "Dossiers validés par l'ONU : Injection de fonds immédiate.")
	
	var com_3a = tree.add_child(com_2, "Reportage TV", 15, 500000, "Droits de diffusion exclusifs vendus à une chaîne internationale.")
	var com_4a = tree.add_child(com_3a, "Sponsoring Privé", 10, 2000000, "Contrat avec Red Bull et North Face pour l'image de la base.")
	
	var com_3b = tree.add_child(com_2, "Partenariat Univ.", 20, 400000, "Fonds de recherche alloués par les grandes universités.")
	
	var hover_timer = Timer.new()
	add_child(hover_timer)
	hover_timer.wait_time = 0.3
	hover_timer.one_shot = true

	_calculate_positions(tree.root, Vector2(0, 0), 0)
	_setup_scroll_area()
	_create_buttons_recursive(tree.root)

func _process(_delta):
	if(timer_label.is_visible_in_tree()):
		timer_label.text=str(int(timer.time_left))

func _calculate_positions(node: SearchTree.NodeData, pos: Vector2, depth: int):
	if node == null: return
	var x_offset = _get_subtree_width(node) * X_SPACING * -0.5
	node_positions[node] = Vector2(pos.x, depth * Y_SPACING)
	var child_x = pos.x + x_offset
	for child in node.children:
		node_positions[child] = Vector2(child_x, (depth + 1) * Y_SPACING)
		_calculate_positions(child, Vector2(child_x, (depth + 1) * Y_SPACING), depth + 1)
		child_x += _get_subtree_width(child) * X_SPACING

func _setup_scroll_area():
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for pos in node_positions.values():
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	var padding = Vector2(100, 100)
	var shift_vector = Vector2(-min_x, -min_y) + padding
	
	for node in node_positions.keys():
		node_positions[node] += shift_vector
		
	var total_width = (max_x - min_x) + (padding.x * 2)
	var total_height = (max_y - min_y) + (padding.y * 2)
	
	tree_canvas.custom_minimum_size = Vector2(total_width, total_height)
	tree_canvas.queue_redraw()

func _get_subtree_width(node: SearchTree.NodeData) -> int:
	if node.children.size() == 0: return 1
	var width = 0
	for child in node.children: width += _get_subtree_width(child)
	return width

func _on_tree_canvas_draw():
	if tree == null or tree.root == null: return
	_draw_lines_recursive(tree.root)

func _draw_lines_recursive(node: SearchTree.NodeData):
	if node == null: return
	var pos = node_positions[node]
	for child in node.children:
		var child_pos = node_positions[child]
		var start_pos = pos + Vector2(0, NODE_RADIUS)
		var end_pos = child_pos - Vector2(0, NODE_RADIUS)
		tree_canvas.draw_line(start_pos, end_pos, Color(0.0, 0.0, 0.0, 1.0), 2)
		_draw_lines_recursive(child)

func _create_buttons_recursive(node: SearchTree.NodeData):
	if node == null: return
	
	var pos = node_positions[node]
	var btn = Button.new() 
	var texte = Label.new()
	
	texte.text = str(node.nom)
	btn.set_size(texte.get_minimum_size()+Vector2(10,10))
	btn.set_position(pos - btn.size / 2) 
	
	btn.add_child(texte)
	texte.set_position(Vector2(5,5))
	
	tree_canvas.add_child(btn)
	
	if node.parent and not node.parent.debloque:
		btn.disabled = true
		btn.modulate = Color(0.0, 0.0, 0.0, 1.0)
	else:
		btn.disabled = false
		btn.modulate = Color(0, 1, 0)
		btn.pressed.connect(func(): ajouter_retirer_menu_node(btn.position + Vector2(btn.size.x, 0), node))
	
	for child in node.children:
		_create_buttons_recursive(child)

func ajouter_retirer_menu_node(pos: Vector2, node: SearchTree.NodeData):
	if current_menu: current_menu.queue_free()
	
	var menu = Panel.new()
	var nom = RichTextLabel.new()
	var bouton_recherche = Button.new()
	
	nom.bbcode_enabled = true
	nom.autowrap_mode = TextServer.AUTOWRAP_WORD
	menu.set_size(Vector2(300, 100))
	tree_canvas.add_child(menu) 
	menu.set_position(pos)
	
	nom.size = Vector2(300, 100)
	if node.debloque:
		nom.text = "[b]Description[/b] : " + node.description
	else:
		bouton_recherche.text = "Rechercher"
		bouton_recherche.set_size(Vector2(50, 20))
		bouton_recherche.set_position(Vector2(0, menu.size.y + 5))
		bouton_recherche.pressed.connect(func(): faire_recherche(node))
		menu.add_child(bouton_recherche)
		nom.text = "[b]Description[/b] : " + node.description + "\n[b]Argent[/b] : " + str(node.money) + "\n[b]Temps[/b] : " + str(node.time_cost)
	
	menu.add_child(nom)
	current_menu = menu

func faire_recherche(node):
	if current_menu: current_menu.queue_free()
	timer = Timer.new()
	timer.wait_time = node.time_cost
	timer.one_shot = true
	node.debloque = true
	add_child(timer)
	timer.timeout.connect(func():
		timer_label.visible=false
		Global.modifier_argent(Global.argent + node.money)
		Global.recherche_debloque.append(node.nom)
		
		for child in tree_canvas.get_children():
			child.queue_free()
		
		await get_tree().process_frame 
		
		_create_buttons_recursive(tree.root)
		tree_canvas.queue_redraw()
		
		timer.queue_free()
	)
	timer.start()
	timer_label.visible=true

func _on_exit_button_pressed() -> void:
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")
	if hud.has_node("ArbreRecherche"):
		hud.get_node("ArbreRecherche").visible = false
		Global.camera_enable = !Global.camera_enable
