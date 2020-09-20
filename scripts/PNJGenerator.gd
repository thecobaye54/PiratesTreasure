extends Node

export (PackedScene) var EnemyShipPrefab
export (NodePath) var Player_path
onready var player = get_node(Player_path)

export (float) var spawn_radius = 100

func _ready():
	randomize()
	set_random_timer()

func _on_SpawnTimer_timeout():
	var instance = EnemyShipPrefab.instance()
	var pos = player.global_position + Vector2(rand_range(-spawn_radius, spawn_radius), rand_range(-spawn_radius, spawn_radius))
	instance.set_position(pos)
	owner.add_child(instance)
	instance.set_player(player)
	set_random_timer()

func set_random_timer():
	$SpawnTimer.wait_time = 20 + randi() % 11
	$SpawnTimer.start()
