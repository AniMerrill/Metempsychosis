extends Node2D

onready var xor_on = $xor_switch0000
onready var xor_off = $xor_switch0001

func _ready():
	set_toggled(false)

func set_toggled(toggled):
	xor_on.visible = not toggled
	xor_off.visible = toggled