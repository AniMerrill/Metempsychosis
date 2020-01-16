extends Node

func load_first_room():
	match GameState.current_player():
		GameState.PLAYER.PLAYER_A:
			if GameState.get_state(GameState.STATE.PLAYER_A_IN_XOR_POD):
				SceneTransition.change_scene_direct('rooms/room_a_xor_puzzle.tscn')
			else:
				SceneTransition.change_scene_direct('rooms/room_a_000.tscn')
		GameState.PLAYER.PLAYER_B:
			SceneTransition.change_scene_direct('rooms/room_b_000.tscn')
		_:
			printerr("ERROR: No player active.")