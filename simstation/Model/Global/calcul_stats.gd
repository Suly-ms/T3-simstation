extends Node2D

# ------------------------------------------------------------------------------
# SYSTEME DE CALCUL DE STATISTIQUES (TOUR PAR TOUR)
# ------------------------------------------------------------------------------
# Ce script gère l'évolution des statistiques de la colonie selon deux modes :
#
# 1. EVOLUTION TEMPORELLE : via la fonction passer_tour()
#    - Avance le calendrier de 3 mois (1 saison).
#    - Change la météo (Température aléatoire selon la saison).
#    - Calcule les dégâts météo (si la température dépasse la tolérance).
#    - Calcule les bonus/malus cumulés des bâtiments sur la période.
#    - Modifie les valeurs brutes de Santé et Bonheur.
#
# 2. MISE A JOUR D'ETAT : via la fonction actualiser_stats_derivees()
#    - À utiliser après une action immédiate (ex: construction, event).
#    - Ne modifie PAS la santé ou le bonheur (pas de gain de temps).
#    - Recalcule l'Efficacité basée sur la Santé (60%) et le Bonheur (40%).
#    - Borne toutes les valeurs entre 0 et 100 (Clamp).
#    - Synchronise le GlobalScript et la population.
# ------------------------------------------------------------------------------

const TEMP_CONFORT = 18.0
const TOLERANCE_TEMP = 5.0
const COEFF_TEMP = 2.0
const COEFF_BATIMENTS = 0.1 

func _ready() -> void:
	if GlobalScript.get_sante() <= 0:
		GlobalScript.set_sante(100)
		GlobalScript.set_bonheur(100)
		GlobalScript.set_efficacite(100)
	
	actualiser_stats_derivees()

func passer_tour() -> void:	
	_calculer_saison_et_meteo()
	_appliquer_changements_tour()
	actualiser_stats_derivees()
	
func _ajouter_stats_nouveau_batiment(nombatiment):
	var bonus_bat_bonheur = 0.0
	var infos = GlobalScript.get_batiment_info(nombatiment)
	
	bonus_bat_bonheur += (infos[1] * 0.1) * COEFF_BATIMENTS * 10.0
	
	GlobalScript.set_bonheur(GlobalScript.get_bonheur() + bonus_bat_bonheur)

func actualiser_stats_derivees() -> void:
	var sante = float(GlobalScript.get_sante())
	var bonheur = float(GlobalScript.get_bonheur())
	
	sante = clamp(sante, 0.0, 100.0)
	bonheur = clamp(bonheur, 0.0, 100.0)
	
	var efficacite = (sante * 0.6) + (bonheur * 0.4)
	efficacite = clamp(efficacite, 0.0, 100.0)
	
	GlobalScript.set_sante(int(sante))
	GlobalScript.set_bonheur(int(bonheur))
	GlobalScript.set_efficacite(int(efficacite))
	GlobalScript.update_population_stats(sante, bonheur, efficacite)
	
	print("Stats Actualisées -> S: %d | B: %d | E: %d" % [sante, bonheur, efficacite])

func _calculer_saison_et_meteo() -> void:
	var tour_actuel = GlobalScript.get_tour() + 1
	GlobalScript.set_tour(tour_actuel)
	
	var saison_index = tour_actuel % 4
	var new_temp = 0
	var nom_saison = ""
	
	match saison_index:
		0: 
			new_temp = -25 - (randi() % 14)
			nom_saison = "Été austral"
		1: 
			new_temp = -40 - (randi() % 16)
			nom_saison = "Automne austral"
		2: 
			new_temp = -60 - (randi() % 16)
			nom_saison = "Hiver austral"
		3: 
			new_temp = -45 - (randi() % 16)
			nom_saison = "Printemps austral"


			
	GlobalScript.set_temperature(new_temp)
	GlobalScript.set_saison(nom_saison)
	print("Saison: %s | Temp: %d°C" % [nom_saison, new_temp])

func _appliquer_changements_tour() -> void:
	var current_sante = float(GlobalScript.get_sante())
	var current_bonheur = float(GlobalScript.get_bonheur())
	
	var temp_actuelle = GlobalScript.get_temperature()
	var distance = abs(temp_actuelle - TEMP_CONFORT)
	var exces = max(0, distance - TOLERANCE_TEMP)
	var delta_sante = -(exces * COEFF_TEMP)
	
	if delta_sante < 0: 
		print("Malus Météo: %.1f" % delta_sante)
	
	var delta_bonheur = 0.0
	
	var counts = GlobalScript.get_batiments_counts()
	var infos = GlobalScript.get_batiments_data()
	
	for nom in counts:
		if counts[nom] > 0 and infos.has(nom):
			delta_bonheur += (infos[nom][1] * 0.01) * counts[nom] * COEFF_BATIMENTS * 10.0
	
	if exces == 0: 
		delta_sante += 5.0
	
	current_sante += delta_sante
	
	if current_sante < 50: 
		delta_bonheur -= 10.0
	elif current_sante > 80: 
		delta_bonheur += 5.0
	
	current_bonheur += delta_bonheur
	
	GlobalScript.set_sante(int(current_sante))
	GlobalScript.set_bonheur(int(current_bonheur))
