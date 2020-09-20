extends Sprite

var has_chest = false
var chest_opened = false
var golds = 0
var boulets = 0

var player_in_area = false
var player_interact = false

var player = null

export (NodePath) var CoinLabel_path
export (NodePath) var CanonLabel_path

func _ready():
	randomize()
	has_chest = randi() % 2
	golds = randi() % 11
	boulets = randi() % 5
	$Coffre.set_visible(has_chest)
	
	if has_chest:
		get_node(CoinLabel_path).text = str(golds)
		get_node(CanonLabel_path).text = str(boulets)
	
	
func _process(delta):
	if has_chest and not chest_opened:
		if player_in_area:
			manage_input()
		if player_interact:
			player.GameUI.set_game_hint_progress((1-($InteractTimer.time_left/$InteractTimer.wait_time))*100)

func manage_input():
	if Input.is_action_just_pressed("player_interact"):
		player_interact = true
		$InteractTimer.start()
	if Input.is_action_just_released("player_interact"):
		player_interact = false
		$InteractTimer.stop()

func _on_Area2D_body_entered(body : Node):
	if has_chest and not chest_opened:
		if body.is_in_group("Player"):
			player_in_area = true
			player_interact = false
			player = body
			player.GameUI.show_game_hint("E", "Interact")

func _on_Area2D_body_exited(body : Node):
	if has_chest and not chest_opened:
		if body.is_in_group("Player"):
			player_in_area = true
			player_interact = false
			player.GameUI.hide_game_hint()
			player = null

func _on_InteractTimer_timeout():
	if player_interact:
		player.GameUI.hide_game_hint()
		$Coffre.play("open")
		player.inventory.add_golds(golds)
		player.inventory.add_canon(boulets)
		$AnimationPlayer.play("coin_reveal")
		chest_opened = true
