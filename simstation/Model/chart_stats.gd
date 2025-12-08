extends Control
 
var x_espacement = 10
var y_espacement = 10

var ligne_sante = Line2D.new()
var ligne_bonheur = Line2D.new()
var ligne_efficacite = Line2D.new()
var ligne_x = Line2D.new()
var ligne_y = Line2D.new()

@onready var container_interne = Control.new()
@onready var scrollContainer = $Panel/ScrollContainer

var taille_x
var taille_y

var points_sante: Array[Vector2] = []
var points_bonheur: Array[Vector2] = []
var points_efficacite: Array[Vector2] = []

func _ready():
	await get_tree().process_frame
	taille_x = scrollContainer.size.x
	taille_y = scrollContainer.size.y
	
	ligne_x.width = 5
	ligne_x.default_color = Color.GRAY
	var points_x: Array[Vector2] = [Vector2(8,5), Vector2(8, taille_y-5)]
	ligne_x.set_points(points_x)
	container_interne.add_child(ligne_x)
	
	ligne_y.width = 5
	ligne_y.default_color = Color.GRAY
	var points_y: Array[Vector2] = [Vector2(5, taille_y-5), Vector2(taille_x, taille_y-5)]
	ligne_y.set_points(points_y)
	container_interne.add_child(ligne_y)
	
	ajouter_point_et_mettre_a_jour()
	GlobalScript.connect("tour_change", ajouter_point_et_mettre_a_jour)
	
	ligne_sante.width = 4
	ligne_sante.default_color = Color.RED
	ligne_bonheur.width = 4
	ligne_bonheur.default_color = Color.YELLOW
	ligne_efficacite.width = 4
	ligne_efficacite.default_color = Color.BLUE
	
	container_interne.add_child(ligne_sante)
	container_interne.add_child(ligne_bonheur)
	container_interne.add_child(ligne_efficacite)
	
	scrollContainer.add_child(container_interne)

func ajouter_point_et_mettre_a_jour():
	var nouvelle_sante = GlobalScript.get_sante()
	var nouveau_bonheur = GlobalScript.get_bonheur()
	var nouvelle_efficacite = GlobalScript.get_efficacite()
	
	var y_sante = taille_y - ((nouvelle_sante * taille_y) / 100.0)
	var y_efficacite = taille_y - ((nouvelle_efficacite * taille_y) / 100.0)
	var y_bonheur = taille_y - ((nouveau_bonheur * taille_y) / 100.0)
	
	var pos_sante = Vector2(x_espacement, y_sante - y_espacement)
	var pos_efficacite = Vector2(x_espacement, y_efficacite - y_espacement)
	var pos_bonheur = Vector2(x_espacement, y_bonheur - y_espacement)
	
	points_sante.append(pos_sante)
	points_efficacite.append(pos_efficacite)
	points_bonheur.append(pos_bonheur)
	
	x_espacement += 100
	
	container_interne.custom_minimum_size.x = x_espacement + 50
	
	if(container_interne.custom_minimum_size.x>=taille_x):
		ligne_y.set_point_position(1, Vector2(container_interne.custom_minimum_size.x, taille_y - 5))
	
	ligne_sante.set_points(points_sante)
	ligne_bonheur.set_points(points_bonheur)
	ligne_efficacite.set_points(points_efficacite)
	
	creer_marqueur(pos_sante, Color.RED)
	creer_marqueur(pos_efficacite, Color.BLUE)
	creer_marqueur(pos_bonheur, Color.YELLOW)
	
	scrollContainer.scroll_horizontal = int(container_interne.custom_minimum_size.x)
	
func creer_marqueur(pos: Vector2, couleur: Color):
	var marqueur = Polygon2D.new()
	
	marqueur.polygon = PackedVector2Array([
		Vector2(0, -6), 
		Vector2(6, 0), 
		Vector2(0, 6), 
		Vector2(-6, 0)
	])
	
	marqueur.position = pos
	marqueur.color = couleur
	marqueur.z_index = 1 
	
	container_interne.add_child(marqueur)

func _on_exit_button_pressed() -> void:
	hide()
