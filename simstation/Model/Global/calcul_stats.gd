extends Node2D

# CONFIGURATION
const TEMP_CONFORT = 18.0
const COEFF_TEMP = 0.5      # Impact du froid/chaud
const COEFF_BATIMENTS = 0.1 # Pour éviter que 5 dortoirs donnent +400% de bonus direct

func _ready() -> void:
	pass

# 1. Calcul de l'impact de la Température (Malus si trop chaud ou trop froid)
func _calculer_facteur_temp() -> float:
	var temp_actuelle = GlobalScript.get_temperature()
	# Distance par rapport à 18°C (ex: s'il fait 30°, distance = 12)
	var distance_confort = abs(temp_actuelle - TEMP_CONFORT)
	
	# Si on est proche de 18°C (+ ou - 2 degrés), pas de malus
	if distance_confort < 2.0:
		return 0.0
		
	# Sinon, malus progressif
	return -(distance_confort * COEFF_TEMP)

# 2. Calcul de l'impact des Bâtiments (Bonus/Malus cumulés)
func _calculer_impact_batiments() -> Dictionary:
	var bonus = {"sante": 0.0, "bonheur": 0.0}
	var batiments_counts = GlobalScript.get_batiments_counts()
	var batiments_info = GlobalScript.get_batiments_data()
	
	for nom_bat in batiments_counts:
		var nombre = batiments_counts[nom_bat]
		# On vérifie que le bâtiment existe dans les infos et qu'on en a au moins 1
		if nombre > 0 and batiments_info.has(nom_bat):
			var infos = batiments_info[nom_bat] 
			# Rappel structure info : [0]=Santé, [1]=Bonheur
			
			# Formule : Valeur du batiment * Nombre * Coefficient
			# On divise par 100 car tes infos sont sur base 100 (ex: 80) mais on veut un facteur
			bonus["sante"] += (infos[0] * 0.01) * nombre * COEFF_BATIMENTS * 10.0
			bonus["bonheur"] += (infos[1] * 0.01) * nombre * COEFF_BATIMENTS * 10.0
			
	return bonus

# 3. Fonction principale appelée par ton Timer ou ton Tour par Tour
func calculer_stats() -> void:
	# --- A. Récupération des valeurs actuelles ---
	# On force le float pour les calculs précis
	var current_sante = float(GlobalScript.get_sante())
	var current_bonheur = float(GlobalScript.get_bonheur())
	
	# --- B. Calculs des variations ---
	var impact_temp = _calculer_facteur_temp()
	var impact_bats = _calculer_impact_batiments()
	
	# --- C. Application Santé ---
	# La santé baisse avec la température, monte/descend avec les batiments
	var new_sante = current_sante + impact_temp + impact_bats["sante"]
	new_sante = clamp(new_sante, 0.0, 100.0)
	
	# --- D. Application Bonheur ---
	# Le bonheur dépend de la santé critique + des bâtiments
	var malus_sante = 0.0
	if new_sante < 40.0:
		malus_sante = -5.0 # Les gens sont malades, ils sont tristes
		
	var new_bonheur = current_bonheur + malus_sante + impact_bats["bonheur"]
	new_bonheur = clamp(new_bonheur, 0.0, 100.0)
	
	# --- E. Application Efficacité ---
	# Formule : (Santé * 60%) + (Bonheur * 40%)
	var new_efficacite = (new_sante * 0.6) + (new_bonheur * 0.4)
	new_efficacite = clamp(new_efficacite, 0.0, 100.0)
	
	# --- F. Envoi des résultats au GlobalScript ---
	GlobalScript.set_sante(int(new_sante))
	GlobalScript.set_bonheur(int(new_bonheur))
	GlobalScript.set_efficacite(int(new_efficacite))
	
	# Optionnel : Mettre à jour chaque habitant individuellement
	GlobalScript.update_population_stats(new_sante, new_bonheur, new_efficacite)
	
	print("Mise à jour Stats | Santé: %d | Bonheur: %d | Efficacité: %d" % [new_sante, new_bonheur, new_efficacite])
