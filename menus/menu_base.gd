extends Node2D

onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("Modulate")

func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/MainMenu.tscn")
