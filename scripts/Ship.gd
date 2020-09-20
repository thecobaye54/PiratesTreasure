extends KinematicBody2D

const FROTTEMENT_EAU = 0.05
const VIT_LITTLE_SAIL = 20
const VIT_MIN_LITTLE_SAIL = 14
const VIT_MAIN_SAIL = 50
const VIT_MIN_MAIN_SAIL = 40

export (NodePath) var WorldPath
var GameUI = null

var velocity = 0
var player_speed = 0
export (float) var rotate_speed = 1
var current_rot_speed = 0.02

var wind_force = 0
var wind_direction = Vector2()

enum {
	NO_SAIL,
	LITTLE_SAIL,
	MAIN_SAIL
}

var sail_state = NO_SAIL

export (PackedScene) var BouletCanon
var shoot_offset_diff = 15

var can_shoot_right = true
var can_shoot_left = true

export (NodePath) var inventory_path
onready var inventory = get_node(inventory_path)

var health = 3

func _ready():
	GameUI = get_node(WorldPath).get_node(get_node(WorldPath).GameUI_path)
	inventory.updateUI()
	
# warning-ignore:unused_argument
func _process(delta):
	manage_input()
	if not can_shoot_left:
		GameUI.update_boulet_timer(GameUI.BOULETS.BOULET_L, (1-($CanShootTimerL.get_time_left() / $CanShootTimerL.wait_time))*100)
	if not can_shoot_right:
		GameUI.update_boulet_timer(GameUI.BOULETS.BOULET_R, (1-($CanShootTimerR.get_time_left() / $CanShootTimerR.wait_time))*100)
	if not $Explosion.is_emitting():
		$Explosion.set_visible(false)

func _physics_process(delta):	
	var direction = -Vector2(0, 1).rotated(transform.get_rotation()).normalized()
	manage_velocity(direction)
	move_and_collide(direction * player_speed * delta)
	
func manage_velocity(direction):
	var coef_dot = wind_direction.dot(direction)
	
	match sail_state:
		NO_SAIL:
			player_speed = lerp(player_speed, 0, FROTTEMENT_EAU)
			current_rot_speed = rotate_speed * 2
		LITTLE_SAIL:
			if coef_dot < 0:
				player_speed = lerp(player_speed, VIT_MIN_LITTLE_SAIL, FROTTEMENT_EAU)
			else:
				player_speed += coef_dot * wind_force * 0.4
			if player_speed > VIT_LITTLE_SAIL:
				player_speed = VIT_LITTLE_SAIL
			current_rot_speed = rotate_speed * 1.5
		MAIN_SAIL:
			if coef_dot < 0:
				player_speed = lerp(player_speed, VIT_MIN_MAIN_SAIL, FROTTEMENT_EAU)
			else:
				player_speed += coef_dot * wind_force
			if player_speed > VIT_MAIN_SAIL:
				player_speed = VIT_MAIN_SAIL

func manage_input():
	if Input.is_action_just_released("ui_up"):
		match sail_state:
			NO_SAIL:
				sail_state = LITTLE_SAIL
			LITTLE_SAIL:
				sail_state = MAIN_SAIL
		GameUI.update_sail(sail_state)
	
	if Input.is_action_just_released("ui_down"):
		match sail_state:
			LITTLE_SAIL:
				sail_state = NO_SAIL	
			MAIN_SAIL:
				sail_state = LITTLE_SAIL
		GameUI.update_sail(sail_state)
	
	if Input.is_action_pressed("ui_left"):
		rotate_ship(-1)
	if Input.is_action_pressed("ui_right"):
		rotate_ship(+1)
	
	if Input.is_action_just_released("player_shoot"):
		shoot()
	
func set_wind_attributes(direction : Vector2, force : float):
	wind_direction = direction
	wind_force = force

func rotate_ship(direction):
	rotate(direction * current_rot_speed)

func shoot():
	if (inventory.canon >= 3):
		var left_distance = abs((get_global_mouse_position() - $CanonsL.get_global_position()).length_squared())
		var right_distance = abs((get_global_mouse_position() - $CanonsR.get_global_position()).length_squared())
	
		if left_distance < (right_distance + shoot_offset_diff):
			if can_shoot_left:
				shoot_cannons(Vector2.LEFT, "CanonsL")
				can_shoot_left = false
				$CanShootTimerL.start()
				GameUI.update_boulet_timer(GameUI.BOULETS.BOULET_L, 0)
		elif right_distance < (left_distance + shoot_offset_diff):
			if can_shoot_right:
				shoot_cannons(Vector2.RIGHT, "CanonsR")
				can_shoot_right = false
				$CanShootTimerR.start()
				GameUI.update_boulet_timer(GameUI.BOULETS.BOULET_R, 0)

func shoot_cannons(direction : Vector2, node_path : String):
	var child_1 = BouletCanon.instance()
	var child_2 = BouletCanon.instance()
	var child_3 = BouletCanon.instance()
	
	child_1.position = get_node(node_path + "/Canon1").get_global_position()
	child_2.position = get_node(node_path + "/Canon2").get_global_position()
	child_3.position = get_node(node_path + "/Canon3").get_global_position()
	
	var children = [ child_1, child_2, child_3 ]
	for child in children:
		get_node(WorldPath).add_child(child)
		var rot_dir = direction.rotated(transform.get_rotation()).normalized()
		child.set_impulse(rot_dir)
	inventory.retrieve_canon(3)

func _on_CanShootTimerR_timeout():
	can_shoot_right = true

func _on_CanShootTimerL_timeout():
	can_shoot_left = true

func _on_Area2D_body_entered(body : Node):
	if body.is_in_group("BouletCanon") and body.is_in_group("EnemyShoot"):
		body.queue_free()
		if not $Explosion.is_visible():
			health -= 1
			GameUI.update_health(health)
			$Explosion.set_visible(true)
			$Explosion.restart()
		if health == 0:
			yield($Explosion, "visibility_changed")
			GameUI.game_over()
