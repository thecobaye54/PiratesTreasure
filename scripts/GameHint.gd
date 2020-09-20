extends Control

func set_progress(value : float):
	$HBoxContainer/TextureProgress.set_value(value)

func set_attributes(commande : String, desc : String):
	$HBoxContainer/TextureProgress/Label.set_text(commande)
	$HBoxContainer/Label.set_text(desc)
	set_progress(0)
