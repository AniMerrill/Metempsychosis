tool
extends Node2D

export (bool) var for_player_b = false setget _set_for_player_b

var n_keys = 0

func _set_for_player_b(value:bool):
	for_player_b = value
	_update_sprite()

func _ready():
	_update_sprite()

func set_n_keys(value : int):
	n_keys = value
	_update_sprite()

func _update_sprite():
	if not $sprite:  ## Because tool script.
		return
	self.scale.x = 1 if for_player_b else -1
	$sprite.frame = 0
	if for_player_b:
		$sprite.frame += 5
	$sprite.frame += n_keys