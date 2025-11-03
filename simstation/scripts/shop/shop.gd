extends Control
signal exit_button(shop_name)

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
