extends Node2D

onready var room = $GenericRoom

func _ready():
	if GameState.get_state(GameState.STATE.XOR_ROOM_SWITCHED):
		room.north_door = room.DOOR_STATUS.CLOSED_DOOR
		room.south_door = room.DOOR_STATUS.LOCKED_DOOR
	if GameState.get_state(GameState.STATE.GAME_OVER):
		RoomUtil.game_over_dialog()
