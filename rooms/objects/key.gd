tool
extends Node2D


export (bool) var for_player_b = false setget _set_for_player_b

func _set_for_player_b(value:bool):
	for_player_b = value
	_update_key()

func _ready():
	_update_key()

func _update_key():
	if not $red_key:
		return
	$red_key.visible = for_player_b
	$blue_key.visible = not for_player_b