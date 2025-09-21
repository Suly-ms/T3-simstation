extends Node2D

# --- Coefficients de pondération ---
const COEF_POLLUTION_SANTE = 1.5   # combien la pollution réduit la santé
const COEF_BONHEUR_SANTE = 0.8     # combien le bonheur améliore la santé
const COEF_SANTE_EFF = 0.5         # combien la santé influence l’efficacité
const COEF_BONHEUR_EFF = 0.3       # combien le bonheur influence l’efficacité


func calculer_etat():
	# --- Santé, bonheur, efficacité bruts (habitants) ---
	var sante_brute = 0
	var bonheur_brute = 0
	var efficacite_brute = 0
	for h in Global.population:
		sante_brute += h["sante"]
		bonheur_brute += h["bonheur"]
		efficacite_brute += h["efficacite"]

	var nb_pop = max(1, Global.population.size())

	# normalisation bonheur habitants (0–100)
	bonheur_brute = float(bonheur_brute) / (100 * nb_pop) * 100

	# --- Pollution & Bonheur bâtiments ---
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

	# pollution moyenne (0–100 amplifiée)
	var pollution_moyenne = pollution_totale / batiments_total if batiments_total > 0 else 0
	Global.stats["polution"] = clamp(pow(pollution_moyenne, 1.2), 0, 100)

	# bonheur bâtiments (0–100)
	var bonheurBatiment_score = (float(bonheurBatiment_total) / bonheurBatiment_max) * 100 if bonheurBatiment_max > 0 else 50

	# --- Calculs pondérés ---
	var bonheur_total = bonheur_brute + bonheurBatiment_score

	var sante_finale = (sante_brute / nb_pop) \
		- Global.stats["pollution"] * COEF_POLLUTION_SANTE \
		+ bonheur_total * COEF_BONHEUR_SANTE

	var efficacite_finale = (efficacite_brute / nb_pop) \
		- Global.stats["sante"] * COEF_SANTE_EFF \
		- bonheur_total * COEF_BONHEUR_EFF

	# --- Normalisation finale 0-100 ---
	Global.stats["bonheur"] = clamp(int(round(bonheur_total)), 0, 100)
	Global.stats["sante"] = clamp(int(round(sante_finale)), 0, 100)
	Global.stats["efficacite"] = clamp(int(round(efficacite_finale)), 0, 100)

func _ready() -> void:
	calculer_etat()
	
func _process(_delta):
	calculer_etat()

func _on_button_pressed() -> void:
	Global.population.append({"sante": RandomNumberGenerator.new().randi_range(10,100), "efficacite": RandomNumberGenerator.new().randi_range(50,100), "bonheur": 0})
