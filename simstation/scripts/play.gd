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

func _ready() -> void:
	calculer_etat()
	
	var control_node = get_node("/root/Play/hud/Hud") 
	control_node.connect("changement_etat", Callable(self, "calculer_etat"))
	
	rng.randomize()

func _process(_delta):
	if not fin_partie and (
		Global.stats["sante"] <= 0 or
		Global.stats["efficacite"] >= 100 or  # efficacité max = perte
		Global.stats["bonheur"] <= 0 or
		Global.stats["pollution"] >= 100
	):
		fin_partie = true
		print("FIN DE LA PARTIE")

# Fonctions principales pour calculer petite stats

func calculer_etat():
	print("Signal recu")
	var bonheur_total = calculer_bonheur()
	var sante_finale = calculer_sante(bonheur_total)
	var efficacite_finale = calculer_efficacite(bonheur_total, sante_finale)

	Global.stats["bonheur"] = clamp(int(round(bonheur_total)), MIN_SCORE, MAX_SCORE)
	Global.stats["sante"] = clamp(int(round(sante_finale)), MIN_SCORE, MAX_SCORE)
	Global.stats["efficacite"] = clamp(int(round(efficacite_finale)), MIN_SCORE, MAX_SCORE)

	if DEBUG_MODE:
		print_debug_stats()

# ----- fonctions utilitaires -----
func print_debug_stats():
	print("Bonheur:", Global.stats["bonheur"], " | Santé:", Global.stats["sante"],
		  " | Efficacité:", Global.stats["efficacite"], " | Pollution:", Global.stats.get("pollution", 0))

func noise_variation() -> float:
	return rng.randf_range(RANDOM_VARIATION_MIN, RANDOM_VARIATION_MAX)

# ----- calculs individuels -----
func calculer_bonheur() -> float:
	var bonheur_habitants = 0.0
	for h in Global.population:
		bonheur_habitants += float(h.get("bonheur", 0))

	var nb_pop = max(1, Global.population.size())
	var bonheur_normalise = bonheur_habitants / float(nb_pop)

	var batiments_results = _calculer_batiments_scores()
	var pollution_moyenne = batiments_results[0]
	var bonheur_batiment_score = batiments_results[1]

	# stocke pollution (déjà normalisée)
	Global.stats["pollution"] = int(clamp(pow(pollution_moyenne, 1.2), MIN_SCORE, MAX_SCORE))


	# Normalisation combinée : on limite l'impact pour éviter valeurs extrêmes
	var bonheur_total = bonheur_normalise + _squash_score(bonheur_batiment_score)
	return bonheur_total

func _calculer_batiments_scores() -> Array:
	var pollution_totale = 0.0
	var batiments_total = 0
	var bonheur_batiment_total = 0.0
	var bonheur_batiment_max = 0

	# accès local pour performance
	var batiments_nombre = Global.batiments_nombre
	var info_batiments = Global.info_batiments

	for id in batiments_nombre.keys():
		var nombre = int(batiments_nombre[id])
		if nombre == 0:
			continue
		var def = info_batiments.get(id, null)
		if def == null:
			continue
		# def expected: [nom, pollution, bonheur, ...]
		var pollution_par_unite = float(def[1])
		var bonheur_par_unite = float(def[2])

		pollution_totale += pollution_par_unite * nombre
		batiments_total += nombre
		bonheur_batiment_total += bonheur_par_unite * nombre
		bonheur_batiment_max += MAX_SCORE * nombre

	var pollution_moyenne = pollution_totale / batiments_total if batiments_total > 0 else 0.0

	var bonheur_batiment_score = DEFAULT_BONHEUR_BATIMENT
	if bonheur_batiment_max > 0:
		bonheur_batiment_score = (bonheur_batiment_total / float(bonheur_batiment_max)) * MAX_SCORE

	return [pollution_moyenne, bonheur_batiment_score]

func calculer_sante(bonheur_total: float) -> float:
	var sante_brute = 0.0
	for h in Global.population:
		sante_brute += float(h.get("sante", 0))

	var nb_pop = max(1, Global.population.size())
	var sante_moyenne = sante_brute / float(nb_pop)

	var pollution = float(Global.stats.get("pollution", 0))

	var sante_finale = sante_moyenne \
		- pollution * COEF_POLLUTION_SANTE \
		+ bonheur_total * COEF_BONHEUR_SANTE \
		+ noise_variation()

	# bornes raisonnables et squash pour éviter valeurs extrêmes
	return _clamp_and_squash(sante_finale)

func calculer_efficacite(bonheur_total: float, sante_finale: float) -> float:
	var efficacite_brute = 0.0
	for h in Global.population:
		efficacite_brute += float(h.get("efficacite", 0))

	var nb_pop = max(1, Global.population.size())
	var efficacite_moyenne = efficacite_brute / float(nb_pop)

	var efficacite_finale = efficacite_moyenne \
		+ sante_finale * COEF_SANTE_EFF \
		+ bonheur_total * COEF_BONHEUR_EFF \
		+ noise_variation()

	return _clamp_and_squash(efficacite_finale)

# ----- fonctions de normalisation et robustesse -----
func _squash_score(value: float) -> float:
	# sigmoid-like squash entre 0 et MAX_SCORE pour stabiliser effets extrêmes
	var x = clamp(value / MAX_SCORE, -3.0, 3.0)
	return MAX_SCORE * (1.0 / (1.0 + exp(-x)) - 0.5) * 2.0

func _clamp_and_squash(value: float) -> float:
	# applique une limite douce puis clamp final
	var softened = _squash_score(value)
	return clamp(softened, MIN_SCORE, MAX_SCORE)
