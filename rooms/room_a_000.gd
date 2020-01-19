extends Node2D

onready var room = $GenericRoom
onready var popup = $Popup/Popup
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer
onready var terminal = $GenericRoom/Objects/Terminal
onready var numpad = $Popup/Popup/Content/TerminalBase/Screen/ScreenContents/TerminalMenu/Options/Numpad

func _ready():
	popup.visible = false
	if GameState.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		room.east_door = room.DOOR_STATUS.CLOSED_DOOR
	room.connect("object_clicked", self, "_on_object_clicked")
	numpad.solution = "123456"
	numpad.connect("solved", self, "_on_solved")
	popup.connect("closed", self, "_on_terminal_closed")
	if not GameState.has_seen_in_room_intro():
		GameState.interaction_is_frozen = true
		yield(get_tree().create_timer(3.0), "timeout")
		RoomUtil.wake_up_dialog()
	if GameState.get_state(GameState.STATE.GAME_OVER):
		RoomUtil.game_over_dialog()


func _on_object_clicked(node):
	match node.name:
		"Terminal":
			room.player_walk_to(terminal.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			popup.visible = true
			GameState.interaction_is_frozen = false
			MusicModule.state_changed("puzzle")
		"Pod":
			Prompt.prompt("Go to sleep and end turn?", "Yes", "No")
			Prompt.connect("responded", self, "_on_end_turn_responded")

func _on_end_turn_responded(response):
	Prompt.disconnect("responded", self, "_on_end_turn_responded")
	if response:
		room.player_walk_to(pod.position)
		GameState.interaction_is_frozen = true
		yield(player, "position_reached")
		GameState.set_state(GameState.STATE.PLAYER_A_IN_XOR_POD, false)
		var code = GameState.serialize()
		GameState.set_last_output_code(code)
		SceneTransition.change_scene('menus/AwaitTurn.tscn')

func _on_solved():
	GameState.set_state(GameState.STATE.POD_ROOMS_UNLOCKED, true)
	room.east_door = room.DOOR_STATUS.CLOSED_DOOR

func _on_terminal_closed():
	MusicModule.state_changed("explore")