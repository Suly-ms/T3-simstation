extends Control

@onready var argent_label = $CanvasLayer/background/argent

func _ready():
	GlobalScript.connect("argent_changed", Callable(self, "_on_argent_changed"))
	_on_argent_changed(GlobalScript.get_argent())
	CalculStats._calculer_saison_et_meteo()
	CalculStats._appliquer_changements_tour()
	CalculStats.actualiser_stats_derivees()
	
func _on_argent_changed(new_value):
	if argent_label:
		argent_label.bbcode_text = "[right][font_size=24]" + GlobalScript.format_money(new_value) + " €"

func _on_passer_tour_pressed():
	CalculStats.passer_tour()
