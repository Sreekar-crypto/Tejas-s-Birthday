extends CharacterBody2D

class_name enemy_eye

@export var movement_speed : float = 130.0
@export var player_target : PackedScene
var movement_direction : Vector2
var movement : bool = true
var character_direction : Vector2
var current_direction : Vector2
var velocity_movement : Vector2
var found_player : bool = false
var target
var last_position : Vector2
var target_direction : Vector2
@onready var detection: Sprite2D = %detection
@onready var sprite: AnimatedSprite2D = %sprite


enum direction {up, down, left, right, non}
enum move {yes, no}
var default_direction : direction = direction.non
var default_move : move = move.no

func matching_enum() -> void:
	match default_move:
		move.yes:
			movement = true
		move.no:
			movement = false
	match default_direction:
		direction.up:
			character_direction = Vector2.UP
		direction.down:
			character_direction = Vector2.DOWN
		direction.left:
			character_direction = Vector2.LEFT
		direction.right:
			character_direction = Vector2.RIGHT
		direction.non:
			character_direction = Vector2.ZERO


func movement_or_not() -> void:
	while true:
		default_move = move.values().pick_random()
		var timed_movement : Array = [10, 15, 20, 25, 30, 35, 40]
		var time = timed_movement.pick_random()
		await get_tree().create_timer(time).timeout

func movement_axis() -> void:
	matching_enum()
	while true:
		var timed_movement : Array = [1, 2, 3]
		var time = timed_movement.pick_random()
		default_move = move.values().pick_random()
		default_direction = direction.values().pick_random()
		movement = default_move
		velocity_movement = character_direction * movement_speed
		await get_tree().create_timer(time).timeout
		
func movement_calculation() -> void:
	if (found_player == true and target):
		target_direction = (target.global_position - global_position).normalized()
		character_direction = vector_to_cardinal(target_direction)
		current_direction = character_direction
		print(target_direction)
		velocity = character_direction * movement_speed
	elif (found_player == false and last_position != Vector2.ZERO):
		character_direction = last_position
		current_direction = character_direction
		velocity = character_direction * movement_speed
	if (movement == true and found_player == false):
		if (character_direction != Vector2.ZERO):
			velocity = velocity_movement
			current_direction = character_direction
		elif (character_direction == Vector2.ZERO):
			current_direction = Vector2.ZERO
	elif (movement == false and found_player == false):
		velocity = Vector2.ZERO
		
func animation_handler() -> void:
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
	

func _ready():
	movement_axis.call_deferred()
	movement_or_not.call_deferred()
	
func _physics_process(delta: float) -> void:
	movement_calculation()
	animation_handler()
	move_and_collide(velocity * delta)
	
func vector_to_cardinal(dir: Vector2) -> Vector2:
	if abs(dir.x) > abs(dir.y):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if dir.y > 0 else Vector2.UP
		
func last_position_save() -> void:
	while target != null:
		last_position = vector_to_cardinal(target_direction)

	
func _on_enemy_detection_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		print("found him")
		print(body.global_position)
		target = body
		found_player = true
		detection.visible = true

func _on_enemy_detection_body_exited(body: Node2D) -> void:
	found_player = false
	target = null
	detection.visible = false
