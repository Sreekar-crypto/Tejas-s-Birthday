extends AnimatedSprite2D
func _ready() -> void:
	SignalBus.velocity_eye.connect(velocity_value)

func velocity_value() -> void: pass

func _process(delta: float) -> void:
	on_velocity_recieved()
		if velocity == Vector2.ZERO:
			if current_direction == Vector2.UP:
				if sprite.animation != "idle_up": sprite.play("idle_up")
			elif current_direction == Vector2.DOWN:
				if sprite.animation != "idle_down": sprite.play("idle_down")
			elif current_direction == Vector2.RIGHT:
				if sprite.animation != "idle_right": sprite.play("idle_right")
			elif current_direction == Vector2.LEFT:
				if sprite.animation != "idle_left": sprite.play("idle_left")
		elif velocity != Vector2.ZERO:
			if current_direction == Vector2.UP:
				if sprite.animation != "walk_up": sprite.play("walk_up")
			elif current_direction == Vector2.DOWN:
				if sprite.animation != "walk_down": sprite.play("walk_down")
			elif current_direction == Vector2.RIGHT:
				if sprite.animation != "walk_right": sprite.play("walk_right")
			elif current_direction == Vector2.LEFT:
				if sprite.animation != "walk_left": sprite.play("walk_left")
