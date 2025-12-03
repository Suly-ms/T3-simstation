extends Node2D

signal argent_changed(argent)

var tree: SearchTree
var node_positions = {}
var current_menu = null 

# Mise en page
const X_SPACING = 300 # Écarté pour les boutons larges
const Y_SPACING = 150
const NODE_RADIUS = 30

# Références
@onready var scrollContainer = $background/ScrollContainer

# Canvas interne
var tree_canvas = Control.new()

func _ready():
	# Setup du ScrollContainer
	scrollContainer.add_child(tree_canvas)
	tree_canvas.draw.connect(_on_tree_canvas_draw)
	
	tree = SearchTree.new()

	# --- CONFIGURATION DES RECHERCHES (Coûts en TOURS) ---
	# 1 tour = 3 mois. 
	# Exemple : Coût 4 = 1 an d'attente.
	
	var root = tree.create_root("Déploiement Base", 1, 15000, "Installation module de survie.")

	# BRANCHE INFRASTRUCTURE (Gauche)
	var infra_1 = tree.add_child(root, "Générateurs Diesel", 1, 5000, "Électricité d'urgence.")
	var infra_2a = tree.add_child(infra_1, "Isolation Renforcée", 2, 25000, "Protection -50°C (6 mois).")
	var infra_3a = tree.add_child(infra_2a, "Dortoirs Modulaires", 3, 60000, "Modules chauffés (9 mois).")
	var infra_2b = tree.add_child(infra_1, "Garage à Chenilles", 2, 45000, "Hangar véhicules (6 mois).")
	var infra_3b = tree.add_child(infra_2b, "Rover d'Exploration", 4, 120000, "Accès zones lointaines (1 an).")
	var infra_final = tree.add_child(infra_3a, "Centrale Géothermique", 12, 2500000, "Énergie illimitée (3 ans).")

	# BRANCHE SCIENCE (Centre)
	var sci_1 = tree.add_child(root, "Sondage Radar", 1, 10000, "Scanner la glace.")
	var sci_2 = tree.add_child(sci_1, "Forage Superficiel", 2, 35000, "Carottes 0-50m (6 mois).")
	var sci_3a = tree.add_child(sci_2, "Labo de Chimie", 3, 80000, "Analyse bulles d'air (9 mois).")
	var sci_4a = tree.add_child(sci_3a, "Données Climatiques", 4, 200000, "Reconstitution climat (1 an).")
	var sci_3b = tree.add_child(sci_2, "Cryobiologie", 3, 90000, "Bactéries dormantes (9 mois).")
	var sci_4b = tree.add_child(sci_3b, "Séquençage ADN", 6, 500000, "Nouvelles formes de vie (1.5 ans).")
	var sci_final = tree.add_child(sci_4a, "Forage Profond (3km)", 20, 15000000, "Le socle rocheux (5 ans).")

	# BRANCHE COMMS (Droite)
	var com_1 = tree.add_child(root, "Antenne Satellite", 1, 8000, "Lien haut débit.")
	var com_2 = tree.add_child(com_1, "Demande de Subvention", 1, 150000, "Dossiers ONU (3 mois).")
	var com_3a = tree.add_child(com_2, "Reportage TV", 2, 500000, "Droits TV (6 mois).")
	var com_4a = tree.add_child(com_3a, "Sponsoring Privé", 4, 2000000, "Contrat Red Bull (1 an).")
	var com_3b = tree.add_child(com_2, "Partenariat Univ.", 3, 400000, "Fonds de recherche (9 mois).")

	# --- VERIFICATION DE L'ETAT ---
	# On parcourt l'arbre pour mettre à jour ce qui est débloqué ou en cours
	_update_tree_state_recursive(tree.root)

	# Calculs visuels
	_calculate_positions(tree.root, Vector2(0, 0), 0)
	_setup_scroll_area()
	_create_buttons_recursive(tree.root)

func _process(_delta):
	# À chaque frame, on vérifie si une recherche vient de se terminer grâce au changement de tour
	_check_research_completion()

# Vérifie si des recherches en cours sont finies
func _check_research_completion():
	var current_turn = GlobalScript.get_tour()
	var changes_made = false
	
	# On liste les clés pour pouvoir modifier le dictionnaire en itérant
	var recherches_names = GlobalScript.get_recherche_en_cours().keys()
	
	for nom_recherche in recherches_names:
		var tour_fin = GlobalScript.get_recherche_en_cours()[nom_recherche]
		
		if current_turn >= tour_fin:
			# C'EST FINI !
			_complete_research(nom_recherche)
			changes_made = true
	
	if changes_made:
		# On rafraichit l'affichage brutalement mais efficacement
		_refresh_ui()

func _complete_research(nom_recherche: String):
	print("Recherche terminée : ", nom_recherche)
	
	# 1. Trouver le noeud correspondant dans notre arbre local
	var node = _find_node_by_name(tree.root, nom_recherche)
	
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
	var btn = Button.new() 
	var texte = Label.new()
	
	# Configuration Style
	texte.text = str(node.nom)
	texte.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texte.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texte.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var button_size = Vector2(180, 60)
	btn.custom_minimum_size = button_size
	btn.set_size(button_size)
	texte.custom_minimum_size = button_size
	texte.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	btn.set_position(pos - button_size / 2) 
	btn.add_child(texte)
	tree_canvas.add_child(btn)
	
	# --- LOGIQUE ETAT DU BOUTON ---
	
	# Cas 1 : Recherche en cours
	if node.nom in GlobalScript.get_recherche_en_cours():
		btn.disabled = true
		btn.modulate = Color(1, 1, 0) # JAUNE = En cours
		var tours_restants = GlobalScript.get_recherche_en_cours()[node.nom] - GlobalScript.get_tour()
		texte.text += "\n(" + str(tours_restants) + " tours)"
		
	# Cas 2 : Parent non débloqué (Grisé)
	elif node.parent and not node.parent.debloque:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5) # GRIS
		
	# Cas 3 : Déjà acheté (Vert)
	elif node.debloque:
		btn.disabled = false # On laisse actif pour pouvoir relire la description
		btn.modulate = Color(0, 1, 0) # VERT
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
		bouton_recherche.text = "Lancer (" + str(node.time_cost) + " tours)"
		bouton_recherche.set_size(Vector2(280, 30))
		bouton_recherche.set_position(Vector2(10, 105))
		bouton_recherche.pressed.connect(func(): lancer_recherche(node))
		menu.add_child(bouton_recherche)
		
		nom.text = "[b]" + node.nom + "[/b]\n" + node.description + \
			"\n[b]Gain :[/b] " + str(node.money) + "$ " + \
			"\n[b]Durée :[/b] " + str(node.time_cost * 3) + " mois"
	
	menu.add_child(nom)
	current_menu = menu

func lancer_recherche(node):
	if current_menu: current_menu.queue_free()
	
	# Calcul du tour de fin
	var tour_actuel = GlobalScript.get_tour()
	var tour_fin = tour_actuel + node.time_cost
	
	# Enregistrement dans le Global
	GlobalScript.set_recherche_en_cours(node.nom, tour_fin)
	
	print("Recherche lancée : " + node.nom + ". Fin au tour " + str(tour_fin))
	
	# Mise à jour de l'interface
	_refresh_ui()

func _refresh_ui():
	# On supprime tout et on recrée (méthode simple et sûre)
	for child in tree_canvas.get_children():
		child.queue_free()
	
	# On attend une frame pour le nettoyage
	await get_tree().process_frame 
	
	# On recrée
	_create_buttons_recursive(tree.root)
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
	_draw_lines_recursive(tree.root)

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
