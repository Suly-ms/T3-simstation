extends Control

signal changement_etat

var rng = RandomNumberGenerator.new()

func _on_ajouter_population_pressed():
	Global.population.append({
		"sante": rng.randi_range(10, 100),
		"efficacite": rng.randi_range(50, 100),
		"bonheur": rng.randi_range(50, 100)
	})
	emit_signal("changement_etat")

func _on_ajouter_batiment_pressed():
	Global.batiments_nombre["cantine"] += 1
	emit_signal("changement_etat")

func _on_ajouter_temperature_pressed():
	Global.environnement["temperature"] += 1
	emit_signal("changement_etat")
