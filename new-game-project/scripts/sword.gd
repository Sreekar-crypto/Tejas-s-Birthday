extends Area2D

class_name sword

signal enemy_hit
signal sword_direction
signal not_enemy_hit

var mouse_position
var can_hit : bool = false
var allowed_to_hit : bool = false

var sword_direction_vector

@onready var sword_sprite: Sprite2D = %sword_sprite

func facing() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mouse_position = get_global_mouse_position()
	look_at(mouse_position)
	sword_direction_vector = (mouse_position - global_position).normalized()
	emit_signal("sword_direction", sword_direction_vector)

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "eye"):
		can_hit = true
		
func attacking() -> void:
	if (can_hit == true):
		if Input.is_action_just_pressed("attack"):
			emit_signal("enemy_hit")

func _on_player_attack_entered() -> void:
	sword_sprite.visible = true
	allowed_to_hit = true
	
func _on_player_attack_exited() -> void:
	sword_sprite.visible = false
	allowed_to_hit = false
	
func _on_body_exited(body: Node2D) -> void:
	can_hit = false
	emit_signal("not_enemy_hit")
	
func _ready() -> void:
	sword_sprite.visible = false

func _process(delta: float) -> void:
	if (allowed_to_hit):
		facing()
		attacking()
	else:
		return
