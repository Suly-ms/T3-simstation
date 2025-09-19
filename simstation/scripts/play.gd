extends Node2D

var batiments = {
	0: "Dortoir",
	1: "Cantine",
	2: "Labo de recherche",
	3: "Salle de sport",
	4: "Salle de repos"
}

# Id bâtiment : [Santé, Pollution, Description]
var infoBatiments = {
	0: [100, 5, "Permet de se reposer tranquillement"],
	1: [80, 10, "Fournit de la nourriture aux habitants"],
	2: [50, 15, "Permet de faire des recherches scientifiques"],
	3: [70, 5, "Améliore la condition physique des habitants"],
	4: [90, 2, "Endroit calme pour se détendre"]
}

func _ready():
	pass
	
func calculer_etat():
	var total_sante = 0
	var total_pollution = 0
	var total_sante_mentale = 0
	
	for id in batiments.keys():
		# On suppose que chaque bâtiment est construit pour tous les habitants
		var info = infoBatiments[id]
		total_sante += info[0]  # Santé
		total_pollution += info[1]  # Pollution
		total_sante_mentale += info[0] * 0.5  # La santé mentale est une fraction de la santé physique

	# Moyenne par bâtiment
	Global.sante = clamp(total_sante / batiments.size(), 0, 100)
	Global.santeMentale = clamp(total_sante_mentale / batiments.size(), 0, 100)
	
	# L'environnement diminue avec la pollution
	Global.environement = clamp(100 - total_pollution, 0, 100)
	
	# Efficacité pourrait être une moyenne de santé physique et mentale
	Global.efficacite = clamp((Global.sante + Global.santeMentale) / 2, 0, 100)
	
	# Ajustements supplémentaires
	if Global.heure == 1:  # Nuit
		Global.santeMentale -= 5
	if Global.temperature > 35 or Global.temperature < 15:
		Global.sante -= 10
		Global.efficacite -= 10
	
	# On garde les valeurs entre 0 et 100
	Global.sante = clamp(Global.sante, 0, 100)
	Global.santeMentale = clamp(Global.santeMentale, 0, 100)
	Global.efficacite = clamp(Global.efficacite, 0, 100)
	Global.environement = clamp(Global.environement, 0, 100)

func _process(_delta):
	pass
