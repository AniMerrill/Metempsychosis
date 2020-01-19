extends Node2D

func _ready():
	GameState.reset_for_new_game()

func _on_PlayerB_pressed():
	GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	SceneTransition.change_scene("menus/AwaitTurn.tscn")


func _on_PlayerA_pressed():
	GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	RoomUtil.load_first_room()


func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/MainMenu.tscn")


func _on_LocalCoop_pressed():
	Prompt.prompt("Player 1 starts. Player 2, look away from the screen now.", "Proceed", "Cancel")
	Prompt.connect("responded", self, "_on_coop_responded")


func _on_coop_responded(response):
	Prompt.disconnect("responded", self, "_on_coop_responded")
	if response:
		GameState.set_coop_mode(true)
		GameState.set_current_player(GameState.PLAYER.PLAYER_A)
		RoomUtil.load_first_room()