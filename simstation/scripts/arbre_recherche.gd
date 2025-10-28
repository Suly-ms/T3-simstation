extends RefCounted
class_name SearchTree

# --- noeud de l’arbre ---
class NodeData:
	var key: int
	var research_cost: int
	var time_cost: int
	var description: String
	var children: Array = []
	var parent: NodeData

	func _init(k: int, r_cost: int, t_cost: int, desc: String):
		key = k
		research_cost = r_cost
		time_cost = t_cost
		description = desc

# --- logique de l’arbre ---
var root: NodeData

func create_root(k: int, r_cost: int, t_cost: int, desc: String) -> NodeData:
	root = NodeData.new(k, r_cost, t_cost, desc)
	return root

func add_child(parent: NodeData, k: int, r_cost: int, t_cost: int, desc: String) -> NodeData:
	var child = NodeData.new(k, r_cost, t_cost, desc)
	child.parent = parent
	parent.children.append(child)
	return child

func depth_first_search(target, node: NodeData = null) -> NodeData:
	if node == null:
		node = root

	if node.value == target:
		return node

	for child in node.children:
		var result = depth_first_search(target, child)
		if result != null:
			return result

	return null

func breadth_first_search(target) -> NodeData:
	if root == null:
		return null

	var queue = [root]

	while queue.size() > 0:
		var current = queue.pop_front()
		if current.value == target:
			return current
		for child in current.children:
			queue.append(child)

	return null
