extends Node2D


onready var room = $GenericRoom


func _ready():
	room.south_door = room.DOOR_STATUS.LOCKED_DOOR
	if WorldMap.is_start_tile_door_open():
		room.south_door = room.DOOR_STATUS.CLOSED_DOOR
