extends Node2D

# ------------------------------------------------------------------------------
# SYSTEME DE CALCUL - TOUR PAR TOUR (3 MOIS)
# ------------------------------------------------------------------------------
# 1 tour = 1 saison.
# La température change drastiquement à chaque tour.
# Les gains et pertes de stats sont beaucoup plus importants (impact sur 3 mois).
# ------------------------------------------------------------------------------

const TEMP_CONFORT = 18.0

# --- REGLAGES D'EQUILIBRAGE (Impact sur 3 mois) ---
# Si l'écart de température est grand, les dégâts sont lourds
# Ex: 10 degrés d'écart * 2.5 = -25 PV en un tour !
const COEFF_TEMP = 2.5      

# Impact des batiments par tour
# Ex: Un dortoir (+100 base) * 0.1 = +10 PV / tour
const COEFF_BATIMENTS = 0.1 

func _ready() -> void:
	print("Système de stats prêt. En attente du passage de tour.")

# Cette fonction doit être connectée à ton bouton "Fin du tour"
func passer_tour() -> void:
	print("\n--- DEBUT DU TOUR (3 MOIS PASSENT) ---")
	
	# 1. Gestion du Temps et de la Météo
	_calculer_saison_et_meteo()
	
	# 2. Calcul des conséquences sur la population
	_calculer_stats_population()
	
	print("--- FIN DU TOUR ---")

func _calculer_saison_et_meteo() -> void:
	# On récupère le numéro de tour actuel
	var tour_actuel = GlobalScript.get_tour()
	tour_actuel += 1
	GlobalScript.set_tour(tour_actuel)
	
	# Calcul de la saison (Modulo 4) : 0=Hiver, 1=Printemps, 2=Eté, 3=Automne
	var saison_index = tour_actuel % 4
	var nom_saison = ""
	var new_temp = 0
	
	match saison_index:
		0: # HIVER
			nom_saison = "Hiver"
			new_temp = -5 + (randi() % 10) # Entre -5 et 5°C
		1: # PRINTEMPS
			nom_saison = "Printemps"
			new_temp = 10 + (randi() % 10) # Entre 10 et 20°C
		2: # ETE
			nom_saison = "Été"
			new_temp = 25 + (randi() % 10) # Entre 25 et 35°C
		3: # AUTOMNE
			nom_saison = "Automne"
			new_temp = 5 + (randi() % 10)  # Entre 5 et 15°C
			
	GlobalScript.set_temperature(new_temp)
	print("Saison: %s | Tour: %d | Température ext: %d°C" % [nom_saison, tour_actuel, new_temp])

func _calculer_stats_population() -> void:
	var current_sante = float(GlobalScript.get_sante())
	var current_bonheur = float(GlobalScript.get_bonheur())
	
	# --- 1. IMPACT TEMPERATURE (FROID/CHAUD) ---
	var temp_actuelle = GlobalScript.get_temperature()
	var distance = abs(temp_actuelle - TEMP_CONFORT)
	var malus_temp = 0.0
	
	# Tolérance de 5 degrés. Au-delà, ça fait mal.
	if distance > 5.0:
		malus_temp = -(distance * COEFF_TEMP)
		print("> Malus Météo : %.1f PV (Conditions rudes)" % malus_temp)
	
	# --- 2. IMPACT BATIMENTS ---
	var bonus_bats = {"sante": 0.0, "bonheur": 0.0}
	var counts = GlobalScript.get_batiments_counts()
	var infos = GlobalScript.get_batiments_data()
	
	for nom in counts:
		var qte = counts[nom]
		if qte > 0 and infos.has(nom):
			# Bonus accumulé sur 3 mois
			bonus_bats["sante"] += (infos[nom][0] * 0.01) * qte * COEFF_BATIMENTS * 10.0
			bonus_bats["bonheur"] += (infos[nom][1] * 0.01) * qte * COEFF_BATIMENTS * 10.0
	
	# --- 3. APPLICATION DES STATS ---
	
	# Santé
	var new_sante = current_sante + malus_temp + bonus_bats["sante"]
	# Petit bonus de survie si tout va bien (+2 PV naturels)
	if malus_temp == 0: new_sante += 2.0 
	new_sante = clamp(new_sante, 0.0, 100.0)
	
	# Bonheur (Dépend fortement de la santé)
	var modif_bonheur_sante = 0.0
	if new_sante < 50: modif_bonheur_sante = -10.0 # Malades = Déprimés
	elif new_sante > 90: modif_bonheur_sante = 5.0  # En forme = Heureux
	
	var new_bonheur = current_bonheur + modif_bonheur_sante + bonus_bats["bonheur"]
	new_bonheur = clamp(new_bonheur, 0.0, 100.0)
	
	# Efficacité
	var new_efficacite = (new_sante * 0.6) + (new_bonheur * 0.4)
	
	# --- 4. SAUVEGARDE ---
	GlobalScript.set_sante(int(new_sante))
	GlobalScript.set_bonheur(int(new_bonheur))
	GlobalScript.set_efficacite(int(new_efficacite))
	GlobalScript.update_population_stats(new_sante, new_bonheur, new_efficacite)
	
	print("RÉSULTATS DU TRIMESTRE : Santé %.1f | Bonheur %.1f | Efficacité %.1f" % [new_sante, new_bonheur, new_efficacite])
