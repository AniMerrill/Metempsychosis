extends Node2D

onready var room = $GenericRoom

func _ready():
	if GameState.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		room.west_door = room.DOOR_STATUS.CLOSED_DOOR
	if not GameState.has_seen_in_room_intro():
		GameState.interaction_is_frozen = true
		yield(get_tree().create_timer(3.0), "timeout")
		RoomUtil.wake_up_dialog()
	if GameState.get_state(GameState.STATE.GAME_OVER):
		RoomUtil.game_over_dialog()
