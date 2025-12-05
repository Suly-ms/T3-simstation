extends PanelContainer

var boxContainer = VBoxContainer.new()
var btn_fermer = Button.new()
var label_nom = Label.new()
var label_sante = Label.new()
var label_bonheur = Label.new()
var label_description = Label.new()
var bouton_rech = Button.new()

func _ready():
	set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	offset_right = -20
	grow_horizontal = Control.GROW_DIRECTION_BEGIN
	
	custom_minimum_size.x = 300
	label_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	styliser_labels()
	boxContainer.set_anchors_preset(Control.PRESET_FULL_RECT)
	boxContainer.add_theme_constant_override("separation", 10)
	
	add_child(boxContainer)

	btn_fermer.text = "Fermer (X)"
	btn_fermer.pressed.connect(cacher_infos)
	
	bouton_rech.text = "Ouvrir les recherches"
	bouton_rech.pressed.connect(ouvrir_recherche)
	bouton_rech.hide() 
	
	label_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label_nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER 
	
	boxContainer.add_child(btn_fermer)
	boxContainer.add_child(label_nom)
	boxContainer.add_child(label_sante)
	boxContainer.add_child(label_bonheur)
	boxContainer.add_child(label_description)
	boxContainer.add_child(bouton_rech)
	
	GlobalScript.connect("demande_ouverture_info", Callable(self, "afficher_infos"))
	GlobalScript.connect("demande_fermeture_info", Callable(self, "cacher_infos"))
	
	hide()
func afficher_infos(nom_batiment: String):
	var infos = GlobalScript.get_batiment_info(nom_batiment)
	
	label_nom.text = infos[3]
	
	label_sante.text = "Santé : " + str(infos[0])
	label_bonheur.text = "Bonheur : " + str(infos[1])
	label_description.text = "Description :\n" + str(infos[2])
	
	if nom_batiment == "labo_recherche":
		bouton_rech.show()
	else:
		bouton_rech.hide()
	show() 

func cacher_infos():
	hide()
	
func ouvrir_recherche():
	GameManager.ouvrir_recherche()
	
func styliser_labels():
	var style = LabelSettings.new()
	style.font_size = 18
	style.outline_size = 4
	style.outline_color = Color.BLACK
	
	label_nom.label_settings = style
	
	var style_titre = style.duplicate()
	style_titre.font_size = 24
	style_titre.font_color = Color.YELLOW
	label_nom.label_settings = style_titre
