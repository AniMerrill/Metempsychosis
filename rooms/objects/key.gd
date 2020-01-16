tool
extends Node2D

onready var key_sprite = $ColorRect

export (bool) var for_player_b = false setget _set_for_player_b

func _set_for_player_b(value:bool):
	for_player_b = value
	_update_key()

func _ready():
	_update_key()

func _update_key():
	if not key_sprite:
		return
	if for_player_b:
		key_sprite.modulate = Color.red
	else:
		key_sprite.modulate = Color.blue