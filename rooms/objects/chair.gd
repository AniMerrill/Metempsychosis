tool
extends Node2D

export (bool) var open := false setget set_open

func set_open(value):
	open = value
	_update_chair()

func _ready():
	_update_chair()

func _update_chair():
	if not $chair_open:
		return
	$chair_open.visible = open
	$chair_closed.visible = not open



func _on_chair_button_pressed():
	if open:
		set_open(false)
	elif not open:
		set_open(true)
	SoundModule.play_sfx("Click")
