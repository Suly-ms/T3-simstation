extends Panel

# DESCRIPTION :
# Script permettant d'afficher un panel d'information d'un batiment quand on clique dessus
# On y affiche : le nom, la santé, le bonheur et une descrption

@onready var label_nom = $LabelNom
@onready var label_bonheur = $LabelBonheur
@onready var label_sante = $LabelSante
@onready var label_description = $LabelDescription
@onready var btn_fermer = $BtnFermer

func _ready():
	hide() 
	if btn_fermer: btn_fermer.pressed.connect(cacher_infos)
	
	GlobalScript.connect("demande_ouverture_info", Callable(self, "afficher_infos"))
	GlobalScript.connect("demande_fermeture_info", Callable(self, "cacher_infos"))

func afficher_infos(nom_batiment: String):
	if label_nom:
		label_nom.text = nom_batiment.capitalize()
	if label_sante:
		label_sante.text = "Santé : "+str(GlobalScript.get_batiment_info(nom_batiment)[0])
	if label_bonheur:
		label_bonheur.text = "Bonheur : "+str(GlobalScript.get_batiment_info(nom_batiment)[1])
	if label_description:
		label_description.text = "Description :\n"+str(GlobalScript.get_batiment_info(nom_batiment)[2])
	
	show()

func cacher_infos():
	hide()
