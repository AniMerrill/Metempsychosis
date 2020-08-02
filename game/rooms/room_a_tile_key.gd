extends Node2D


onready var room = $GenericRoom


func _ready():
	room.west_door = room.DOOR_STATUS.LOCKED_DOOR
	if WorldMap.is_key_tile_door_open():
		room.west_door = room.DOOR_STATUS.CLOSED_DOOR
