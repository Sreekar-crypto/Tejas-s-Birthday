extends Node

class_name game_manager

@onready var eye: enemy_eye = %eye
@onready var eye_2: enemy_eye = %eye2
@onready var eye_3: enemy_eye = %eye3


var enemy_array : Array = [eye, eye_2, eye_3]

func _ready() -> void:
	pass
