extends Control

func _process(delta):
	$barreEtat/efficacite/LabelEfficacite.text = str(Global.efficacite) + "/100"
	$barreEtat/santeMentale/LabelSanteMentale.text = str(Global.santeMentale) + "/100"
	$barreEtat/environnement/LabelEnvironnement.text = str(Global.environement) + "/100"
	$barreEtat/sante/LabelSante.text = str(Global.sante) + "/100"
