extends Node2D

onready var room = $GenericRoom
onready var player = $GenericRoom/ControllablePlayer
onready var popup = $Popup/Popup
onready var numpad = $Popup/Popup/Content/TerminalBase/Screen/ScreenContents/NumpadScreen
onready var terminal = $GenericRoom/Objects/Terminal

func _ready():
	if GameState.get_state(GameState.STATE.BIOME_PUZZLE_SOLVED):
		_unlock_door()
	room.connect("object_clicked", self, "_on_object_clicked")
	popup.connect("closed", self, "_on_popup_closed")
	numpad.connect("solved", self, "_on_puzzle_solved")
	numpad.connect("number_pressed", self, "_on_number_pressed")

func _on_object_clicked(node):
	match node.name:
		"Terminal":
			room.player_walk_to(terminal.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			popup.visible = true
			MusicModule.state_changed("puzzle")

func _on_popup_closed():
	GameState.interaction_is_frozen = false
	MusicModule.state_changed("explore")

func _on_puzzle_solved():
	GameState.set_state(GameState.STATE.BIOME_PUZZLE_SOLVED, true)
	_unlock_door()
	MusicModule.state_changed("explore")
	SoundModule.play_sfx("DoorUnlocksNear")

func _unlock_door():
	room.north_door = room.DOOR_STATUS.CLOSED_DOOR

func _on_number_pressed(value):
	SoundModule.play_sfx("SoundPuzzle" + str(value))