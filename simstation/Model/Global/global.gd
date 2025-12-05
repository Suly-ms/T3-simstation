extends Node

# DESCRIPTION :
# Global qui sert à stocker les infos du joueur, des stats de la partie, des batiments, 
# de la population, de l'argent et du nombre de tour de la partie.

var camera_enable = true;
var user = {"nom":"Martin","time":3}

var population = [
	{"sante": 100, "efficacite": 100, "bonheur": 50}
]

var recherche_debloque = []
var recherche_en_cours = {}

var argent = 3000000

# ce que le joueur possède
var inventaire = {
	"hub": 1,
	"dortoir": 0, 
	"cantine": 1, 
	"labo_recherche": 1, 
	"salle_sport": 0, 
	"salle_repos": 0, 
	"panneaux_solaires": 0,
	"generateur_petrole": 0
}

var batiments_prix = {
	"hub": 94837175, 
	"dortoir": 54867, 
	"cantine": 50000, 
	"labo_recherche": 646463, 
	"salle_sport": 957376, 
	"salle_repos": 75743, 
	"panneaux_solaires": 88484,
	"generateur_petrole": 19999
}

var batiments_nombre = {
	"hub": 1,
	"dortoir": 5, 
	"cantine": 1, 
	"labo_recherche": 5, 
	"salle_sport": 1, 
	"salle_repos": 1, 
	"panneaux_solaires": 3,
	"generateur_petrole": 3
}

# [Santé, Bonheur, Description]
var info_batiments = {
	"hub": [100, 50, "Hub principal de la station", "Hub"],  # [ Santé, Bonheur, Description, Nom (à afficher) ]
	"dortoir": [100, 50, "Permet de se reposer tranquillement", "Dortoir"],  
	"cantine": [80, 70, "Fournit de la nourriture aux habitants", "Cantine"],
	"labo_recherche": [50, 60, "Permet de faire des recherches scientifiques", "Laboratoire de recherche"], 
	"salle_sport": [70, 85, "Améliore la condition physique des habitants", "Salle de sport"],  
	"salle_repos": [90, 90, "Endroit calme pour se détendre", "Salle de repos"],    
	"panneaux_solaires": [90, 90, "Génère de l'électricité avec le Soleil", "Panneau solaire"],   
	"generateur_petrole": [50, -20, "Génère de l'électricité avec du pétrole", "Générateur de pétrole"] 
}

var stats = {
	"sante": 50,
	"efficacite": 50,
	"bonheur": 50,
	"science": 50
}

var environnement = {
	"temperature": -5  # °C
}

var tour = 1       # chaque tours 3 mois
