extends Node2D

onready var table := $Popup/Popup/Content/Table
onready var dropbox := $Popup/Popup/Content/Dropbox
onready var popup := $Popup/Popup
onready var closed_a := $Popup/Popup/Content/closed_a
onready var opened_a = $Popup/Popup/Content/opened_a
onready var closed_b := $Popup/Popup/Content/closed_b
onready var opened_b = $Popup/Popup/Content/opened_b

var opened
var closed

export (bool) var for_player_b = false setget _set_for_player_b

func _set_for_player_b(value):
	for_player_b = value
	update_sprites()

func update_sprites():
	opened = opened_a if not for_player_b else opened_b
	closed = closed_a if not for_player_b else closed_b

var my_keys
const box_keys = [
		GameState.STATE.KEY_A_1_POS_BOX,
		GameState.STATE.KEY_A_2_POS_BOX,
		GameState.STATE.KEY_A_3_POS_BOX,
		GameState.STATE.KEY_B_1_POS_BOX,
		GameState.STATE.KEY_B_2_POS_BOX,
		GameState.STATE.KEY_B_3_POS_BOX,
	]

signal done

func show():
	popup.visible = true
	opened.visible = false
	closed.visible = true
	table.visible = true
	dropbox.visible = false
	table.actionable = false

func _ready():
	
	update_sprites()
	
	table.connect("key_removed", self, "_on_table_key_removed")
	dropbox.connect("key_removed", self, "_on_dropbox_key_removed")
	popup.connect("closed", self, "_on_popup_closed")
	
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
	if for_player_b:
		var tmp = table.position
		table.position = dropbox.position
		dropbox.position = tmp
	_update_display()

func _update_display():
	for i in range(my_keys.size()):
		if GameState.get_state(my_keys[i]):
			table.add_key(i)
	for i in range(box_keys.size()):
		if GameState.get_state(box_keys[i]):
			dropbox.add_key(i)

func _on_table_key_removed(key):
	dropbox.add_key(key)
	GameState.set_state(my_keys[key], false)
	GameState.set_state(box_keys[key], true)

func _on_dropbox_key_removed(key):
	table.add_key(key)
	GameState.set_state(my_keys[key], true)
	GameState.set_state(box_keys[key], false)


func _on_popup_closed():
	emit_signal("done")


func _on_closeddrawer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		opened.visible = true
		dropbox.visible = true
		closed.visible = false
		table.actionable = true
		SoundModule.play_sfx("Click")

func _on_openeddrawer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		opened.visible = false
		dropbox.visible = false
		closed.visible = true
		table.actionable = false
		SoundModule.play_sfx("Click")
