extends Node2D

onready var room = $GenericRoom
onready var popup = $Popup/Popup
onready var table = $GenericRoom/Objects/Table
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer

func _ready():
	popup.visible = false
	if GameState.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		room.west_door = room.DOOR_STATUS.CLOSED_DOOR
	room.connect("object_clicked", self, "_on_object_clicked")
	popup.connect("closed", self, "_on_popup_closed")

func _on_object_clicked(node):
	match node.name:
		"Table":
			room.player_walk_to(table.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			popup.visible = true
			MusicModule.state_changed("puzzle")
			GameState.interaction_is_frozen = false
		"Pod":
			room.player_walk_to(pod.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			var code = GameState.serialize()
			GameState.set_last_output_code(code)
			SceneTransition.change_scene('menus/AwaitTurn.tscn')

func _on_popup_closed():
	MusicModule.state_changed("explore")

