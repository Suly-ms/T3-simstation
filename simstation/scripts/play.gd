extends Node2D

var batimentsNombre = {
	0: 5, # Dortoir
	1: 1, # Cantine
	2: 5, # Labo recherche
	3: 1, # Salle sport
	4: 1,  # Salle repos
	5: 2
}

var batimentsDef = {
	0: "Dortoir",
	1: "Cantine",
	2: "Labo de recherche",
	3: "Salle de sport",
	4: "Salle de repos",
	5: "Générateur à pétrole"
}

# Id bâtiment : [Santé, Pollution, Bonheur, Description]
var infoBatiments = {
	0: [100, 5, 80, "Permet de se reposer tranquillement"],  
	1: [80, 10, 70, "Fournit de la nourriture aux habitants"],
	2: [50, 15, 60, "Permet de faire des recherches scientifiques"], 
	3: [70, 5, 85, "Améliore la condition physique des habitants"],  
	4: [90, 2, 90, "Endroit calme pour se détendre"],       
	5: [90, 25, -20, "Génère de l'électricité avec du pétrole"] 
}


func calculer_etat():
	# --- Santé des habitants ---
	var sante_total_SD = 0
	var sante_max_totale = 0
	for h in Global.population:
		sante_total_SD += h["sante"]
		sante_max_totale += 100   # chaque habitant a 100 max
	sante_total_SD = (float(sante_total_SD) / sante_max_totale) * 100 if sante_max_totale > 0 else 0

	# --- Santé mentale des habitants ---
	var mentale_total_SD = 0
	var mentale_max_totale = 0
	for h in Global.population:
		mentale_total_SD += h["sante_mentale"]
		mentale_max_totale += 100
	mentale_total_SD = (float(mentale_total_SD) / mentale_max_totale) * 100 if mentale_max_totale > 0 else 0

	# --- Efficacité des habitants ---
	var efficacite_total_SD = 0
	var efficacite_max_totale = 0
	for h in Global.population:
		efficacite_total_SD += h["efficacite"]
		efficacite_max_totale += 100
	efficacite_total_SD = (float(efficacite_total_SD) / efficacite_max_totale) * 100 if efficacite_max_totale > 0 else 0

	var pollution_totale = 0
	var batiments_total = 0
	for id in batimentsNombre.keys():
		var nombre = batimentsNombre[id]
		pollution_totale += infoBatiments[id][1] * nombre
		batiments_total += nombre

	var pollution_moyenne = float(pollution_totale) / batiments_total if batiments_total > 0 else 0
	Global.pollution = int(round(pollution_moyenne))

	# --- Bonheur des bâtiments ---
	var bonheur_total = 0
	var bonheur_max = 0
	for id in batimentsNombre.keys():
		var nombre = batimentsNombre[id]
		var bonheur_batiment = infoBatiments[id][2]   # index 2 = bonheur
		bonheur_total += bonheur_batiment * nombre
		bonheur_max += 100 * nombre                  # max bonheur possible pour ces bâtiments

	# Score normalisé entre 0 et 100
	var bonheur_score = clamp((float(bonheur_total) / bonheur_max) * 100, 0, 100) if bonheur_max > 0 else 50

	# --- Formules finales ---
	Global.santeMentale = clamp(int(round(mentale_total_SD + bonheur_score)), 0, 100)
	Global.sante = clamp(int(round(sante_total_SD - (Global.pollution / 2) + (Global.santeMentale / 2))), 0, 100)
	Global.efficacite = clamp(int(round(efficacite_total_SD - (Global.sante / 2) - (Global.santeMentale / 2))), 0, 100)
	
	print(str(Global.sante) + " ", str(Global.santeMentale) + " ", str(Global.efficacite) + " ", str(Global.pollution))

func _ready() -> void:
	calculer_etat()
