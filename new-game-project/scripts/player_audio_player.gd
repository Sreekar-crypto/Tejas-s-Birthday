extends AudioStreamPlayer2D

var play : bool = false
@onready var audio_player: AudioStreamPlayer2D = $"."

func _process(delta: float) -> void:
	if (play == true):
		audio_player.play()


func _on_player_walking() -> void:
	play = true
