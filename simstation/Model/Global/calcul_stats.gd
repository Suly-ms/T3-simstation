extends Node2D

# SYSTEME DE STATISTIQUES ANTARCTIQUE (BASÉ SUR FORMULES MATHÉMATIQUES)

const COEFF_ISOLATION = 0.3
const COEFF_FROID = 0.8     
const REGEN_NATURELLE = 2.0   
const REGEN_HOPITAL = 15.0    
const COEFF_SAISON = 20.0
const BASE_TEMP = -40.0   

func _ready() -> void:
	if GlobalScript.get_sante() <= 0:
		GlobalScript.set_sante(100)
		GlobalScript.set_bonheur(100)
		GlobalScript.set_efficacite(100)
	
	passer_tour()

func passer_tour() -> void:    
	var tour_actuel = GlobalScript.get_tour() + 1
	GlobalScript.set_tour(tour_actuel)
	
	var mois = ((tour_actuel - 1) % 12) + 1
	var temp_ext = _calculer_temperature_cosinus(mois)
	GlobalScript.set_temperature(int(temp_ext))
	
	var sante_actuelle = float(GlobalScript.get_sante()) 
	var bonheur_actuel = float(GlobalScript.get_bonheur())
	var argent = max(1.0, float(GlobalScript.get_argent()))
	var scores_batiments = _calculer_scores_batiments() 
	var population = float(GlobalScript.get_population().size())
	
	var puissance_froid = abs(temp_ext) * COEFF_FROID
	var protection = 1.0 + (COEFF_ISOLATION * log(argent))
	var degats_subis = puissance_froid / protection
	
	var soin = REGEN_NATURELLE + (REGEN_HOPITAL * scores_batiments[0])
	
	var delta_sante = soin - degats_subis
	
	var nouvelle_sante = sante_actuelle + delta_sante
	
	if nouvelle_sante <= 0:
		nouvelle_sante = 0
		print("!!! GAME OVER : LA COLONIE EST MORTE DE FROID !!!")
	
	var score_loisir = scores_batiments[1] 
	var bonus_richesse = min(10.0, log(argent))
	var malus_hiver = 40.0 * pow(sin(PI * (mois - 1) / 12.0), 2) 
	var malus_pop = 0.5 * population
	
	var impact_sante_moral = (nouvelle_sante - 50) * 0.2
	
	var nouveau_bonheur = score_loisir + bonus_richesse - malus_hiver - malus_pop + impact_sante_moral

	_finaliser_stats(nouvelle_sante, nouveau_bonheur)
	
	print("--- MOIS %d ---" % mois)
	print("Météo: %d°C" % temp_ext)
	print("Bilan Santé: %+.1f PV (Dégats: -%.1f | Soin: +%.1f)" % [delta_sante, degats_subis, soin])
	print("Santé Totale: %d | Bonheur: %d" % [int(nouvelle_sante), int(nouveau_bonheur)])

func actualiser_stats_derivees() -> void:
	var s = float(GlobalScript.get_sante())
	var b = float(GlobalScript.get_bonheur())
	_finaliser_stats(s, b)

func _finaliser_stats(sante_brute: float, bonheur_brut: float) -> void:
	var s = clamp(sante_brute, 0.0, 100.0)
	var b = clamp(bonheur_brut, 0.0, 100.0)
	
	var efficacite = pow(s / 100.0, 1.5) * (b / 100.0) * 100.0
	
	GlobalScript.set_sante(int(s))
	GlobalScript.set_bonheur(int(b))
	GlobalScript.set_efficacite(int(efficacite))
	GlobalScript.update_population_stats(s, b, efficacite)

func _calculer_temperature_cosinus(mois: int) -> float:
	return BASE_TEMP + COEFF_SAISON * cos(PI * (mois - 1) / 6.0)
	
func _calculer_scores_batiments() -> Array:
	var counts = GlobalScript.get_batiments_counts()
	
	var points_medicaux = 0.0
	var points_loisirs = 70.0
	
	for nom_bat in counts:
		var qte = counts[nom_bat]
		if qte > 0:
			match nom_bat:
				"Infirmerie":
					points_medicaux += 0.2 * qte 
				"Hopital":
					points_medicaux += 0.5 * qte
				"Chauffage_Central":
					points_medicaux += 0.1 * qte 
				"Bar":
					points_loisirs += 10.0 * qte
				"SalleDeSport":
					points_loisirs += 15.0 * qte
				"Bibliotheque":
					points_loisirs += 5.0 * qte
					
	return [points_medicaux, points_loisirs]

func _ajouter_stats_nouveau_batiment(nombatiment):
	var current_b = GlobalScript.get_bonheur()
	GlobalScript.set_bonheur(min(100, current_b + 5))
	actualiser_stats_derivees()
