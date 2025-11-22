extends Panel

@onready var label_nom = $LabelNom
@onready var label_bonheur = $LabelBonheur
@onready var label_sante = $LabelSante
@onready var label_description = $LabelDescription
@onready var btn_fermer = $BtnFermer

func _ready():
	hide() 
	if btn_fermer: btn_fermer.pressed.connect(cacher_infos)
	
	Global.connect("demande_ouverture_info", Callable(self, "afficher_infos"))
	Global.connect("demande_fermeture_info", Callable(self, "cacher_infos"))

func afficher_infos(nom_batiment: String):
	if label_nom:
		label_nom.text = nom_batiment.capitalize()
	if label_sante:
		label_sante.text = "Santé : "+str(Global.info_batiments.get(nom_batiment)[0])
	if label_bonheur:
		label_bonheur.text = "Bonheur : "+str(Global.info_batiments.get(nom_batiment)[1])
	if label_description:
		label_description.text = "Description :\n"+str(Global.info_batiments.get(nom_batiment)[2])
	
	show()

func cacher_infos():
	hide()
