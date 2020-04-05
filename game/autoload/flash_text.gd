extends Node2D

onready var label = $ColorRect/Label

func _ready():
	visible = false

func flash(text : String, duration : float = 3.0):
	label.text = text
	visible = true
	yield(get_tree().create_timer(duration), "timeout")
	visible = false