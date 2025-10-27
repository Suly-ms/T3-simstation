extends RefCounted
class_name SearchTree

# --- noeud de l’arbre ---
class NodeData:
	var value
	var children = []

	func _init(v):
		value = v

	func add_child_node(child: NodeData):
		children.append(child)

# --- logique de l’arbre ---
var root: NodeData = null

func create_root(value):
	root = NodeData.new(value)
	return root

func add_child(parent: NodeData, value):
	var child = NodeData.new(value)
	parent.add_child_node(child)
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
