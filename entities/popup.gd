extends Node2D

signal closed

func _ready():
	visible = false

func _on_XButton_pressed():
	visible = false
	emit_signal("closed")
