extends Node2D

var tree: SearchTree
var node_positions = {}
var current_menu = null 

# Espacements
const X_SPACING = 100
const Y_SPACING = 100
const NODE_RADIUS = 5

func _ready():
	tree = SearchTree.new()
	var root = tree.create_root("Nouveau départ", 10, 5, "Établir le camp de base et installer les équipements.")
	var etape2 = tree.add_child(root, "Echantillons", 20, 10, "Forer la glace pour prélever des carottes.")
	var etape3 = tree.add_child(etape2, "Analyser les échantillons", 15, 7, "Analyser les échantillons sur place.")
	var etape4 = tree.add_child(etape3, "Envoyer les échantillons", 25, 12, "Envoyer les carottes au laboratoire central.")
	var etape5 = tree.add_child(etape4, "Vérifier la qualité", 10, 3, "Vérifier la qualité des données.")
	var etape6 = tree.add_child(etape5, "Rédiger rapport", 30, 15, "Rédiger le rapport préliminaire.")
	
	var hover_timer = Timer.new()
	add_child(hover_timer)
	hover_timer.wait_time = 0.3
	hover_timer.one_shot = true

	_calculate_positions(tree.root, Vector2(0, 0), 0)

# --- Calcul des positions des nœuds ---
func _calculate_positions(node: SearchTree.NodeData, pos: Vector2, depth: int):
	if node == null:
		return
	var x_offset = _get_subtree_width(node) * X_SPACING * -0.5
	node_positions[node] = Vector2(pos.x, depth * Y_SPACING)
	var child_x = pos.x + x_offset
	for child in node.children:
		node_positions[child] = Vector2(child_x, (depth + 1) * Y_SPACING)
		_calculate_positions(child, Vector2(child_x, (depth + 1) * Y_SPACING), depth + 1)
		child_x += _get_subtree_width(child) * X_SPACING
	if node == tree.root:
		_center_tree()
		
func _center_tree():
	# Trouve les bornes de l’arbre (min/max X et Y)
	var min_x = INF
	var max_x = -INF
	var min_y = INF
	var max_y = -INF
	
	for pos in node_positions.values():
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_y = min(min_y, pos.y)
		max_y = max(max_y, pos.y)
	
	# Calcule le centre de l’arbre
	var tree_center = Vector2((min_x + max_x) / 2.0, (min_y + max_y) / 2.0)
	
	# Décale tous les nœuds pour centrer l’arbre dans la vue
	var viewport_center = get_viewport_rect().size / 2.0
	for key in node_positions.keys():
		node_positions[key] -= tree_center
		node_positions[key] += viewport_center

func _get_subtree_width(node: SearchTree.NodeData) -> int:
	if node.children.size() == 0:
		return 1
	var width = 0
	for child in node.children:
		width += _get_subtree_width(child)
	return width

# --- Dessin ---
func _draw():
	if tree == null or tree.root == null:
		return
	_draw_node_recursive(tree.root)

func _draw_node_recursive(node: SearchTree.NodeData):
	if node == null:
		return

	var pos = node_positions[node]

	# tracer les liens
	for child in node.children:
		var child_pos = node_positions[child]
		var start_pos = pos + Vector2(0, NODE_RADIUS)
		var end_pos = child_pos - Vector2(0, NODE_RADIUS)
		draw_line(start_pos, end_pos, Color(0.6, 0.6, 0.6), 2)
		_draw_node_recursive(child)

	var btn = Button.new() 
	var texte = Label.new()
	
	texte.text = str(node.key)
	btn.set_position(pos - Vector2(50, 50)/2)
	btn.set_size(texte.get_minimum_size()+Vector2(10,10))
	btn.pressed.connect(func(): ajouter_retirer_menu_node(Vector2(pos.x+texte.size.x-10, pos.y), node))
	btn.add_child(texte)
	texte.set_position(Vector2(5,5))
	add_child(btn)
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	add_child(texte)

func ajouter_retirer_menu_node(pos: Vector2, node: SearchTree.NodeData):
	if current_menu:
		current_menu.queue_free()
	var menu = Panel.new()
	var nom = RichTextLabel.new()
	var faire_recherche = Button.new()
	menu.set_size(Vector2(300, 100))
	faire_recherche.set_size(Vector2(50, 20))
	faire_recherche.text = "Rechercher"
	faire_recherche.set_position(Vector2(0, menu.size.y+5))
	faire_recherche.pressed.connect(func(): faire_recherche(node.key))
	
	nom.bbcode_enabled = true
	nom.text = "[b]Description[/b] : "+node.description+"\n[b]Coût en recherche[/b] : "+str(node.research_cost)+"\n[b]Temps nécessaire[/b] : "+str(node.time_cost)
	nom.autowrap_mode = TextServer.AUTOWRAP_WORD
	nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nom.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	nom.size = menu.size
	nom.mouse_filter = Control.MOUSE_FILTER_IGNORE

	menu.set_position(Vector2(pos.x, pos.y+10))
	menu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu.add_child(nom)
	menu.add_child(faire_recherche)
	add_child(menu)
	current_menu = menu

func faire_recherche(nom_recherche: String):
	pass
