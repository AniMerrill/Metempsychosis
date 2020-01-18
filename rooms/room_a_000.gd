extends Node2D

onready var room = $GenericRoom
onready var popup = $Popup/Popup
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer
onready var terminal = $GenericRoom/Objects/Terminal
onready var numpad = $Popup/Popup/Content/TerminalBase/Screen/ScreenContents/NumpadScreen

func _ready():
	popup.visible = false
	if GameState.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		room.east_door = room.DOOR_STATUS.CLOSED_DOOR
	room.connect("object_clicked", self, "_on_object_clicked")
	numpad.solution = "123456"
	numpad.connect("solved", self, "_on_solved")

func _on_object_clicked(node):
	match node.name:
		"Terminal":
			room.player_walk_to(terminal.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			popup.visible = true
			GameState.interaction_is_frozen = false
		"Pod":
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
