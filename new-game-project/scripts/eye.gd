extends CharacterBody2D

class_name enemy_eye

@export var movement_speed : float
@export var player : PackedScene

signal touched
signal hit

var health : float = 100.0
var last_health : float
var backoff_timer : SceneTreeTimer  = null

var character_direction : Vector2
var last_direction : Vector2
var last_direction_to_player : Vector2
var global_position_at_start : Vector2
var live_global_position : Vector2
var dir : Vector2
var knockback_direction : Vector2
var direction_enabler : Vector2

var direction_array : Array = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var idle_walk_behaviour_array : Array = [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]
var idle_behaviour_array : Array = [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]
var wander_array : Array =  [0.05,0.15,1.25,2.5,3.75,4.0,3.25,2.5,7.75,8.05,0.15]
var finding_behaviour_array : Array = [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]
var finding_array : Array = [0.05,0.15,0.25,0.5,0.75,1.0,1.25,1.5,1.75,0.05,0.15]
var finding_direction = [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]


var univeral_timer : float = 0
var finding_direction_change_timer : float = 0
var knockback_time : float
var knockback_timer : float
var knockback_force : float

var got_direction : Vector2
var roll : int
var steps : int = 0

var target

var target_found : bool = false
var running : bool = true
var in_knockback : bool = true
var backoff_done : bool = false
var backoff_active : bool = false
var got_hit : bool = false


@onready var sprite: AnimatedSprite2D = %sprite
@onready var detection: Sprite2D = %detection
@onready var question: Sprite2D = %question

enum states {IDLE, WANDER, CHASE, FINDING, BACKOFF}
enum idle_states {IDLING, WALKING}

var state : states = states.IDLE
var idle_state : idle_states = idle_states.IDLING
	
func idle_behaviour(_delta : float) -> void:
	detection.visible = false
	question.visible = false
	idle_state = idle_states.IDLING
	last_direction = character_direction
	character_direction = Vector2.ZERO
	univeral_timer = idle_behaviour_array.pick_random()
	
func idle_walk_behaviour(_delta : float) -> void:
	detection.visible = false
	question.visible = false
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
	question.visible = false
	state = states.WANDER
	last_direction = character_direction
	character_direction = direction_array.pick_random()
	univeral_timer = wander_array.pick_random()

func wandering(_delta : float) -> void:
	if (state == states.WANDER):
		univeral_timer -= _delta
		if (univeral_timer <= 0):
			do_next(_delta)

			
func movement_mechanics(dir : Vector2) -> void:
	if (dir.x > 0.3826 and dir.y < -0.3826):
		character_direction = (Vector2.UP + Vector2.RIGHT).normalized()
	elif (dir.x < -0.3826 and dir.y > 0.3826):
		character_direction = (Vector2.DOWN + Vector2.LEFT).normalized()
	elif (dir.x < -0.3826 and dir.y < -0.3826):
		character_direction = (Vector2.UP + Vector2.LEFT).normalized()
	elif (dir.x > 0.3826 and dir.y > 0.3826):
		character_direction = (Vector2.DOWN + Vector2.RIGHT).normalized()
	elif (abs(dir.x) > abs(dir.y)):
		if (dir.x > 0):
			character_direction = Vector2.RIGHT
		elif (dir.x < 0):
			character_direction = Vector2.LEFT
	elif (abs(dir.y) > abs(dir.x)):
		if (dir.y > 0):
			character_direction = Vector2.DOWN
		elif (dir.y < 0):
			character_direction = Vector2.UP
			
func chase() -> void:
	detection.visible = true
	question.visible = false
	dir = (target.position - global_position).normalized()
	movement_mechanics(dir)
	last_direction = character_direction
	
		
func do_next(_delta : float) -> void:
	roll = [1,2,3].pick_random()
	if (roll == 1):
		idle_behaviour(_delta)
	elif (roll == 3):
		wander_behaviour(_delta)
		
func finding_player_behaviour() -> void:
	finding_direction.erase(character_direction)
	if (state == states.FINDING):
		if (steps <= 2):
			character_direction = last_direction_to_player
			steps += 1
		detection.visible = false
		question.visible = true
		finding_direction_change_timer = finding_array.pick_random()
		univeral_timer = finding_behaviour_array.pick_random()
		if (finding_direction.is_empty()):
			state = states.IDLE
		else:
			character_direction = finding_direction.pick_random()
		
func managing_direction_change(_delta : float) -> void:
	if (state == states.FINDING):
		finding_direction_change_timer -= _delta
		if (finding_direction_change_timer <= 0):
			finding_player_behaviour()
	
func finding_player(_delta : float) -> void:
	if (state == states.FINDING):
		univeral_timer -= _delta
		if (univeral_timer <= 0):
			managing_direction_change(_delta)
			
func pause() -> void:
	character_direction = Vector2.ZERO
	velocity = character_direction * 0
			
func enum_matching(_delta : float) -> void:
	if (state == states.BACKOFF):
		backoff()
		return
	if (target_found == false):
		match state:
			states.IDLE:
				idling(_delta)
			states.WANDER:
				wandering(_delta)
			states.FINDING:
				finding_player(_delta)
			
				
	elif (target_found == true):
		match state:
			states.CHASE:
				chase()
		
func _on_enemy_detection_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		target_found = true
		state = states.CHASE
		target = body
	
func _on_enemy_detection_body_exited(body: Node2D) -> void:
	target_found = false
	state = states.FINDING
	last_direction_to_player = character_direction
	
func _on_touching_detection_body_entered(body: Node2D) -> void:
	if (body.name == "player"):
		await HitStopManager.hit_stop()
		emit_signal("touched", global_position)
		emit_signal("hit")

func _on_player_hitting_enemy(got_player_direction) -> void:
	health -= 100
	got_direction = got_player_direction
	enter_backoff()
	print("enemy health ", health)
	print(got_direction)
	if (health <= 0):
		die()
		
func _on_player_not_hitting_enemy() -> void:
	got_hit = false

	
func enter_backoff() -> void:
	if (backoff_active == true):
		return
	print("Backoff working")
	backoff_active = true
	state = states.BACKOFF
	direction_enabler = -got_direction.normalized()
	backoff_timer = get_tree().create_timer(20)
	backoff_timer.timeout.connect(Callable(self, "_end_backoff"))
	
func _end_backoff() -> void:
	backoff_timer = null
	state = states.FINDING
	direction_enabler = Vector2.ZERO
	backoff_done = true
	backoff_active = false
	
func backoff() -> void:
	movement_mechanics(direction_enabler)
	
func velocity_match() -> void:
	velocity = character_direction * movement_speed
	
func die() -> void:
	self.queue_free()
			
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
	global_position_at_start = global_position

func _ready():
	initializer()
	
func _physics_process(delta: float) -> void:
	if (Engine.time_scale == 0):
		return
	live_global_position = global_position
	enum_matching(delta)
	velocity_match()
	animation_handler()
	move_and_collide(velocity * delta)
