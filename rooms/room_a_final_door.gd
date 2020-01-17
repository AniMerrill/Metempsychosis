extends Node2D

onready var room = $GenericRoom

func _ready():
	room.set_final_door_east()