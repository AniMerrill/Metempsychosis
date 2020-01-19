extends Node2D

onready var room = $GenericRoom
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer

func _ready():
	if GameState.get_state(GameState.STATE.XOR_ROOM_SWITCHED):
		room.north_door = room.DOOR_STATUS.CLOSED_DOOR
		room.south_door = room.DOOR_STATUS.LOCKED_DOOR
	room.connect("object_clicked", self, "_on_object_clicked")
	if GameState.get_state(GameState.STATE.GAME_OVER):
		RoomUtil.game_over_dialog()

func _on_object_clicked(node):
	match node.name:
		"Pod":
			room.player_walk_to(pod.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			GameState.set_state(GameState.STATE.PLAYER_A_IN_XOR_POD, true)
			var code = GameState.serialize()
			GameState.set_last_output_code(code)
			SceneTransition.change_scene('menus/AwaitTurn.tscn')
