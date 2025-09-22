extends Node

var population = [
	{"sante": 100, "efficacite": 100, "bonheur": 50}
]

var batiments_nombre = {
	"dortoir": 5, 
	"cantine": 1, 
	"labo_recherche": 5, 
	"salle_sport": 1, 
	"salle_repos": 1, 
	"generateur_petrole": 3
}

# [Santé, Pollution, Bonheur, Description]
var info_batiments = {
	"dortoir": [100, 5, 80, "Permet de se reposer tranquillement"],  
	"cantine": [80, 10, 70, "Fournit de la nourriture aux habitants"],
	"labo_recherche": [50, 15, 60, "Permet de faire des recherches scientifiques"], 
	"salle_sport": [70, 5, 85, "Améliore la condition physique des habitants"],  
	"salle_repos": [90, 2, 90, "Endroit calme pour se détendre"],       
	"generateur_petrole": [90, 50, -20, "Génère de l'électricité avec du pétrole"] 
}

var stats = {
	"sante": 0,
	"efficacite": 0,
	"bonheur": 0,
	"pollution": 0
}

var environnement = {
	"heure": 0,        # 0 = Jour, 1 = Nuit
	"temperature": 30  # °C
}
