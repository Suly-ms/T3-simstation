extends Node2D

var batimentsNombre = {
	0: 5, # Dortoir
	1: 1, # Cantine
	2: 5, # Labo recherche
	3: 1, # Salle sport
	4: 1,  # Salle repos
	5: 200
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
	# --- Santé brute ---
	var sante_brute = 0
	for h in Global.population:
		sante_brute += h["sante"]

	# --- Bonheur brut (habitants) ---
	var bonheur_brute = 0
	var bonheur_max = 0
	for h in Global.population:
		bonheur_brute += h["bonheur"]
		bonheur_max += 100
	if bonheur_max > 0:
		bonheur_brute = (float(bonheur_brute) / bonheur_max) * 100

	# --- Efficacité brute ---
	var efficacite_brute = 0
	for h in Global.population:
		efficacite_brute += h["efficacite"]

	# --- Pollution brute ---
	var pollution_totale = 0
	var batiments_total = 0
	for id in batimentsNombre.keys():
		var nombre = batimentsNombre[id]
		pollution_totale += infoBatiments[id][1] * nombre
		batiments_total += nombre
	var pollution_moyenne = float(pollution_totale) / batiments_total if batiments_total > 0 else 0
	Global.pollution = int(clamp(pow(pollution_moyenne, 1.2), 0, 100)) # exposant >1 amplifie


	# --- Bonheur des bâtiments ---
	var bonheurBatiment_total = 0
	var bonheurBatiment_max = 0
	for id in batimentsNombre.keys():
		var nombre = batimentsNombre[id]
		bonheurBatiment_total += infoBatiments[id][2] * nombre
		bonheurBatiment_max += 100 * nombre
	var bonheurBatiment_score = (float(bonheurBatiment_total) / bonheurBatiment_max) * 100 if bonheurBatiment_max > 0 else 50

	# --- Somme brute ---
	var bonheur_total = bonheur_brute + bonheurBatiment_score
	var sante_finale = sante_brute - Global.pollution + bonheur_total
	var efficacite_finale = efficacite_brute - (sante_finale / 2) - (bonheur_total / 2)

	# --- Normalisation sur 0-100 ---
	Global.bonheur = clamp(int(round(bonheur_total)), 0, 100)
	Global.sante = clamp(int(round(sante_finale / (100 * len(Global.population)) * 100)), 0, 100)
	Global.efficacite = clamp(int(round(efficacite_finale / (100 * len(Global.population)) * 100)), 0, 100)

func _ready() -> void:
	calculer_etat()
	
func _process(_delta):
	calculer_etat()

func _on_button_pressed() -> void:
	Global.population.append({"sante": RandomNumberGenerator.new().randi_range(10,100), "efficacite": RandomNumberGenerator.new().randi_range(50,100), "bonheur": 0})
