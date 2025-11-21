extends Panel

@onready var label_nom = $LabelNom
@onready var label_bonheur = $LabelBonheur
@onready var label_sante = $"LabelSante"
@onready var btn_fermer = $BtnFermer

func _ready():
	hide() # Caché au départ
	if btn_fermer: btn_fermer.pressed.connect(cacher_infos)
	
	# --- C'EST ICI QUE LA CONNEXION SE FAIT ---
	# On dit : "Quand Global crie 'demande_ouverture', lance ma fonction 'afficher_infos'"
	Global.connect("demande_ouverture_info", Callable(self, "afficher_infos"))
	Global.connect("demande_fermeture_info", Callable(self, "cacher_infos"))

func afficher_infos(nom_batiment: String):
	# Si tu as besoin de charger des données spécifiques (ex: production, coût),
	# tu peux le faire ici en utilisant le 'nom_batiment' comme clé.
	if label_nom:
		label_nom.text = nom_batiment.capitalize()
	if label_bonheur:
		label_bonheur.text = str(Global.info_batiments.get(nom_batiment)[1])
	if label_sante:
		label_sante.text = str(Global.info_batiments.get(nom_batiment)[0])
	
	show() # On affiche le panneau

func cacher_infos():
	hide()
