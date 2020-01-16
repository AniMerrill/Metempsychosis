extends Node2D

onready var inventory := $Inventory
onready var dropbox := $Dropbox

var my_key_a_1
var my_key_a_2
var my_key_a_3
var my_key_b_1
var my_key_b_2
var my_key_b_3

signal done

func _ready():
	if GameState.current_player() == GameState.PLAYER.PLAYER_A:
		my_key_a_1 = GameState.STATE.KEY_A_1_POS_A
		my_key_a_2 = GameState.STATE.KEY_A_2_POS_A
		my_key_a_3 = GameState.STATE.KEY_A_3_POS_A
		my_key_b_1 = GameState.STATE.KEY_B_1_POS_A
		my_key_b_2 = GameState.STATE.KEY_B_2_POS_A
		my_key_b_3 = GameState.STATE.KEY_B_3_POS_A

	if GameState.current_player() == GameState.PLAYER.PLAYER_B:
		my_key_a_1 = GameState.STATE.KEY_A_1_POS_B
		my_key_a_2 = GameState.STATE.KEY_A_2_POS_B
		my_key_a_3 = GameState.STATE.KEY_A_3_POS_B
		my_key_b_1 = GameState.STATE.KEY_B_1_POS_B
		my_key_b_2 = GameState.STATE.KEY_B_2_POS_B
		my_key_b_3 = GameState.STATE.KEY_B_3_POS_B
	
	_update_display()

func _update_display():

	$Inventory/KeyA1.visible = GameState.get_state(my_key_a_1)
	$Inventory/KeyA2.visible = GameState.get_state(my_key_a_2)
	$Inventory/KeyA3.visible = GameState.get_state(my_key_a_3)
	$Inventory/KeyB1.visible = GameState.get_state(my_key_b_1)
	$Inventory/KeyB2.visible = GameState.get_state(my_key_b_2)
	$Inventory/KeyB3.visible = GameState.get_state(my_key_b_3)

	$Dropbox/KeyA1.visible = GameState.get_state(GameState.STATE.KEY_A_1_POS_BOX)
	$Dropbox/KeyA2.visible = GameState.get_state(GameState.STATE.KEY_A_2_POS_BOX)
	$Dropbox/KeyA3.visible = GameState.get_state(GameState.STATE.KEY_A_3_POS_BOX)
	$Dropbox/KeyB1.visible = GameState.get_state(GameState.STATE.KEY_B_1_POS_BOX)
	$Dropbox/KeyB2.visible = GameState.get_state(GameState.STATE.KEY_B_2_POS_BOX)
	$Dropbox/KeyB3.visible = GameState.get_state(GameState.STATE.KEY_B_3_POS_BOX)
	
	for key in $Inventory.get_children():
		if key.visible:
			var area = key.get_node("Area2D")
			if not area.is_connected("mouse_entered", self, "_on_mouse_entered"):
				area.connect("mouse_entered", self, "_on_mouse_entered", ["inventory", key])
				area.connect("mouse_exited", self, "_on_mouse_exited")
	for key in $Dropbox.get_children():
		if key.visible:
			var area = key.get_node("Area2D")
			if not area.is_connected("mouse_entered", self, "_on_mouse_entered"):
				area.connect("mouse_entered", self, "_on_mouse_entered", ["dropbox", key])
				area.connect("mouse_exited", self, "_on_mouse_exited")

var current_key = null

func _on_mouse_entered(collection, key):
	current_key = [collection, key]

func _on_mouse_exited():
	current_key = null

func _input(event):
	if not event.is_action_pressed("click"):
		return
	if current_key == null:
		return
	
	var collection = current_key[0]
	var key = current_key[1]
	
	key.visible = false
	key.disconnect("mouse_entered", self, "_on_mouse_entered")
	var in_dropbox = collection == "inventory"
	match key.name:
		"KeyA1":
			GameState.set_state(my_key_a_1, not in_dropbox)
			GameState.set_state(GameState.STATE.KEY_A_1_POS_BOX, in_dropbox)
		"KeyA2":
			GameState.set_state(my_key_a_2, not in_dropbox)
			GameState.set_state(GameState.STATE.KEY_A_2_POS_BOX, in_dropbox)
		"KeyA3":
			GameState.set_state(my_key_a_3, not in_dropbox)
			GameState.set_state(GameState.STATE.KEY_A_3_POS_BOX, in_dropbox)
		"KeyB1":
			GameState.set_state(my_key_b_1, not in_dropbox)
			GameState.set_state(GameState.STATE.KEY_B_1_POS_BOX, in_dropbox)
		"KeyB2":
			GameState.set_state(my_key_b_2, not in_dropbox)
			GameState.set_state(GameState.STATE.KEY_B_2_POS_BOX, in_dropbox)
		"KeyB3":
			GameState.set_state(my_key_b_3, not in_dropbox)
			GameState.set_state(GameState.STATE.KEY_B_3_POS_BOX, in_dropbox)
	_update_display()

func _on_DoneButton_pressed():
	emit_signal("done")
