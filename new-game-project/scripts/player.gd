extends CharacterBody2D


@export var movement_speed : float = 130.0
var character_direction : Vector2
@onready var sprite: AnimatedSprite2D = %sprite

enum movement_direction {up, down, left, right, nun}
var default_direction := movement_direction.nun

func _physics_process(delta: float) -> void:
	character_direction = Input.get_vector("move_left_td", "move_right_td", "move_up_td", "move_down_td", 0.2)
	if character_direction.x > 0: default_direction = movement_direction.right
	elif character_direction.x < 0: default_direction= movement_direction.left
	
	if character_direction.y < 0: default_direction = movement_direction.up
	elif character_direction.y > 0: default_direction = movement_direction.down
	
	
	if character_direction and not Input.is_action_pressed("shift"):
		velocity = character_direction * movement_speed
	elif character_direction and Input.is_action_pressed("shift"):
		velocity = character_direction * (movement_speed * 2)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed-100.0)
		
	if character_direction != Vector2.ZERO:
		if default_direction == movement_direction.up:
			if sprite.animation != "walk_up": sprite.animation = "walk_up"
		elif default_direction == movement_direction.down:
			if sprite.animation != "walk_down": sprite.animation = "walk_down"
		elif default_direction == movement_direction.right:
			if sprite.animation != "walk_right": sprite.animation = "walk_right"
		elif default_direction == movement_direction.left:
			if sprite.animation != "walk_left": sprite.animation = "walk_left"
	elif character_direction == Vector2.ZERO:
		if default_direction == movement_direction.up:
			if sprite.animation != "idle_up": sprite.animation = "idle_up"
		elif default_direction == movement_direction.down:
			if sprite.animation != "idle_down": sprite.animation = "idle_down"
		elif default_direction == movement_direction.right:
			if sprite.animation != "idle_right": sprite.animation = "idle_right"
		elif default_direction == movement_direction.left:
			if sprite.animation != "idle_left": sprite.animation = "idle_left"
	move_and_slide()
