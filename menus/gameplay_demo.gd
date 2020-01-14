extends Node2D


func _ready():
	GameState.set_current_player(GameState.PLAYER.INVALID_PLAYER)
	$CurrentPlayer.refresh()

func _on_PlayerA_pressed():
	GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	start_game()

func _on_PlayerB_pressed():
	GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	start_game()

func start_game():
	SceneTransition.change_scene_direct('menus/AwaitTurn.tscn')
