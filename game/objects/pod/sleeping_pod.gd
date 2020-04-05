tool
extends GameObject

export (bool) var for_player_b = false setget _set_for_player_b
export (bool) var is_a_xor_pod = false


func _set_for_player_b(value):
	for_player_b = value
	_update_sprite()


func _ready():
	_update_sprite()


func _update_sprite():
	if not $sprite:
		return
	$sprite.scale.x = -1 if for_player_b else 1


func _on_click():
	self._walk_player_to_here()
	yield(self, "position_reached")
	Prompt.prompt("Go to sleep and end turn?", "Yes", "No")
	# warning-ignore:return_value_discarded
	Prompt.connect("responded", self, "_on_end_turn_responded")


func _on_end_turn_responded(response):
	Prompt.disconnect("responded", self, "_on_end_turn_responded")
	if response:
		GameState.set_state(GameState.STATE.PLAYER_A_IN_XOR_POD, is_a_xor_pod)
		var code = GameState.serialize()
		GameState.set_last_output_code(code)
		SceneTransition.change_scene('menus/AwaitTurn.tscn')
	GameState.interaction_is_frozen = false
