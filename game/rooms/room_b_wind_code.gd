extends Node2D

onready var room = $GenericRoom
onready var wind_puzzle = $GenericRoom/Objects/Terminal/WindCodeTerminal

func _ready():
	if GameState.get_state(GameState.STATE.WIND_PUZZLE_SOLVED):
		_unlock_door()
	wind_puzzle.connect("solved", self, "_on_puzzle_solved")

func _on_puzzle_solved():
	GameState.set_state(GameState.STATE.WIND_PUZZLE_SOLVED, true)
	_unlock_door()
	SoundModule.play_sfx("DoorUnlocksFar")

func _unlock_door():
	room.north_door = room.DOOR_STATUS.CLOSED_DOOR
