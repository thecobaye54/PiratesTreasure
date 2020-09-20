extends Node

var golds = 0
var canon = 27

export (NodePath) var player_node_path
onready var player = get_node(player_node_path)

func updateUI():
	player.GameUI.update_golds(golds)
	player.GameUI.update_canon(canon)

func add_golds(value : int):
	golds += value
	player.GameUI.update_golds(golds)

func retrieve_golds(value : int):
	var result = golds - value
	if result < 0:
		print("Can't pay")
	else:
		golds = result
		player.GameUI.update_golds(golds)

func add_canon(value : int):
	canon += value
	player.GameUI.update_canon(canon)

func retrieve_canon(value : int):
	var result = canon - value
	if result < 0:
		print("Can't shoot")
	else:
		canon = result
		player.GameUI.update_canon(canon)
