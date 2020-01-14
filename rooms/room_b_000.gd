extends Node2D

onready var room = $GenericRoom
onready var popup = $Popup/Label
onready var table = $GenericRoom/Objects/Table
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer

func _ready():
	popup.visible = false
	if GameState.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		room.west_door = room.DOOR_STATUS.CLOSED_DOOR
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"Table":
			room.player_walk_to(table.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			GameState.interaction_is_frozen = false
			popup.text = "It says 3456"
			popup.visible = true
			yield(get_tree().create_timer(2.5), "timeout")
			popup.visible = false
		"Pod":
			popup.text = "Going to sleep. Surrending control."
			popup.visible = true
			room.player_walk_to(pod.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			var code = GameState.serialize()
			GameState.set_last_output_code(code)
			SceneTransition.change_scene('menus/AwaitTurn.tscn')


