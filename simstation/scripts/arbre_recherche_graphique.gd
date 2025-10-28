extends Node2D

var tree: SearchTree
var node_positions = {} # {NodeData: Vector2}

# Espacements
const X_SPACING = 150
const Y_SPACING = 100
const NODE_RADIUS = 25

func _ready():
	tree = SearchTree.new()
	var root = tree.create_root(1, 10, 5, "Établir le camp de base et installer les équipements.")
	var etape2 = tree.add_child(root, 2, 20, 10, "Forer la glace pour prélever des carottes.")
	var etape3 = tree.add_child(root, 3, 15, 7, "Analyser les échantillons sur place.")
	var etape4 = tree.add_child(etape2, 4, 25, 12, "Envoyer les carottes au laboratoire central.")
	var etape5 = tree.add_child(etape3, 5, 30, 15, "Rédiger le rapport préliminaire.")
	var etape6 = tree.add_child(etape3, 6, 10, 3, "Vérifier la qualité des données.")

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

	# dessiner le nœud
	var btn = Button.new() # ou créez plutôt une scène de bouton
	btn.set_position(pos - Vector2(50, 50)/2)
	btn.set_size(Vector2(50, 50))
	btn.pressed.connect(func(): afficher_menu_node(pos - Vector2(50, 50)/2, node))
	add_child(btn)
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	draw_string(default_font, pos + Vector2(-6, 5), str(node.key), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, Color.WHITE)
	draw_string(default_font, pos + Vector2(-6, 5), str(node.key), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size, Color.WHITE)

func afficher_menu_node(pos: Vector2, node: SearchTree.NodeData):
	print("Coût de recherche: %d, Temps nécessaire: %d" % [node.research_cost, node.time_cost])
