extends Node2D

func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/MainMenu.tscn")

var me
var other

func _ready():
	me = 1 if GameState.current_player() == GameState.PLAYER.PLAYER_A else 2
	other = 3 - me
	$Button.text = "Change to player " + str(other)

func _on_Button_pressed():
	Prompt.prompt("Player " + str(other) + " starts their turn. Player " + str(me) + ", look away from the screen now.", "Proceed", "Cancel")
	Prompt.connect("responded", self, "_on_continue_responded")

func _on_continue_responded(response):
	$Button.disabled = true
	Prompt.disconnect("responded", self, "_on_coop_responded")
	if response:
		if me == 1:
			GameState.set_current_player(GameState.PLAYER.PLAYER_B)
		else:
			GameState.set_current_player(GameState.PLAYER.PLAYER_A)
		GameState.deserialize(GameState.last_output_code())
		RoomUtil.load_first_room()
