extends Control

const x_espacement = 5
const MAX_VALUE = 100.0
const GRAPH_WIDTH = 660     
const GRAPH_HEIGHT = 325   
const x_step = 10

@onready var scrollContainer = $Panel/ScrollContainer

# --- Stockage des données historiques ---
var historique = {"sante":[],"efficacite":[],"bonheur":[]}


# Fonction pour ajouter une nouvelle donnée et mettre à jour le graphique
func ajouter_point_et_mettre_a_jour():
	# 1. Récupérer les nouvelles valeurs
	var nouvelle_sante = GlobalScript.get_sante()
	var nouveau_bonheur = GlobalScript.get_bonheur()
	var nouvelle_efficacite = GlobalScript.get_efficacite()
	
	# 2. Ajouter les valeurs à l'historique
	historique["sante"].append(nouvelle_sante)
	historique["efficacite"].append(nouvelle_efficacite)
	historique["bonheur"].append(nouveau_bonheur)
	_dessiner_ligne()

# Fonction générique pour convertir l'historique en points Line2D
func _dessiner_ligne():
	var ligne_sante = Line2D.new()
	var ligne_bonheur = Line2D.new()
	var ligne_efficacite = Line2D.new()
	var points: Array[Vector2] = []
	
	# Sante
	var line_sante = Line2D.new()
	var x = float(0) * x_step
	var normalized_value = historique["sante"].size()
	var y = GRAPH_HEIGHT - (normalized_value * GRAPH_HEIGHT)
	
	points.append(Vector2(x, y))
	line_sante.set_points(points)
	
	#Bonheur
	x = float(1) * x_step
	normalized_value = historique["bonheur"].size() -1
	y = GRAPH_HEIGHT - (normalized_value * GRAPH_HEIGHT)
	
	points.append(Vector2(x, y))
	
	#Efficacite
	x = float(2) * x_step
	normalized_value = historique["efficacite"].size() -1
	y = GRAPH_HEIGHT - (normalized_value * GRAPH_HEIGHT)
	
	points.append(Vector2(x, y))

# --- Exemple d'utilisation dans un intervalle régulier ---
func _ready():
	ajouter_point_et_mettre_a_jour()
