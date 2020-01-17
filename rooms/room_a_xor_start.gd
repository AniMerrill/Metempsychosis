extends Node2D

onready var room = $GenericRoom

func _ready():
	if GameState.get_state(GameState.STATE.XOR_ROOM_SWITCHED):
		room.north_door = room.DOOR_STATUS.LOCKED_DOOR