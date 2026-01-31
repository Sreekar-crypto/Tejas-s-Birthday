extends CharacterBody2D

class_name player

@onready var sprite: AnimatedSprite2D = %sprite
@export var movement_speed : float = 130.0
@export var knockback_force : float
@onready var camera_2d: camera2D = %Camera2D

signal hit_stop
signal attack_entered
signal attack_exited
signal hitting_enemy
signal not_hitting_enemy

var get_enemy_velocity : Vector2

var player_direction : Vector2
var knockback_direction : Vector2
var got_sword_direction : Vector2

var health : float = 100
var knockback_time : float= 0.15
var knockback_timer : float= 0.0

var count : int = 0

var in_knockback : bool= false
var attack_pressed_bool : bool = false
var hit : bool = true

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
		
func knockback(enemy_position: Vector2) -> void:
	in_knockback = true
	knockback_timer = knockback_time
	var dir : Vector2 = global_position - enemy_position
	if (dir.is_zero_approx()):
		if (not player_direction.is_zero_approx()):
			dir -= player_direction
		if (dir.is_zero_approx()):
			dir = Vector2.UP
	knockback_direction = dir.normalized()
	velocity = knockback_direction * knockback_force
	
func _on_eye_hit() -> void:
	health -= 20
	print("player ", health)
	
func _on_sword_enemy_hit() -> void:
	count += 1
	emit_signal("hitting_enemy", got_sword_direction)
	
func _on_sword_not_enemy_hit() -> void:
	emit_signal("not_hitting_enemy")

func _on_eye_touched(enemy_position) -> void:
	camera_2d.screen_shake(4, 0.25)
	knockback(enemy_position)
	await HitStopManager.hit_stop()
	
func _on_sword_sword_direction(sword_direction) -> void:
	got_sword_direction = sword_direction
	
func attack_manager() -> void:
	if (Input.is_action_just_pressed("enter_attack")):
		attack_pressed_bool = !attack_pressed_bool
		if (attack_pressed_bool):
			print("entering attack")
			emit_signal("attack_entered")
		else:
			print("exiting attack")
			emit_signal("attack_exited")
	
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
			
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if (Engine.time_scale == 0):
		return
	if (in_knockback):
		knockback_timer -= delta
		move_and_slide()
		if (knockback_timer <= 0):
			in_knockback = false
		return
	attack_manager()
	encode_direction()
	velocity_calculator()
	animation_handler_player()
	move_and_slide()
