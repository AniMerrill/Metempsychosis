extends Node2D

onready var room = $GenericRoom

func _ready():
	if GameState.get_state(GameState.STATE.BIOME_PUZZLE_SOLVED):
		_unlock_door()

func _unlock_door():
	room.north_door = room.DOOR_STATUS.CLOSED_DOOR

func _on_SoundBoardTerminal_solved():
	_unlock_door()
	SoundModule.play_sfx("DoorUnlocksNear")
