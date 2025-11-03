extends TextureButton

func _on_pressed():
	var nom_batiment = Global.batiment_en_cours_achat
	var prix = Global.batiments_prix[nom_batiment]
	
	print("Argent avant achat : ", Global.argent)
	print("Nombre de ", nom_batiment, " avant achat : ", Global.inventaire[nom_batiment])
	
	Global.modifier_argent(-prix)
	Global.modifier_batiment(nom_batiment, 1)
	
	
	print("Argent après achat : ", Global.argent)
	print("Nombre de ", nom_batiment, " après achat : ", Global.inventaire[nom_batiment])
	
	var node = self
	while node.get_parent() != get_tree().current_scene:
		node = node.get_parent()
	node.queue_free()  # ferme la popup
