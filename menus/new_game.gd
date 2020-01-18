extends Node2D

# TODO(ereborn): Set up game states in each.

func _on_PlayerB_pressed():
	SceneTransition.change_scene("menus/AwaitTurn.tscn")


func _on_PlayerA_pressed():
	RoomUtil.load_first_room()
