extends Control

@onready var argent_label = $CanvasLayer/background/argent
@onready var date_label = $CanvasLayer/background/mois

func _ready():
	$ChartStats.hide()
	GlobalScript.connect("argent_changed", Callable(self, "_on_argent_changed"))
	GlobalScript.connect("tour_change", _maj_mois)
	_maj_mois()
	_on_argent_changed(GlobalScript.get_argent())
	CalculStats.actualiser_stats_derivees()
	
func _maj_mois():
	date_label.text = "[center][font_size=24]Mois "+str(GlobalScript.get_tour()*3)
	
func _on_argent_changed(new_value):
	if argent_label:
		argent_label.bbcode_text = "[right][font_size=24]" + GlobalScript.format_money(new_value) + " €"

func _on_passer_tour_pressed():
	CalculStats.passer_tour()
	GlobalScript.emit_signal("tour_change")

func _on_btn_graphique_stats_pressed() -> void:
	$ChartStats.show()
	#GameManager.load_scene("res://View/chart_stats.tscn", "CharStats")
