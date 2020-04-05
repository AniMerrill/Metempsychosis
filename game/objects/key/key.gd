tool
extends GameObject

enum DOOR_KEY {
	A_1, A_2, A_3,
	B_1, B_2, B_3
}

export (DOOR_KEY) var key = DOOR_KEY.A_1 setget _set_key

# Players always pick up each other's key
const state_mapping = {
	DOOR_KEY.A_1: GameState.STATE.KEY_A_1_POS_B,
	DOOR_KEY.A_2: GameState.STATE.KEY_A_2_POS_B,
	DOOR_KEY.A_3: GameState.STATE.KEY_A_3_POS_B,
	DOOR_KEY.B_1: GameState.STATE.KEY_B_1_POS_A,
	DOOR_KEY.B_2: GameState.STATE.KEY_B_2_POS_A,
	DOOR_KEY.B_3: GameState.STATE.KEY_B_3_POS_A,
}

# POS_A is always used to check if the key is on the floor.
const floor_key_mapping = {
	DOOR_KEY.A_1: GameState.STATE.KEY_A_1_POS_A,
	DOOR_KEY.A_2: GameState.STATE.KEY_A_2_POS_A,
	DOOR_KEY.A_3: GameState.STATE.KEY_A_3_POS_A,
	DOOR_KEY.B_1: GameState.STATE.KEY_B_1_POS_A,
	DOOR_KEY.B_2: GameState.STATE.KEY_B_2_POS_A,
	DOOR_KEY.B_3: GameState.STATE.KEY_B_3_POS_A,
}

var player_a_key = false

func _set_key(val):
	key = val
	_update_key()

func _ready():
	_update_key()
	if find_parent("ExchangePopup"):
		return
	if not GameState.key_on_floor(floor_key_mapping[key]):
		visible = false

func _update_key():
	if not $red_key:  # Because of tooling.
		return
	player_a_key = [DOOR_KEY.A_1, DOOR_KEY.A_2, DOOR_KEY.A_3].has(key)
	$blue_key.visible = player_a_key
	$red_key.visible = not player_a_key

# only called when picking up the key from the floor, not from the dropbox.
func _on_click():
	GameState.interaction_is_frozen = true
	_walk_player_to_here()
	yield(self, "position_reached")
	GameState.interaction_is_frozen = false
	visible = false
	GameState.set_state(state_mapping[key], true)
	var color = "blue" if player_a_key else "red"
	FlashText.flash("You pick up a " + color + " key.")
	SoundModule.play_sfx("ItemPickedUp")
