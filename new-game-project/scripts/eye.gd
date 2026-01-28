extends CharacterBody2D

class_name enemy_eye

@export var movement_speed : float
@export var player : PackedScene

var health : float = 100.0

var character_direction : Vector2
var last_direction : Vector2

var direction_array : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var idle_walk_behaviour_array : Array = [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]
var idle_behaviour_array : Array = [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]
var wander_array : Array =  [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]

var univeral_timer : float = 0
var roll : int

var target
var target_found : bool = false

@onready var sprite: AnimatedSprite2D = %sprite
@onready var detection: Sprite2D = %detection
@onready var question: Sprite2D = %question

enum states {IDLE, WANDER, CHASE}
enum idle_states {IDLING, WALKING}

var state : states = states.IDLE
var idle_state : idle_states = idle_states.IDLING
	
func idle_behaviour(_delta : float) -> void:
	detection.visible = false
	idle_state = idle_states.IDLING
	last_direction = character_direction
	character_direction = Vector2.ZERO
	univeral_timer = idle_behaviour_array.pick_random()
	
func idle_walk_behaviour(_delta : float) -> void:
	detection.visible = false
	idle_state = idle_states.WALKING
	last_direction = character_direction
	character_direction = direction_array.pick_random()
	univeral_timer = idle_behaviour_array.pick_random()
	
func idling(_delta : float) -> void:
	if (state == states.IDLE):
		if (idle_state == idle_states.IDLING):
			univeral_timer -= _delta
			if (univeral_timer <= 0):
				do_next(_delta)

		elif (idle_state == idle_states.WALKING):
			univeral_timer -= _delta
			if (univeral_timer <= 0):
				do_next(_delta)

func wander_behaviour(_delta : float) -> void:
	detection.visible = false
	state = states.WANDER
	last_direction = character_direction
	character_direction = direction_array.pick_random()
	univeral_timer = wander_array.pick_random()

func wandering(_delta : float) -> void:
	if (state == states.WANDER):
		univeral_timer -= _delta
		if (univeral_timer <= 0):
			do_next(_delta)
			
func chase() -> void:
	detection.visible = true
	var dir = (target.position - global_position).normalized()
	if (abs(dir.x) > abs(dir.y)):
		if (dir.x > 0):
			character_direction = Vector2.RIGHT
		elif (dir.x < 0):
			character_direction = Vector2.LEFT
	else:
		if (dir.y > 0):
			character_direction = Vector2.DOWN
		elif (dir.y < 0):
			character_direction = Vector2.UP
	
func do_next(_delta : float) -> void:
	roll = [1,2,3].pick_random()
	if (roll == 1):
		idle_behaviour(_delta)
		print("IDLING")
	elif (roll == 3):
		wander_behaviour(_delta)
		print("WANDERING")
			
func enum_matching(_delta : float) -> void:
	if (target_found == false):
		match state:
			states.IDLE:
				idling(_delta)
			states.WANDER:
				wandering(_delta)
				
	elif (target_found == true):
		match state:
			states.CHASE:
				chase()
		
		
func velocity_match() -> void:
	velocity = character_direction * movement_speed
		
func _on_enemy_detection_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		state = states.CHASE
		target = body
		target_found = true
	
func _on_enemy_detection_body_exited(body: Node2D) -> void:
	state = states.IDLE
	target_found = false
			
func animation_handler() -> void:
	if (velocity == Vector2.ZERO):
		if (last_direction == Vector2.UP):
			if (sprite.animation != "idle_up"): sprite.play("idle_up")
		elif (last_direction == Vector2.DOWN):
			if (sprite.animation != "idle_down"): sprite.play("idle_down")
		elif (last_direction == Vector2.RIGHT):
			if (sprite.animation != "idle_right"): sprite.play("idle_right")
		elif (last_direction == Vector2.LEFT):
			if (sprite.animation != "idle_left"): sprite.play("idle_left")
	elif (velocity != Vector2.ZERO):
		if (character_direction == Vector2.UP):
			if (sprite.animation != "walk_up"): sprite.play("walk_up")
		elif (character_direction == Vector2.DOWN):
			if (sprite.animation != "walk_down"): sprite.play("walk_down")
		elif (character_direction == Vector2.RIGHT):
			if (sprite.animation != "walk_right"): sprite.play("walk_right")
		elif (character_direction == Vector2.LEFT):
			if (sprite.animation != "walk_left"): sprite.play("walk_left")
			
func vector_to_cardinal(dir: Vector2) -> Vector2:
	if (abs(dir.x) > abs(dir.y)):
		return Vector2.RIGHT if dir.x > 0 else Vector2.LEFT
	else:
		return Vector2.DOWN if dir.y > 0 else Vector2.UP
			
func initializer() -> void:
	idle_state = idle_states.IDLING
	detection.visible = false
	question.visible = false

func _ready():
	initializer()
	
func _physics_process(delta: float) -> void:
	enum_matching(delta)
	velocity_match()
	print(character_direction)
	animation_handler()
	move_and_collide(velocity * delta)
