extends Node2D

# TODO(ereborn): Set up game states in each.

func _on_PlayerB_pressed():
	GameState.clear_state()
	GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	GameState.set_last_output_code('(no code)')
	GameState.has_seen_in_room_intro = false
	GameState.has_seen_introduction = false
	SceneTransition.change_scene("menus/AwaitTurn.tscn")


func _on_PlayerA_pressed():
	GameState.clear_state()
	GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	GameState.set_last_output_code('(no code)')
	RoomUtil.load_first_room()


func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/MainMenu.tscn")

