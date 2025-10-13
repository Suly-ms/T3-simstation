extends Node2D

# Coeff
const COEF_POLLUTION_SANTE = 1.5
const COEF_BONHEUR_SANTE = 0.8
const COEF_SANTE_EFF = 0.5
const COEF_BONHEUR_EFF = 0.3
const BONHEUR_BATIMENT_PAR_DEFAUT = 50
const DEBUG_MODE = true

var fin_partie = false
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	calculer_etat()

func _process(_delta):
	if not fin_partie and (
		Global.stats["sante"] <= 0 or
		Global.stats["efficacite"] >= 100 or  # efficacité max = perte
		Global.stats["bonheur"] <= 0 or
		Global.stats["pollution"] >= 100
	):
		fin_partie = true
		print("FIN DE LA PARTIE")


func _on_button_pressed() -> void:
	Global.population.append({
		"sante": rng.randi_range(10, 100),
		"efficacite": rng.randi_range(50, 100),
		"bonheur": 0
	})
	calculer_etat()

# Fonctions principales pour calculer petite stats

func calculer_etat():
	var bonheur_total = calculer_bonheur()
	var sante_finale = calculer_sante(bonheur_total)
	var efficacite_finale = calculer_efficacite(bonheur_total, sante_finale)

	Global.stats["bonheur"] = clamp(int(round(bonheur_total)), 0, 100)
	Global.stats["sante"] = clamp(int(round(sante_finale)), 0, 100)
	Global.stats["efficacite"] = clamp(int(round(efficacite_finale)), 0, 100)

	if DEBUG_MODE:
		print("Bonheur:", Global.stats["bonheur"], " | Santé:", Global.stats["sante"], " | Efficacité:", Global.stats["efficacite"], " | Pollution:", Global.stats["pollution"])

func calculer_bonheur() -> float:
	var bonheur_habitants = 0
	for h in Global.population:
		bonheur_habitants += h["bonheur"]

	var nb_pop = max(1, Global.population.size())
	var bonheur_normalise = float(bonheur_habitants) / nb_pop

	var pollution_totale = 0
	var batiments_total = 0
	var bonheurBatiment_total = 0
	var bonheurBatiment_max = 0

	for id in Global.batiments_nombre.keys():
		var nombre = Global.batiments_nombre[id]
		if nombre == 0:
			continue
		var def = Global.info_batiments[id]
		pollution_totale += def[1] * nombre
		batiments_total += nombre
		bonheurBatiment_total += def[2] * nombre
		bonheurBatiment_max += 100 * nombre

	var pollution_moyenne = pollution_totale / batiments_total if batiments_total > 0 else 0
	Global.stats["pollution"] = int(clamp(pow(pollution_moyenne, 1.2), 0, 100))

	var bonheurBatiment_score = 0.0
	if bonheurBatiment_max > 0:
		bonheurBatiment_score = (float(bonheurBatiment_total) / bonheurBatiment_max) * 100
	else:
		bonheurBatiment_score = BONHEUR_BATIMENT_PAR_DEFAUT


	return bonheur_normalise + bonheurBatiment_score

func calculer_sante(bonheur_total: float) -> float:
	var sante_brute = 0
	for h in Global.population:
		sante_brute += h["sante"]

	var nb_pop = max(1, Global.population.size())
	var sante_moyenne = float(sante_brute) / nb_pop

	var sante_finale = sante_moyenne \
		- Global.stats["pollution"] * COEF_POLLUTION_SANTE \
		+ bonheur_total * COEF_BONHEUR_SANTE \
		+ rng.randf_range(-2, 2)

	return sante_finale

func calculer_efficacite(bonheur_total: float, sante_finale: float) -> float:
	var efficacite_brute = 0
	for h in Global.population:
		efficacite_brute += h["efficacite"]

	var nb_pop = max(1, Global.population.size())
	var efficacite_moyenne = float(efficacite_brute) / nb_pop

	var efficacite_finale = efficacite_moyenne \
		+ sante_finale * COEF_SANTE_EFF \
		+ bonheur_total * COEF_BONHEUR_EFF \
		+ rng.randf_range(-2, 2)

	return efficacite_finale
