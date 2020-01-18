extends Node2D


func _on_New_pressed():
	SceneTransition.change_scene("menus/NewGame.tscn")


func _on_Credits_pressed():
	SceneTransition.change_scene("menus/Credits.tscn")


func _on_Continue_pressed():
	SceneTransition.change_scene("menus/AwaitTurn.tscn")
