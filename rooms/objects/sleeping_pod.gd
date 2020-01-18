tool
extends Node2D

export (bool) var for_player_b = false setget _set_for_player_b

func _set_for_player_b(value):
	for_player_b = value
	_update_sprite()


func _ready():
	_update_sprite()


func _update_sprite():
	if not $sprite:
		return
	$sprite.scale.x = -1 if for_player_b else 1