extends Node

export (PackedScene) var player_ship_prefab

export (NodePath) var GameUI_path

var wind_direction = Vector2.RIGHT
var wind_force = 10

func _ready():
	set_wind()
	random_wind_timer()

func set_wind():
	$Ship.set_wind_attributes(wind_direction, wind_force)
	$GUILayer/GameUI.set_wind_arrow_rotation(rad2deg(wind_direction.angle()) + 90)

func random_wind_timer():
	$WindTimer.wait_time = 10 + randi() % 21
	$WindTimer.start()

func _on_WindTimer_timeout():
	wind_direction = Vector2(randf(), randf()).normalized()
	wind_force = rand_range(10, 20)
	set_wind()
	random_wind_timer()
