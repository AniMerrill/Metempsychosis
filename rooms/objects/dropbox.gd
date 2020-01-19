tool
extends Node2D

export (bool) var for_player_b setget _for_player_b

func _for_player_b(value):
	for_player_b = value
	_update_sprites()


func _ready():
	_update_sprites()


func _update_sprites():
	if not $dropbox_a_side:
		return
	$dropbox_a_side.visible = not for_player_b
	$dropbox_b_side.visible = for_player_b
