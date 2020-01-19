extends Node2D

onready var room = $GenericRoom
onready var player = $GenericRoom/ControllablePlayer
onready var popup = $Popup/Popup
onready var wind_puzzle = $Popup/Popup/Content/TerminalBase/Screen/ScreenContents/puzzle_base
onready var chair = $GenericRoom/Objects/Chair

func _ready():
	if GameState.get_state(GameState.STATE.WIND_PUZZLE_SOLVED):
		_unlock_door()
	room.connect("object_clicked", self, "_on_object_clicked")
	popup.connect("closed", self, "_on_popup_closed")
	wind_puzzle.connect("solved", self, "_on_puzzle_solved")
	wind_puzzle.set_process_input(false)

func _on_object_clicked(node):
	match node.name:
		"Terminal":
			room.player_walk_to(popup.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			wind_puzzle.set_process_input(true)
			popup.visible = true
			MusicModule.state_changed("puzzle")
		"Chair":
			room.player_walk_to(chair.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			chair.open = not chair.open
			GameState.interaction_is_frozen = false

func _on_popup_closed():
	GameState.interaction_is_frozen = false
	MusicModule.state_changed("explore")

func _on_puzzle_solved():
	popup.visible = false
	GameState.interaction_is_frozen = false
	wind_puzzle.set_process_input(false)
	GameState.set_state(GameState.STATE.WIND_PUZZLE_SOLVED, true)
	_unlock_door()
	MusicModule.state_changed("explore")
	SoundModule.play_sfx("DoorUnlocksFar")

func _unlock_door():
	room.north_door = room.DOOR_STATUS.CLOSED_DOOR