extends Node2D

onready var room = $GenericRoom
onready var switch = $GenericRoom/Objects/Switch
onready var player = $GenericRoom/ControllablePlayer

func _ready():
	switch.set_toggled(GameState.get_state(GameState.STATE.XOR_ROOM_SWITCHED))
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"Switch":
			room.player_walk_to(switch.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			_switch_xor()
			GameState.interaction_is_frozen = false

func _switch_xor():
	var status = not GameState.get_state(GameState.STATE.XOR_ROOM_SWITCHED)
	GameState.set_state(GameState.STATE.XOR_ROOM_SWITCHED, status)
	switch.set_toggled(status)