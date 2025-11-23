extends Node

signal argent_changed(new_value)
signal batiment_changed(batiment_name, new_value)
signal demande_ouverture_info(nom_batiment)
signal demande_fermeture_info()

var camera_enable = true;
var user = {"nom":"Martin","time":3}

var population = [
	{"sante": 100, "efficacite": 100, "bonheur": 50}
]

var recherche_debloque = []

var argent = 3000000

# ce que le joueur possède
var inventaire = {
	"hub": 1,
	"dortoir": 0, 
	"cantine": 1, 
	"labo_recherche": 0, 
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
	"dortoir": [100, 80, "Permet de se reposer tranquillement", "Dortoir"],  
	"cantine": [80, 70, "Fournit de la nourriture aux habitants", "Cantine"],
	"labo_recherche": [50, 60, "Permet de faire des recherches scientifiques", "Laboratoire de recherche"], 
	"salle_sport": [70, 85, "Améliore la condition physique des habitants", "Salle de sport"],  
	"salle_repos": [90, 90, "Endroit calme pour se détendre", "Salle de repos"],    
	"panneaux_solaires": [90, 90, "Génère de l'électricité avec le Soleil", "Panneau solaire"],   
	"generateur_petrole": [50, -20, "Génère de l'électricité avec du pétrole", "Générateur de pétrole"] 
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

var tour = {
	"nombre de tours": 0,       # chaque tours 3 mois 
}

func modifier_argent(delta: int) -> void:
	argent += delta
	emit_signal("argent_changed", argent)

func modifier_batiment(nom: String, delta: int) -> void:
	if inventaire.has(nom):
		inventaire[nom] += delta
		emit_signal("batiment_changed", nom, inventaire[nom])


# Pour avoir un affichage de la thune en millier (1 000 000 et pas 1000000)
func format_money(value: int) -> String:
	var s = str(value)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = " " + result  # espace comme séparateur
	return result
