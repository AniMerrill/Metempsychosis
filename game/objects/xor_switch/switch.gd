extends GameObject

onready var xor_on = $xor_switch0000
onready var xor_off = $xor_switch0001

func _ready():
	set_toggled(false)

func set_toggled(toggled):
	xor_on.visible = not toggled
	xor_off.visible = toggled

func _on_click():
	self._walk_player_to_here()
	yield(self, "position_reached")
	_switch_xor()
	GameState.interaction_is_frozen = false
	FlashText.flash("Somewhere in the distance you hear the sound of two doors. One locking, one unlocking.")
	SoundModule.play_sfx("DoorUnlocksFar")

func _switch_xor():
	var status = not GameState.get_state(GameState.STATE.XOR_ROOM_SWITCHED)
	GameState.set_state(GameState.STATE.XOR_ROOM_SWITCHED, status)
	set_toggled(status)
