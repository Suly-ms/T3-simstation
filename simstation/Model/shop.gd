extends Control

@onready var batiments_container = $background/ScrollContainer/Batiments

func _ready():
	remplir_labels()

func remplir_labels():
	for batiment_node in batiments_container.get_children():
		var cost_label = batiment_node.get_node("Cost_text")
		var name_label = batiment_node.get_node("Name_text")
		
		var batiment_name = batiment_node.name
		var prix = GlobalScript.get_batiment_prix(batiment_name)
		
		cost_label.bbcode_text = "[center][font_size=48]" + GlobalScript.format_money(prix) + " €"
		name_label.bbcode_text = "[center][font_size=48]" + GlobalScript.get_batiment_info(batiment_name)[3]
		

func _on_exit_button_pressed() -> void:
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")

	if hud.has_node("Shop"):
		hud.get_node("Shop").visible = false
		GlobalScript.set_camera(!GlobalScript.get_camera())


func acheter_batiment(nom_batiment):
	var arbre_scene = load("res://View/buy_confirmation.tscn")
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud") 

	if not hud.has_node("BuyConfirmation"):
		var instance = arbre_scene.instantiate()
		instance.name = "BuyConfirmation"
		instance.batiment = nom_batiment
		hud.add_child(instance)

	else:
		var node = hud.get_node("BuyConfirmation")
		node.visible = !node.visible  


func _on_buy_button_pressed_dortoir() -> void:
	acheter_batiment("dortoir")
	
func _on_buy_button_pressed_cantine() -> void:
	acheter_batiment("cantine")
	
func _on_buy_button_pressed_labo_recherche() -> void:
	acheter_batiment("labo_recherche")

func _on_buy_button_pressed_salle_sport() -> void:
	acheter_batiment("salle_sport")

func _on_buy_button_pressed_salle_repos() -> void:
	acheter_batiment("salle_repos")

func _on_buy_button_pressed_panneaux_solaires() -> void:
	acheter_batiment("panneaux_solaires")

func _on_buy_button_pressed_generateur_petrole() -> void:
	acheter_batiment("generateur_petrole")


#func afficher_description(nom_batiment):
	
