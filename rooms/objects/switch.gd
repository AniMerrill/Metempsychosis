extends Node2D

func _ready():
	set_toggled(false)

func set_toggled(toggled):
	if toggled:
		$ColorRect.color = Color.green
	else:
		$ColorRect.color = Color.red