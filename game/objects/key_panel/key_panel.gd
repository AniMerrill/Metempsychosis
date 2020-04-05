tool
extends GameObject

export (bool) var for_player_b = false setget _set_for_player_b

var n_keys = 0
var room

func _set_for_player_b(value:bool):
	for_player_b = value
	_update_sprite()

func _ready():
	room = _room()
	if for_player_b:
		room.set_final_door_west()
	else:
		room.set_final_door_east()
	_update_keys()

func _on_click():
	GameState.interaction_is_frozen = true
	_walk_player_to_here()
	yield(self, "position_reached")
	_add_keys()
	_update_keys()
	GameState.interaction_is_frozen = false

func _update_keys():
	var n_keys = 0
	if for_player_b:
		if GameState.get_state(GameState.STATE.KEY_B_1_POS_DOOR):
			n_keys += 1
		if GameState.get_state(GameState.STATE.KEY_B_2_POS_DOOR):
			n_keys += 1
		if GameState.get_state(GameState.STATE.KEY_B_3_POS_DOOR):
			n_keys += 1
	else:
		if GameState.get_state(GameState.STATE.KEY_A_1_POS_DOOR):
			n_keys += 1
		if GameState.get_state(GameState.STATE.KEY_A_2_POS_DOOR):
			n_keys += 1
		if GameState.get_state(GameState.STATE.KEY_A_3_POS_DOOR):
			n_keys += 1
	set_n_keys(n_keys)
	if n_keys == 3:
		_unlock_door()
		FlashText.flash("Door unlocked!")

func _unlock_door():
	if for_player_b:
		room.west_door = room.DOOR_STATUS.CLOSED_DOOR
	else:
		room.east_door = room.DOOR_STATUS.CLOSED_DOOR

func set_n_keys(value : int):
	n_keys = value
	_update_sprite()

func _add_keys():
	var n_added_keys = 0
	if for_player_b:
		if GameState.get_state(GameState.STATE.KEY_B_1_POS_B):
			GameState.set_state(GameState.STATE.KEY_B_1_POS_B, false)
			GameState.set_state(GameState.STATE.KEY_B_1_POS_DOOR, true)
			n_added_keys += 1
		if GameState.get_state(GameState.STATE.KEY_B_2_POS_B):
			GameState.set_state(GameState.STATE.KEY_B_2_POS_B, false)
			GameState.set_state(GameState.STATE.KEY_B_2_POS_DOOR, true)
			n_added_keys += 1
		if GameState.get_state(GameState.STATE.KEY_B_3_POS_B):
			GameState.set_state(GameState.STATE.KEY_B_3_POS_B, false)
			GameState.set_state(GameState.STATE.KEY_B_3_POS_DOOR, true)
			n_added_keys += 1
	else:
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
	match n_added_keys:
		0:
			FlashText.flash("You do not have any matching keys to insert.")
		1:
			FlashText.flash("One key inserted.")
		2:
			FlashText.flash("Two keys inserted.")
		3:
			FlashText.flash("All keys inserted.")

func _update_sprite():
	if not $sprite:  ## Because tool script.
		return
	self.scale.x = 1 if for_player_b else -1
	$sprite.frame = 0
	if for_player_b:
		$sprite.frame += 5
	$sprite.frame += n_keys
