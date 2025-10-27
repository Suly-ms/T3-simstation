extends Control

signal changement_etat
signal passer_mois

@onready var nombre_mois = $CanvasLayer/background/NombreMois
@onready var date = $CanvasLayer/background/date
@onready var temperature = $CanvasLayer/background/date/temperature

func _ready() -> void:
	var datetime = Time.get_datetime_dict_from_system()
	Global.stats["date"]["jour"] = datetime["day"]
	Global.stats["date"]["mois"] = datetime["month"]
	Global.stats["date"]["annee"] = datetime["year"]
	

func _process(_delta: float) -> void:
	nombre_mois.text = "[right][font_size=24]"+str(Global.stats["nombre_de_mois"]) + " Mois"
	date.text = "[right][font_size=24]"+"%02d/%02d/%04d" % [Global.stats["date"]["jour"], Global.stats["date"]["mois"], Global.stats["date"]["annee"]]
	temperature.text = "[right][font_size=24]"+str(Global.environnement["temperature"])+" °"

func _on_ajouter_population_pressed():
	Global.population.append({
		"sante": 0,
		"efficacite": 0,
		"bonheur": 0
	})
	emit_signal("changement_etat")

func _on_ajouter_batiment_pressed():
	Global.batiments_nombre["cantine"] += 1
	emit_signal("changement_etat")

func _on_ajouter_temperature_pressed():
	Global.environnement["temperature"] += 1
	emit_signal("changement_etat")
	
func _on_passer_mois_pressed() -> void:
	Global.stats["date"] = ajouter_trois_mois(Global.stats["date"])
	emit_signal("passer_mois")
	
func ajouter_trois_mois(p_date: Dictionary) -> Dictionary:
	var nouvelle_date = p_date.duplicate()
	nouvelle_date["mois"] += 3

	# Gestion du dépassement d'année
	if nouvelle_date["mois"] > 12:
		nouvelle_date["annee"] += 1
		nouvelle_date["mois"] -= 12

	# Vérification du nombre de jours dans le nouveau mois
	var jours_dans_mois = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	# Gestion des années bissextiles pour février
	if nouvelle_date["annee"] % 4 == 0 and (nouvelle_date["annee"] % 100 != 0 or nouvelle_date["annee"] % 400 == 0):
		jours_dans_mois[1] = 29

	# Ajustement du jour si nécessaire
	if nouvelle_date["jour"] > jours_dans_mois[nouvelle_date["mois"] - 1]:
		nouvelle_date["jour"] = jours_dans_mois[nouvelle_date["mois"] - 1]

	return nouvelle_date
