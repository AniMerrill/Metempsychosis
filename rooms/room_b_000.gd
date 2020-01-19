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
	if not GameState.has_seen_in_room_intro():
		GameState.interaction_is_frozen = true
		yield(get_tree().create_timer(4.0), "timeout")
		RoomUtil.wake_up_dialog()
	if GameState.get_state(GameState.STATE.GAME_OVER):
		RoomUtil.game_over_dialog()

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
			Prompt.prompt("Go to sleep and end turn?", "Yes", "No")
			Prompt.connect("responded", self, "_on_end_turn_responded")


func _on_end_turn_responded(response):
	Prompt.disconnect("responded", self, "_on_end_turn_responded")
	if response:
		room.player_walk_to(pod.position)
		GameState.interaction_is_frozen = true
		yield(player, "position_reached")
		var code = GameState.serialize()
		GameState.set_last_output_code(code)
		SceneTransition.change_scene('menus/AwaitTurn.tscn')

func _on_popup_closed():
	MusicModule.state_changed("explore")

