extends Control

@onready var argent_label = $argent
@onready var batiments_container = $dragBuilding

func _ready():
	# Connecte les signaux
	Global.connect("argent_changed", Callable(self, "_on_argent_changed"))
	Global.connect("batiment_changed", Callable(self, "_on_batiment_changed"))
	
	# Mets à jour directement l'affichage au lancement
	_on_argent_changed(Global.argent)
	for nom in Global.batiments_nombre.keys():
		_on_batiment_changed(nom, Global.batiments_nombre[nom])

func _on_argent_changed(new_value):
	if argent_label:
		argent_label.bbcode_text = "[right][font_size=24]" + Global.format_money(new_value) + " €"

func _on_batiment_changed(nom, new_value):
	if batiments_container:
		var batiment_node = batiments_container.get_node(nom)
		if batiment_node:
			var nombre_label = batiment_node.get_node("nombre")
			if nombre_label:
				nombre_label.bbcode_text = str(new_value)
