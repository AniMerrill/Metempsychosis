extends Node2D

func _on_Player1Start_pressed():
	GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	_start_game()


func _on_Player2Start_pressed():
	GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	_start_game()

func _start_game() -> void:
	SceneTransition.change_scene('menus/OpeningDialogue.tscn', 'It starts.', 1.0)
