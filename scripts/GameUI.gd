extends Control

export (NodePath) var Boulets_L
export (NodePath) var Boulets_R

export (NodePath) var GameHint_path
export (NodePath) var GoldsLabel_path
export (NodePath) var CanonLabel_path
export (NodePath) var HealthLabel_path

export (NodePath) var GameOverPanel_path

export (Array, Texture) var sail_state
export (NodePath) var SailIndicator_path

enum BOULETS {
	BOULET_R,
	BOULET_L
}

func update_boulet_timer(side, value : float):
	match side:
		BOULETS.BOULET_L:
			get_node(Boulets_L).get_node("TextureProgress").value = value
		BOULETS.BOULET_R:
			get_node(Boulets_R).get_node("TextureProgress").value = value

func set_wind_arrow_rotation(value : float):
	$WindArrow.rect_rotation = value

func show_game_hint(commande : String, desc : String):
	get_node(GameHint_path).set_attributes(commande, desc)
	get_node(GameHint_path).set_visible(true) 

func hide_game_hint():
	get_node(GameHint_path).set_visible(false)

func set_game_hint_progress(value : float):
	get_node(GameHint_path).set_progress(value)

func update_golds(value : int):
	get_node(GoldsLabel_path).text = str(value)

func update_canon(value : int):
	get_node(CanonLabel_path).text = str(value)

func update_health(value : int):
	get_node(HealthLabel_path).text = str(value)
	
func game_over():
	get_node(GameOverPanel_path).set_visible(true)
	get_tree().paused = true

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_RestartButton_pressed():
	get_tree().change_scene("res://World.tscn")

func update_sail(value : int):
	get_node(SailIndicator_path).texture = sail_state[value]
