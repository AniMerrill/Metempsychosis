extends Node2D

onready var room = $GenericRoom
onready var key_panel = $GenericRoom/Objects/KeyPanel
onready var player = $GenericRoom/ControllablePlayer

func _ready():
	room.set_final_door_east()
	room.connect("object_clicked", self, "_on_object_clicked")
	_update_keys()


func _on_object_clicked(node):
	match node.name:
		"KeyPanel":
			room.player_walk_to(key_panel.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			_add_keys()
			_update_keys()
			GameState.interaction_is_frozen = false

func _add_keys():
	var n_added_keys = 0
	if GameState.get_state(GameState.STATE.KEY_A_1_POS_A):
		GameState.set_state(GameState.STATE.KEY_A_1_POS_A, false)
		GameState.set_state(GameState.STATE.KEY_A_1_POS_DOOR, true)
		n_added_keys += 1
	if GameState.get_state(GameState.STATE.KEY_A_2_POS_A):
		GameState.set_state(GameState.STATE.KEY_A_2_POS_A, false)
		GameState.set_state(GameState.STATE.KEY_A_2_POS_DOOR, true)
		n_added_keys += 1
	if GameState.get_state(GameState.STATE.KEY_A_3_POS_A):
		GameState.set_state(GameState.STATE.KEY_A_3_POS_A, false)
		GameState.set_state(GameState.STATE.KEY_A_3_POS_DOOR, true)
		n_added_keys += 1
	print("Added " + str(n_added_keys) + " keys.")


func _update_keys():
	var n_keys = 0
	if GameState.get_state(GameState.STATE.KEY_A_1_POS_DOOR):
		n_keys += 1
	if GameState.get_state(GameState.STATE.KEY_A_2_POS_DOOR):
		n_keys += 1
	if GameState.get_state(GameState.STATE.KEY_A_3_POS_DOOR):
		n_keys += 1
	key_panel.set_n_keys(n_keys)
	if n_keys == 3:
		_unlock_door()

func _unlock_door():
	room.east_door = room.DOOR_STATUS.CLOSED_DOOR
