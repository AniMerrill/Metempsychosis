tool
extends EditorScript

func _run():
	var game_state = load('res://util/game_state.gd').new()
	
	print(game_state._slide_normal_to_encoding([0]))
	print(game_state._slide_normal_to_encoding([0,1,2,3,4,5,6,7,8]))
	print(game_state._slide_normal_to_encoding([1,0,2,3,4,5,8,6,7]))
	
	print(game_state._slide_encoding_to_normal([]))
	print(game_state._slide_encoding_to_normal([0,0,0,0,0,0,0,0,0]))
	print(game_state._slide_encoding_to_normal([1,0,0,0,0,0,2,0,0]))
	print(game_state._slide_encoding_to_normal([8,7,6,5,4,3,2,1,0]))
	
	print(game_state._fact(0))
	print(game_state._fact(3))
	print(game_state._fact(5))
	
	print(game_state._slide_encoding_to_int([0,0,0,0,0,0,0,0,0]))
	print(game_state._slide_encoding_to_int([1,0,0,0,0,0,2,0,0]))
	print(game_state._slide_encoding_to_int([8,7,6,5,4,3,2,1,0]))
	
	print(game_state._slide_int_to_encoding(0))
	print(game_state._slide_int_to_encoding(40324))
	print(game_state._slide_int_to_encoding(362879))
	
	print(game_state._slide_get_state())
	game_state._slide_set_state(42)
	print(game_state._slide_get_state())
	game_state._slide_set_state(40324)
	print(game_state._slide_get_state())
	game_state._slide_set_state(362879)
	print(game_state._slide_get_state())
	game_state._slide_set_state(0)
	print(game_state._slide_get_state())
	
	game_state.set_slide_puzzle_state([4,3,2,1,0,5,6,8,7])
	print(game_state.get_slide_puzzle_state())
	
	game_state.set_slide_puzzle_state([8,7,6,5,4,3,2,1,0])
	print(game_state.get_slide_puzzle_state())
	
	game_state.set_slide_puzzle_state([0,1,5,4,3,2,6,7,8])
	print(game_state.get_slide_puzzle_state())

