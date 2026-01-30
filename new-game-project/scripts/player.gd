extends CharacterBody2D

class_name player

@onready var sprite: AnimatedSprite2D = %sprite

@export var movement_speed : float = 130.0
@export var knockback_force : float

var get_enemy_velocity : Vector2

var player_direction : Vector2
var knockback_direction : Vector2

enum movement_direction {UP, DOWN, LEFT, RIGHT, NON}

var default_direction := movement_direction.NON

func encode_direction() -> void:
	player_direction = Input.get_vector("move_left_td", "move_right_td", "move_up_td", "move_down_td", 0.2)
	
	if player_direction.x > 0: default_direction = movement_direction.RIGHT
	elif player_direction.x < 0: default_direction = movement_direction.LEFT
		
	if player_direction.y < 0: default_direction = movement_direction.UP
	elif player_direction.y > 0: default_direction = movement_direction.DOWN

func velocity_calculator() -> void:
	if player_direction and not Input.is_action_pressed("shift"):
		velocity = player_direction * movement_speed
	elif player_direction and Input.is_action_pressed("shift"):
		velocity = player_direction * (movement_speed * 2)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed-100.0)
		
func _on_eye_touched(enemy_velocity) -> void:
	knockback(enemy_velocity)
	
func knockback(enemy_velocity) -> void:
	knockback_direction = (enemy_velocity - velocity).normalized() * knockback_force
	velocity = knockback_direction
	print_debug(velocity)
	print_debug(position)
	move_and_slide()
	print_debug(velocity)
	print_debug(position)
	
func animation_handler_player() -> void:
	if player_direction != Vector2.ZERO:
		if default_direction == movement_direction.UP:
			if sprite.animation != "walk_up": sprite.animation = "walk_up"
		elif default_direction == movement_direction.DOWN:
			if sprite.animation != "walk_down": sprite.animation = "walk_down"
		elif default_direction == movement_direction.RIGHT:
			if sprite.animation != "walk_right": sprite.animation = "walk_right"
		elif default_direction == movement_direction.LEFT:
			if sprite.animation != "walk_left": sprite.animation = "walk_left"
	elif player_direction == Vector2.ZERO:
		if default_direction == movement_direction.UP:
			if sprite.animation != "idle_up": sprite.animation = "idle_up"
		elif default_direction == movement_direction.DOWN:
			if sprite.animation != "idle_down": sprite.animation = "idle_down"
		elif default_direction == movement_direction.RIGHT:
			if sprite.animation != "idle_right": sprite.animation = "idle_right"
		elif default_direction == movement_direction.LEFT:
			if sprite.animation != "idle_left": sprite.animation = "idle_left"

func _physics_process(delta: float) -> void:
	encode_direction()
	velocity_calculator()
	animation_handler_player()
	move_and_slide()
