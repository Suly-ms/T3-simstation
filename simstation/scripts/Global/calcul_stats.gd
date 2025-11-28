extends Node2D
# DESCRIPTION :
# SCRIPT permettant de calculer les stats de la partie à partir de la population, 
# des batiments, de la température.
# On utilise une matrice d'affluence afin de calculer au mieux quelle stats influe sur quelle stats

const TEMP_CONFORT = 18
const RESISTANCE_FROID = 1.0

func _ready() -> void:
	pass
		
func calculer_facteur_temp() -> int:
	return max(0, (Global.environnement.get("temperature") - TEMP_CONFORT)*0.5)
	
func calculer_sante() -> int:
	var sante = GlobalScript.get_sante()
	if(GlobalScript.get_temperature() > TEMP_CONFORT):
		sante += clamp(GlobalScript.get_sante()+0.5, 0.0, 100)
	else:
		sante -= (TEMP_CONFORT - GlobalScript.get_temperature() * 0.5) / RESISTANCE_FROID
	return sante
	
func calculer_bonheur() -> int:
	var bonheur = GlobalScript.get_bonheur()
	var malus_sante = 0.0
	if GlobalScript.get_sante() < 50.0:
		malus_sante = -2.0
		
	bonheur += malus_sante
	bonheur = clamp(bonheur, 0.0, 100.0)
	return bonheur
	
func calculer_efficacite() -> int:
	# Formule : (Santé * 50%) + (Bonheur * 50%)
	# Un habitant triste mais en bonne santé bosse à 50%
	var efficacite = GlobalScript.get_efficacite()
	var facteur_base = (GlobalScript.get_sante() / 100.0)
	var facteur_motivation = 0.5 + (GlobalScript.get_bonheur() / 200.0) # Varie de 0.5 à 1.0
	
	efficacite = facteur_base * facteur_motivation
	return efficacite
	
func calculer_stats() -> Dictionary:
	var stats = {
		"sante": 0,
		"efficacite": 0,
		"bonheur": 0,
	}
	
	stats["sante"] = calculer_sante()
	stats["efficacite"] = calculer_efficacite()
	stats["bonheur"] = calculer_bonheur()
	
	return stats
