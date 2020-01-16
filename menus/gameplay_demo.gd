extends Node2D

onready var state_container = $Frame/ScrollContainer/VBoxContainer
onready var start_button = $Frame/StartButton

func _ready():
	GameState.set_current_player(GameState.PLAYER.INVALID_PLAYER)
	for key in GameState.STATE.keys():
		var c = CheckBox.new()
		c.pressed = GameState.get_state(GameState.STATE.get(key))
		c.text = key
		state_container.add_child(c)
		c.connect("pressed", self, "_on_toggled", [c, key])
	_update_start_button()


func _update_start_button():
	if GameState.get_state(GameState.STATE.CODE_CREATED_BY_PLAYER_A):
		start_button.text = "Start as player B"
	else:
		start_button.text = "Start as player A"


func _on_toggled(cbox, key):
	GameState.set_state(GameState.STATE.get(key), cbox.pressed)
	_update_start_button()


func _on_StartButton_pressed():
	if GameState.get_state(GameState.STATE.CODE_CREATED_BY_PLAYER_A):
		GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	else:
		GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	RoomUtil.load_first_room()

