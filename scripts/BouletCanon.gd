extends RigidBody2D

export (float) var impulse_force = 20000

var rb_impulse = Vector2()

func set_impulse(impulse_dir : Vector2):
	rb_impulse = impulse_dir * impulse_force

func _on_ImpulseTimer_timeout():
	apply_central_impulse(rb_impulse)

func _on_ParticleTimer_timeout():
	$Particles2D.set_emitting(false)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
