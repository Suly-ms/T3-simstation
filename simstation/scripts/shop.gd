extends Control

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
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud")

	if hud.has_node("Shop"):
		hud.get_node("Shop").visible = false
		Global.camera_enable = !Global.camera_enable

func _on_buy_button_pressed() -> void:
	var arbre_scene = load("res://scenes/buy_confirmation.tscn")
	var play_scene = get_tree().current_scene
	var hud = play_scene.get_node("hud") 

	if not hud.has_node("BuyConfirmation"):
		var instance = arbre_scene.instantiate()
		instance.name = "BuyConfirmation"
		instance.batiment = "cantine"
		hud.add_child(instance)

	else:
		var node = hud.get_node("BuyConfirmation")
		node.visible = !node.visible  

	Global.camera_enable = !Global.camera_enable
