extends Node2D

var fin_partie = false
const MAX_SCORE := 100
const MIN_SCORE := 0
const DEFAULT_BONHEUR_BATIMENT := 50.0
const RANDOM_VARIATION_MIN := -5.0
const RANDOM_VARIATION_MAX := 5.0

# Matrice d'influence
var matrice_influence = [
	[0.0,   0.2,  0.3],  # Influence du bonheur
	[0.3,   0.0,  0.1],  # Influence de la santé
	[0.1,   0.2,  0.0]   # Influence de l'efficacité
]

var rng := RandomNumberGenerator.new()
var DEBUG_MODE := true
@onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	calculer_etat()
	rng.randomize()

func _process(_delta):
	if not fin_partie and (
		Global.stats["bonheur"] <= 0 or
		Global.stats["sante"] <= 0 or
		Global.stats["efficacite"] <= 0
	):
		fin_partie = true
		print("PARTIE FINI")

# Calcule les stats brutes
func calculer_stats_brutes() -> Array:
	var stats = [0.0, 0.0, 0.0]  # bonheur, santé, efficacité
	var nb_pop = Global.population.size()
	if nb_pop == 0:
		return [0.0, 0.0, 0.0] 

	var zero_bonheur = 0
	var zero_sante = 0
	var zero_efficacite = 0

	for h in Global.population:
		if h.get("bonheur", 0) == 0:
			zero_bonheur += 1
		if h.get("sante", 0) == 0:
			zero_sante += 1
		if h.get("efficacite", 0) == 0:
			zero_efficacite += 1

	if zero_bonheur > nb_pop * 0.5:
		stats[0] = 0.0
	else:
		var bonheur_total = 0.0
		for h in Global.population:
			bonheur_total += float(h.get("bonheur", 0))
		stats[0] = (bonheur_total / float(nb_pop) + _calculer_bonheur_batiments()) / 2.0

	if zero_sante > nb_pop * 0.5:
		stats[1] = 0.0
	else:
		var sante_total = 0.0
		for h in Global.population:
			sante_total += float(h.get("sante", 0))
		stats[1] = sante_total / float(nb_pop)

	if zero_efficacite > nb_pop * 0.5:
		stats[2] = 0.0
	else:
		var efficacite_total = 0.0
		for h in Global.population:
			efficacite_total += float(h.get("efficacite", 0))
		stats[2] = efficacite_total / float(nb_pop)

	return stats

# Appliquer la matrice d'influence
func appliquer_matrice_influence(stats_brutes: Array) -> Array:
	var stats_finales = [0.0, 0.0, 0.0]
	for i in range(3):
		for j in range(3):
			stats_finales[i] += stats_brutes[j] * matrice_influence[j][i]
		stats_finales[i] += noise_variation()
	return stats_finales

func calculer_etat():
	var stats_brutes = calculer_stats_brutes()
	var stats_finales = appliquer_matrice_influence(stats_brutes)
	Global.stats["bonheur"] = clamp(int(round(stats_finales[0])), MIN_SCORE, MAX_SCORE)
	Global.stats["sante"] = clamp(int(round(stats_finales[1])), MIN_SCORE, MAX_SCORE)
	Global.stats["efficacite"] = clamp(int(round(stats_finales[2])), MIN_SCORE, MAX_SCORE)
	if DEBUG_MODE:
		print_debug_stats()

func print_debug_stats():
	print("Bonheur:", Global.stats["bonheur"], " | Santé:", Global.stats["sante"], " | Efficacité:", Global.stats["efficacite"])

func noise_variation() -> float:
	return rng.randf_range(RANDOM_VARIATION_MIN, RANDOM_VARIATION_MAX)

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
