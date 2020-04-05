extends Node2D

const BOX_KEYS = [
		GameState.STATE.KEY_A_1_POS_BOX,
		GameState.STATE.KEY_A_2_POS_BOX,
		GameState.STATE.KEY_A_3_POS_BOX,
		GameState.STATE.KEY_B_1_POS_BOX,
		GameState.STATE.KEY_B_2_POS_BOX,
		GameState.STATE.KEY_B_3_POS_BOX,
	]

export (bool) var for_player_b = false setget _set_for_player_b

var opened
var closed

var my_keys

onready var table = $Popup/Table
onready var dropbox = $Popup/Dropbox
onready var popup = $Popup
onready var closed_a = $Popup/closed_a
onready var opened_a = $Popup/opened_a
onready var closed_b = $Popup/closed_b
onready var opened_b = $Popup/opened_b

func _ready():
	update_sprites()
	
	# warning-ignore:return_value_discarded
	table.connect("key_removed", self, "_on_table_key_removed")
	# warning-ignore:return_value_discarded
	dropbox.connect("key_removed", self, "_on_dropbox_key_removed")
	# warning-ignore:return_value_discarded
	popup.connect("closed", self, "_on_popup_closed")
	# warning-ignore:return_value_discarded
	popup.connect("opened", self, "_on_popup_opened")
	
	if for_player_b:
		my_keys = [
				GameState.STATE.KEY_A_1_POS_B,
				GameState.STATE.KEY_A_2_POS_B,
				GameState.STATE.KEY_A_3_POS_B,
				GameState.STATE.KEY_B_1_POS_B,
				GameState.STATE.KEY_B_2_POS_B,
				GameState.STATE.KEY_B_3_POS_B,
			]
	else:
		my_keys = [
				GameState.STATE.KEY_A_1_POS_A,
				GameState.STATE.KEY_A_2_POS_A,
				GameState.STATE.KEY_A_3_POS_A,
				GameState.STATE.KEY_B_1_POS_A,
				GameState.STATE.KEY_B_2_POS_A,
				GameState.STATE.KEY_B_3_POS_A,
			]
	closed_a.visible = false
	closed_b.visible = false
	opened_a.visible = false
	opened_b.visible = false
	
	closed_a.get_node("Area2D").connect("input_event", self, "_on_closeddrawer_input_event")
	opened_a.get_node("Area2D").connect("input_event", self, "_on_openeddrawer_input_event")
	closed_b.get_node("Area2D").connect("input_event", self, "_on_closeddrawer_input_event")
	opened_b.get_node("Area2D").connect("input_event", self, "_on_openeddrawer_input_event")
	
	if for_player_b:
		var tmp = table.position
		table.position = dropbox.position
		dropbox.position = tmp
	
	_update_display()


func _update_display():
	for i in range(my_keys.size()):
		if GameState.get_state(my_keys[i]):
			table.add_key(i)
	for i in range(BOX_KEYS.size()):
		if GameState.get_state(BOX_KEYS[i]):
			dropbox.add_key(i)


func _on_table_key_removed(key):
	dropbox.add_key(key)
	GameState.set_state(my_keys[key], false)
	GameState.set_state(BOX_KEYS[key], true)


func _on_dropbox_key_removed(key):
	table.add_key(key)
	GameState.set_state(my_keys[key], true)
	GameState.set_state(BOX_KEYS[key], false)


func _on_popup_closed():
	var has_keys = false
	if for_player_b:
		has_keys = (
				GameState.get_state(GameState.STATE.KEY_A_1_POS_B) or
				GameState.get_state(GameState.STATE.KEY_A_2_POS_B) or
				GameState.get_state(GameState.STATE.KEY_A_3_POS_B) or
				GameState.get_state(GameState.STATE.KEY_B_1_POS_B) or
				GameState.get_state(GameState.STATE.KEY_B_2_POS_B) or
				GameState.get_state(GameState.STATE.KEY_B_3_POS_B)
			)
	else:
		has_keys = (
				GameState.get_state(GameState.STATE.KEY_A_1_POS_A) or
				GameState.get_state(GameState.STATE.KEY_A_2_POS_A) or
				GameState.get_state(GameState.STATE.KEY_A_3_POS_A) or
				GameState.get_state(GameState.STATE.KEY_B_1_POS_A) or
				GameState.get_state(GameState.STATE.KEY_B_2_POS_A) or
				GameState.get_state(GameState.STATE.KEY_B_3_POS_A)
			)
	if has_keys:
		FlashText.flash("You take the keys that are on the table with you.")
		SoundModule.play_sfx("ItemPickedUp") 


func _on_closeddrawer_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		opened.visible = true
		dropbox.visible = true
		closed.visible = false
		table.actionable = true
		SoundModule.play_sfx("Click")


func _on_openeddrawer_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		opened.visible = false
		dropbox.visible = false
		closed.visible = true
		table.actionable = false
		SoundModule.play_sfx("Click")


func _set_for_player_b(value):
	for_player_b = value
	update_sprites()


func update_sprites():
	opened = opened_a if not for_player_b else opened_b
	closed = closed_a if not for_player_b else closed_b


func _on_popup_opened():
	opened.visible = false
	closed.visible = true
	table.visible = true
	dropbox.visible = false
	table.actionable = false
	_update_display()

