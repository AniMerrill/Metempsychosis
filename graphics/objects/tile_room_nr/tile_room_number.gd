tool
extends Node2D

export var number:int = 3 setget set_number
export var color:Color = Color(0,250,100) setget set_color

func set_number(value):
	number = value
	if $Outline:
		$Outline.text = str(number)
		$Label.text = str(number)

func set_color(value):
	color = value
	if $Outline:
		$Outline.self_modulate = color

func _ready():
	$AnimationPlayer.play("modulate")

