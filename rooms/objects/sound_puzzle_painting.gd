tool
extends Node2D

export (String) var biome = "jungle" setget _set_biome

func _set_biome(value):
	biome= value
	_update_sprites()


func _ready():
	_update_sprites()

func _update_sprites():
	if not get_node(biome):
		return
	$jungle.visible = false
	$sea.visible = false
	$sky.visible = false
	get_node(biome).visible = true