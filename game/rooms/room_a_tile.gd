extends Node2D


onready var room = $GenericRoom

func _ready():
	WorldMap.set_tile_room_doors(room)
