extends KinematicBody2D

var player = null
export (float) var prox_radius = 50
export (float) var enemy_speed = 15

var is_attacking = false

var health = 3
var offset_rotation = PI/12
var rotation_speed = 0.1
export (PackedScene) var BouletCanon

var can_shoot_left = true
var can_shoot_right = true

func set_player(p : KinematicBody2D):
	player = p

func _physics_process(delta):
	if player != null:
		follow_target(delta)
	if not $Explosion.is_emitting():
		$Explosion.set_visible(false)

func follow_target(delta):
	var direction = player.global_position - global_position
	if not is_attacking:
		set_rotation(direction.angle() + PI/2)
	
	var distance = direction.length()
	if distance > prox_radius:
		is_attacking = false
		move_and_collide(direction.normalized() * enemy_speed * delta)
	else:
		attack()

func attack():
	if not is_attacking:
		is_attacking = true
	
	var direction = player.global_position - global_position
	var test1 = direction.angle() - offset_rotation <= rotation
	var test2 = rotation <= direction.angle() + offset_rotation
	if  (test1 and test2)  or (-direction.angle() + offset_rotation <= rotation and rotation <= -direction.angle() - offset_rotation) :
		shoot()
	else:
		var dest1 = - direction.angle() - rotation
		var dest2 =   direction.angle() - rotation
		var dest = 0
		if abs(dest1) > abs(dest2):
			dest = direction.angle()
		else:
			dest = -direction.angle()
		rotation = lerp_angle(rotation, dest, rotation_speed)
		print(rotation)

func _on_Area2D_body_entered(body : Node):
	if body.is_in_group("BouletCanon") and not body.is_in_group("EnemyShoot"):
		body.queue_free()
		if not $Explosion.is_visible():
			health -= 1
			$Explosion.set_visible(true)
			$Explosion.restart()
		if health == 0:
			yield($Explosion, "visibility_changed")
			queue_free()

func shoot():
	var left_distance = abs((player.global_position - $CanonsL.get_global_position()).length_squared())
	var right_distance = abs((player.global_position - $CanonsR.get_global_position()).length_squared())
	var shoot_offset_diff = 15
	if left_distance < (right_distance + shoot_offset_diff):
		if can_shoot_left:
			shoot_cannons(Vector2.LEFT, "CanonsL")
			can_shoot_left = false
			$CanShootTimerL.start()
	elif right_distance < (left_distance + shoot_offset_diff):
		if can_shoot_right:
			shoot_cannons(Vector2.RIGHT, "CanonsR")
			can_shoot_right = false
			$CanShootTimerR.start()

func shoot_cannons(direction : Vector2, node_path : String):
	var child_1 = BouletCanon.instance()
	var child_2 = BouletCanon.instance()
	
	child_1.position = get_node(node_path + "/Canon1").get_global_position()
	child_2.position = get_node(node_path + "/Canon2").get_global_position()
	
	var children = [ child_1, child_2 ]
	for child in children:
		child.add_to_group("EnemyShoot")
		get_node("..").add_child(child)
		var rot_dir = direction.rotated(transform.get_rotation()).normalized()
		child.set_impulse(rot_dir)


func _on_CanShootTimerL_timeout():
	can_shoot_left = true


func _on_CanShootTimerR_timeout():
	can_shoot_right = true
