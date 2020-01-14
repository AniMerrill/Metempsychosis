extends Node2D

onready var output_code = $Frame/OutputCodeBG/OutputCode
onready var input_code = $Frame/InputCode

func _ready():
	output_code.text = GameState.last_output_code()

func _on_InputCode_text_entered(new_text):
	print(new_text)
	if not GameState.deserialize(new_text):
		printerr("FAILED to decode game state: " + new_text)
	else:
		if GameState.current_player() == GameState.PLAYER.PLAYER_A:
			SceneTransition.change_scene("rooms/room_a_000.tscn")
		else:
			SceneTransition.change_scene("rooms/room_b_000.tscn")

func _on_Continue_pressed():
	_on_InputCode_text_entered(input_code.text)

func _on_ChangePlayer_pressed():
	SceneTransition.change_scene_direct('menus/GameplayDemo.tscn')
