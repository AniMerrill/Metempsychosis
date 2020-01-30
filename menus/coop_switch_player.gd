extends Node2D

func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/MainMenu.tscn")

var next_player
var prev_player

func _ready():
	# We do not know whether we continue a normal turn, whether the game was
	# closed while playing, or the game was closed in the change-turn screen.
	# So we need to look at the stored state to determine how to continue.
	
	GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	var result = GameState.deserialize(GameState.last_output_code())
	if result == GameState.ERROR_CODE.OTHER_PLAYER_CODE:
		GameState.set_current_player(GameState.PLAYER.PLAYER_B)
		GameState.deserialize(GameState.last_output_code())
	
	next_player = 1 if GameState.current_player() == GameState.PLAYER.PLAYER_A else 2
	prev_player = 3 - next_player
	$Button.text = "Change to player " + str(next_player)

func _on_Button_pressed():
	Prompt.prompt("Player " + str(next_player) + " starts their turn. Player " + str(prev_player) + ", look away from the screen now.", "Proceed", "Cancel")
	Prompt.connect("responded", self, "_on_continue_responded")

func _on_continue_responded(response):
	$Button.disabled = true
	Prompt.disconnect("responded", self, "_on_coop_responded")
	if response:
		GameState.deserialize(GameState.last_output_code())
		RoomUtil.load_first_room()
