extends Node

# ------------------------------------------------------------------------------
# INTERFACE GLOBALE (VERSION TOUR PAR TOUR)
# ------------------------------------------------------------------------------

signal argent_changed(new_value)
signal batiment_changed(batiment_name, new_value)
signal stats_updated() 

# GET

func get_sante() -> int: return Global.stats["sante"]
func get_efficacite() -> int: return Global.stats["efficacite"]
func get_bonheur() -> int: return Global.stats["bonheur"]
func get_argent() -> int: return Global.argent
func get_inventaire() -> Dictionary: return Global.inventaire
func get_camera() -> bool: return Global.camera_enable

# Gestion du temps / Tour
func get_tour() -> int: return Global.tour["nombre de tours"]
func get_temperature() -> int: return Global.environnement["temperature"]

# Gestion Batiments
func get_batiment_prix(nom) -> int: return Global.batiments_prix[nom]
func get_batiment_info(nom): return Global.info_batiments[nom]
func get_batiments_counts() -> Dictionary: return Global.batiments_nombre
func get_batiments_data() -> Dictionary: return Global.info_batiments
func get_population() -> Array: return Global.population

# SET

func set_sante(val): Global.stats["sante"] = val
func set_efficacite(val): Global.stats["efficacite"] = val
func set_bonheur(val): Global.stats["bonheur"] = val
func set_argent(val): Global.argent = val
func set_camera(val): Global.camera_enable = val

func set_tour(val: int):
	Global.tour["nombre de tours"] = val
	
func set_temperature(val: int):
	Global.environnement["temperature"] = val

# LOGIQUE METIER

func add_batiment(nomBatiment, nombre):
	if Global.batiments_nombre.has(nomBatiment):
		Global.batiments_nombre[nomBatiment] += nombre

func modifier_argent(delta: int) -> void:
	set_argent(get_argent() + delta)
	emit_signal("argent_changed", get_argent())

func modifier_batiment(nom: String, delta: int) -> void:
	var inventaire = get_inventaire()
	if inventaire.has(nom):
		inventaire[nom] += delta
		emit_signal("batiment_changed", nom, inventaire[nom])

# Applique les stats globales à chaque individu (lissage)
func update_population_stats(sante: float, bonheur: float, efficacite: float) -> void:
	for habitant in Global.population:
		habitant["sante"] = lerp(float(habitant["sante"]), sante, 0.8) # 0.8 car le changement est brutal sur 3 mois
		habitant["bonheur"] = lerp(float(habitant["bonheur"]), bonheur, 0.8)
		habitant["efficacite"] = efficacite
	emit_signal("stats_updated")

func format_money(value: int) -> String:
	var s = str(value)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = " " + result
	return result
