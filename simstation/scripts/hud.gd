extends Control

signal changement_etat

func _on_ajouter_population_pressed():
	Global.population.append({
		"sante": 0,
		"efficacite": 20,
		"bonheur": 20
	})
	emit_signal("changement_etat")

func _on_ajouter_batiment_pressed():
	Global.batiments_nombre["cantine"] += 1
	emit_signal("changement_etat")

func _on_ajouter_temperature_pressed():
	Global.environnement["temperature"] += 1
	emit_signal("changement_etat")
