extends RefCounted
class_name SearchTree

# DESCRIPTION :
# Script de gestion d'un arbre de recherche (SearchTree), étendant RefCounted.
# Il s'appuie sur une classe interne NodeData qui contient les propriétés d'une recherche :
# nom, coût en argent, coût en temps, description, état débloqué, ainsi que ses liens (parent/enfants).
# Les fonctions disponibles sont :
# _init() : Constructeur de base (implicite ou hérité).
# create_root : Initialise la racine de l'arbre avec les données spécifiées.
# add_child : Ajoute un nouveau nœud enfant à un parent donné et met à jour les liens.
# depth_first_search : Parcourt l'arbre en profondeur pour trouver un nœud par son nom.
# breadth_first_search : Parcourt l'arbre en largeur pour trouver un nœud par son nom.

class NodeData:
	var nom: String
	var money: int
	var time_cost: int
	var description: String
	var debloque: bool
	var children: Array = []
	var parent: NodeData

	func _init(k: String, t_cost: int, r_cost: int, desc: String):
		nom = k
		money = r_cost
		time_cost = t_cost
		description = desc
		debloque = false

var root: NodeData

func create_root(k: String, r_cost: int, t_cost: int, desc: String) -> NodeData:
	root = NodeData.new(k, r_cost, t_cost, desc)
	return root

func add_child(parent: NodeData, k: String, r_cost: int, t_cost: int, desc: String) -> NodeData:
	var child = NodeData.new(k, r_cost, t_cost, desc)
	child.parent = parent
	parent.children.append(child)
	return child

func depth_first_search(target, node: NodeData = null) -> NodeData:
	if node == null:
		node = root

	if node.nom == target:
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
		if current.nom == target:
			return current
		for child in current.children:
			queue.append(child)

	return null
