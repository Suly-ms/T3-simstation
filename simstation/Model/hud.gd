extends Control

@onready var argent_label = $CanvasLayer/background/argent
@onready var date_label = $CanvasLayer/background/mois
@onready var temperature_label = $CanvasLayer/background/temperature
@onready var saison_label = $CanvasLayer/background/saison

func _ready():
	$ChartStats.hide()
	GlobalScript.connect("argent_changed", Callable(self, "_on_argent_changed"))
	GlobalScript.connect("tour_change", Callable(self, "_maj_saison"))
	GlobalScript.connect("tour_change", Callable(self, "_maj_mois"))
	_maj_mois()
	_maj_saison()
	_maj_temperature()
	_on_argent_changed(GlobalScript.get_argent())
	
func _maj_mois():
	var tour = GlobalScript.get_tour()
	date_label.text = "[center][font_size=24]Mois "+str(tour*3)
	
func _maj_saison():
	saison_label.text = "[center][font_size=24]" + str(Global.environnement["saison"])
	
func _maj_temperature():
	temperature_label.text = "[center][font_size=24]" + str(Global.environnement["temperature"]) + " C°"
	
func _on_argent_changed(new_value):
	if argent_label:
		argent_label.bbcode_text = "[right][font_size=32]" + GlobalScript.format_money(new_value) + " €"

func _on_passer_tour_pressed():
	CalculStats.passer_tour()
	_maj_temperature()
	GlobalScript.emit_signal("tour_change")

func _on_btn_graphique_stats_pressed() -> void:
	$ChartStats.show()
	#GameManager.load_scene("res://View/chart_stats.tscn", "CharStats")
