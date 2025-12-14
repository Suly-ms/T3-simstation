extends RichTextLabel

# Vitesse de défilement en pixels par seconde
const SCROLL_SPEED = 50.0 

var scroll_finished = false

func _ready():
	# S'assurer que le texte est bien visible au début
	# (Met la barre de défilement en haut)
	if is_instance_valid(get_v_scroll_bar()):
		get_v_scroll_bar().value = 0.0

# Fonction principale appelée à chaque frame
func _process(delta):
	if scroll_finished:
		return

	# Étape 1: Récupérer le nœud interne de la barre de défilement (VScrollBar)
	var v_scrollbar = get_v_scroll_bar()

	# Vérification de sécurité
	if not is_instance_valid(v_scrollbar):
		return

	# Propriétés de la Scrollbar en Godot 4
	var current_scroll = v_scrollbar.value
	var max_scroll = v_scrollbar.max_value

	# Étape 2: Vérifier si le défilement est terminé (doit défiler uniquement s'il y a du contenu)
	if max_scroll > 0 and current_scroll < max_scroll:
		
		# 3. Calcul de la nouvelle position basée sur la vitesse et le temps (delta)
		var new_scroll_position = current_scroll + SCROLL_SPEED * delta
		
		# 4. On s'assure de ne pas dépasser la position maximale
		new_scroll_position = min(new_scroll_position, max_scroll)
		
		# Étape 5: Appliquer la nouvelle position en modifiant la PROPRIÉTÉ VALUE de la VScrollBar.
		# C'est la clé de la solution.
		v_scrollbar.value = new_scroll_position

	# Si le défilement a atteint ou dépassé la fin, on arrête
	elif max_scroll > 0 and current_scroll >= max_scroll:
		scroll_finished = true
		print("Défilement des crédits terminé !")
		# Logique de fin ici
