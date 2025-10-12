extends Node2D

var fin_partie = false

const MAX_SCORE := 100
const MIN_SCORE := 0
const DEFAULT_BONHEUR_BATIMENT := 50.0
const RANDOM_VARIATION_MIN := -2.0
const RANDOM_VARIATION_MAX := 2.0

const COEF_POLLUTION_SANTE := 0.5   # exemple, adapte selon ton jeu
const COEF_BONHEUR_SANTE := 0.3
const COEF_SANTE_EFF := 0.2
const COEF_BONHEUR_EFF := 0.4

var rng := RandomNumberGenerator.new()
var DEBUG_MODE := true

@onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	calculer_etat()
	
	var control_node = get_node("/root/Play/hud/Hud") 
	control_node.connect("changement_etat", Callable(self, "calculer_etat"))
	
	rng.randomize()
	
func _input(_event: InputEvent) -> void:
	if(Input.is_action_just_pressed("sauvegarder")):
		var url = "https://simstation-33519-default-rtdb.europe-west1.firebasedatabase.app/users/"+Global.user["nom"]+".json"
		var data = {"time":Global.user["time"], "habitants": Global.population.size(), "stats":Global.stats}
		var json_data = JSON.stringify(data)
		
		var error = http_request.request(
			url,
			["Content-Type: application/json"],
			HTTPClient.METHOD_PUT,
			json_data
		)
		
		if error != OK:
			print("Erreur envoi Firebase:", error)

func _process(_delta):
	if not fin_partie and (
		Global.stats["sante"] <= 0 or
		Global.stats["efficacite"] >= 100 or
		Global.stats["bonheur"] <= 0
	):
		fin_partie = true
		print("FIN DE LA PARTIE")

func calculer_etat():
	print("Signal reçu")
	var matrice_stats = calculer_matrice_stats()
	Global.stats["bonheur"] = clamp(int(round(matrice_stats[0])), MIN_SCORE, MAX_SCORE)
	Global.stats["sante"] = clamp(int(round(matrice_stats[1])), MIN_SCORE, MAX_SCORE)
	Global.stats["efficacite"] = clamp(int(round(matrice_stats[2])), MIN_SCORE, MAX_SCORE)
	if DEBUG_MODE:
		print_debug_stats()

func print_debug_stats():
	print("Bonheur:", Global.stats["bonheur"], " | Santé:", Global.stats["sante"], " | Efficacité:", Global.stats["efficacite"])

func noise_variation() -> float:
	return rng.randf_range(RANDOM_VARIATION_MIN, RANDOM_VARIATION_MAX)

func calculer_matrice_stats() -> Array:
	# Matrice 2D : [ [bonheur_pop, bonheur_bat], [sante_pop, sante_bat], [efficacite_pop, efficacite_bat] ]
	var matrice = [
		[0.0, DEFAULT_BONHEUR_BATIMENT],  # bonheur
		[0.0, 0.0],                        # santé
		[0.0, 0.0]                         # efficacité
	]

	#Bonheur
	var bonheur_habitants = 0.0
	for h in Global.population:
		bonheur_habitants += float(h.get("bonheur", 0))
	var nb_pop = max(1, Global.population.size())
	matrice[0][0] = bonheur_habitants / float(nb_pop)
	matrice[0][1] = _calculer_bonheur_batiments()

	#Santé
	var sante_brute = 0.0
	for h in Global.population:
		sante_brute += float(h.get("sante", 0))
	matrice[1][0] = sante_brute / float(nb_pop)

	#Efficacité
	var efficacite_brute = 0.0
	for h in Global.population:
		efficacite_brute += float(h.get("efficacite", 0))
	matrice[2][0] = efficacite_brute / float(nb_pop)

	#Calcul final des stats combinées
	var bonheur_total = matrice[0][0] + _squash_score(matrice[0][1])
	var sante_finale = matrice[1][0] + bonheur_total * COEF_BONHEUR_SANTE + noise_variation()
	var efficacite_finale = matrice[2][0] + sante_finale * COEF_SANTE_EFF + bonheur_total * COEF_BONHEUR_EFF + noise_variation()

	return [bonheur_total, sante_finale, efficacite_finale]

func _calculer_bonheur_batiments() -> float:
	var bonheur_batiment_total = 0.0
	var bonheur_batiment_max = 0
	var batiments_nombre = Global.batiments_nombre
	var info_batiments = Global.info_batiments
	for id in batiments_nombre.keys():
		var nombre = int(batiments_nombre[id])
		if nombre == 0:
			continue
		var def = info_batiments.get(id, null)
		if def == null:
			continue
		var bonheur_par_unite = float(def[2])
		bonheur_batiment_total += bonheur_par_unite * nombre
		bonheur_batiment_max += MAX_SCORE * nombre
	if bonheur_batiment_max > 0:
		return (bonheur_batiment_total / float(bonheur_batiment_max)) * MAX_SCORE
	return DEFAULT_BONHEUR_BATIMENT

func _squash_score(value: float) -> float:
	var x = clamp(value / MAX_SCORE, -3.0, 3.0)
	return MAX_SCORE * (1.0 / (1.0 + exp(-x)) - 0.5) * 2.0
