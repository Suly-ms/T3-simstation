extends Node

signal argent_changed(new_value)
signal batiment_changed(batiment_name, new_value)
signal demande_ouverture_info(nom_batiment)
signal demande_fermeture_info()

# FONCTION GET
func get_sante() -> int:
	return Global.stats["sante"];
	
func get_efficacite() -> int:
	return Global.stats["efficacite"];
	
func get_bonheur() -> int:
	return Global.stats["bonheur"];
	
func get_argent() -> int:
	return Global.argent;
	
func get_inventaire() -> Dictionary:
	return Global.inventaire;
	
func get_temperature() -> int:
	return Global.environnement["temperature"];
	
# FONCTION SET
	
func set_sante(sante):
	Global.stats["sante"]=sante;
	
func set_efficacite(efficacite):
	Global.stats["efficacite"]=efficacite;
	
func set_bonheur(bonheur):
	Global.stats["bonheur"]=bonheur;
	
func set_argent(argent):
	Global.argent=argent;
	
func set_stats(stats):
	Global.stats=stats;
	
# FONCTIONS ADD

func add_batiment(nomBatiment, nombre):
	Global.batiments_nombre[nomBatiment] += nombre
	
# AUTRES FONCTIONS
	
func modifier_argent(delta: int) -> void:
	set_argent(get_argent()+delta)
	emit_signal("argent_changed", get_argent())

func modifier_batiment(nom: String, delta: int) -> void:
	var inventaire = get_inventaire()
	if inventaire.has(nom):
		inventaire[nom] += delta
		emit_signal("batiment_changed", nom, inventaire[nom])

# Pour avoir un affichage de l'argent en millier (1 000 000 et pas 1000000)
func format_money(value: int) -> String:
	var s = str(value)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = " " + result  # espace comme séparateur
	return result
