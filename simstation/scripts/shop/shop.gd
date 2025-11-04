extends Control
signal exit_button(shop_name)
signal afficher_scene(chemin_scene, nom_node)

@onready var batiments_container = $background/ScrollContainer/Batiments

func _ready():
	remplir_labels()

func remplir_labels():
	for batiment_node in batiments_container.get_children():
		var cost_label = batiment_node.get_node("Cost_text")
		var batiment_name = batiment_node.name  
		
		var prix = Global.batiments_prix[batiment_name]
		cost_label.bbcode_text = Global.format_money(prix) + " €"  

func _on_exit_button_pressed() -> void:
	emit_signal("exit_button", "Shop")

func buy_button(nom_batiment):
	if (Global.argent - Global.batiments_prix[nom_batiment] >= 0):
		print("Bouton cliqué : ", nom_batiment) 
		var prix = Global.batiments_prix[nom_batiment]
		Global.modifier_argent(-prix)
		Global.modifier_batiment(nom_batiment, 1)
	else :
		print("Vous n'avez pas les fonds nécessaires")

func _on_buy_button_pressed() -> void:
	emit_signal("afficher_scene", "res://scenes/buy_confirmation.tscn", "BuyConfirmation")
	buy_button("cantine")
