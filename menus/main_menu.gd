extends Node2D


func _ready():
	Timeout.stop_timer()
	if GameState.current_player() == GameState.PLAYER.INVALID_PLAYER:
		$Continue.visible = false

func _on_New_pressed():
	if $Continue.visible:
		Prompt.prompt("This will overwrite your current game. Proceed?", "Proceed", "Cancel")
		Prompt.connect("responded", self, "_on_new_game_responded")
	else:
		SceneTransition.change_scene("menus/NewGame.tscn")

func _on_new_game_responded(response):
	Prompt.disconnect("responded", self, "_on_new_game_responded")
	if response:
		SceneTransition.change_scene("menus/NewGame.tscn")


func _on_Credits_pressed():
	SceneTransition.change_scene("menus/Credits.tscn")


func _on_Continue_pressed():
	SceneTransition.change_scene("menus/AwaitTurn.tscn")
