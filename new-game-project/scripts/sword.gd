extends Area2D

class_name sword

signal enemy_hit

var mouse_position
var can_hit : bool = false
var allowed_to_hit : bool = false

@onready var sword_sprite: Sprite2D = %sword_sprite

func facing() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	mouse_position = get_global_mouse_position()
	look_at(mouse_position)

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
	
func _ready() -> void:
	sword_sprite.visible = false

func _process(delta: float) -> void:
	if (allowed_to_hit):
		facing()
		attacking()
	else:
		return
