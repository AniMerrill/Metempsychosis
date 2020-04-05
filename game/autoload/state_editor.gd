extends CanvasLayer


var new_state
var tile_state := [0,1,2,3,4,5,6,7,8]

onready var editor = $StateEditor
onready var other_states = $StateEditor/Frame/OtherState/VBoxContainer
onready var key_states = $StateEditor/Frame/KeyState/VBoxContainer
onready var custom_a_states = $StateEditor/Frame/CustomAState/VBoxContainer
onready var custom_b_states = $StateEditor/Frame/CustomBState/VBoxContainer
onready var state_code_a = $StateEditor/Frame/StateCodeA
onready var state_code_b = $StateEditor/Frame/StateCodeB
onready var player_a = $StateEditor/Frame/PlayerA
onready var player_b = $StateEditor/Frame/PlayerB
onready var room_select = $StateEditor/Frame/RoomSelect
onready var tile_popup = $StateEditor/Frame/TilesPopup
onready var tile_options = $StateEditor/Frame/TilesPopup/Options


func _ready():
	editor.visible = false
	tile_popup.visible = false
	
	# Room selection
	room_select.add_item("(In Menu)")
	for item in WorldMap.prefix_map.keys():
		room_select.add_item(item)
	
	# Sliding tiles
	for index in range(9):
		for value in range(9):
			tile_options.get_child(index).add_item(str(value))
		tile_options.get_child(index).connect(
				"item_selected", self, "on_tile_selected", [index])


func _input(_event):
	if Input.is_action_just_pressed("cheat"):
		editor.visible = not editor.visible
		reload()


func _clear_node(node):
	for child in node.get_children():
		node.remove_child(child)


func _update_state_code():
	state_code_a.text = new_state.serialize(GameState.PLAYER.PLAYER_A)
	state_code_b.text = new_state.serialize(GameState.PLAYER.PLAYER_B)


func _on_toggled(cbox, key):
	new_state.set_state(GameState.STATE.get(key), cbox.pressed)
	_update_state_code()


func _on_StartButton_pressed():
	if GameState.get_state(GameState.STATE.CODE_CREATED_BY_PLAYER_A):
		GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	else:
		GameState.set_current_player(GameState.PLAYER.PLAYER_A)


func _on_ExitButton_pressed():
	editor.visible = false


func _on_SaveButton_pressed():
	var code = ""
	
	new_state.set_slide_puzzle_state(tile_state)
	
	if player_a.pressed:
		GameState.set_current_player(GameState.PLAYER.PLAYER_A)
		code = new_state.serialize(GameState.PLAYER.PLAYER_A)
	else:
		GameState.set_current_player(GameState.PLAYER.PLAYER_B)
		code = new_state.serialize(GameState.PLAYER.PLAYER_B)
	
	GameState.set_last_output_code(code)
	# warning-ignore:return_value_discarded
	GameState.deserialize(code)
	
	var selected_room = room_select.get_item_text(room_select.selected)
	if room_select.selected > 0 and selected_room != WorldMap._current_room:
		WorldMap.move_to_room(selected_room)
		editor.visible = false
	else:
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
		editor.visible = false


func _on_PlayerA_pressed():
	player_b.pressed = not player_a.pressed


func _on_PlayerB_pressed():
	player_a.pressed = not player_b.pressed


func _on_TilesDoneButton_pressed():
	tile_popup.visible = false


func _on_TilesButton_pressed():
	tile_popup.visible = true


func _on_TilesResetButton_pressed():
	tile_state = GameState.get_slide_puzzle_state()
	update_tiles()


func reload():
	new_state = load('res://game/autoload/game_state.gd').new()
	
	_clear_node(other_states)
	_clear_node(key_states)
	_clear_node(custom_a_states)
	_clear_node(custom_b_states)
	
	# Room selection
	var index = 1
	var selected_index = 0
	for item in WorldMap.prefix_map.keys():
		if item == WorldMap._current_room:
			selected_index = index
		index += 1
	room_select.select(selected_index)
	
	# Tile editing
	tile_state = GameState.get_slide_puzzle_state()
	update_tiles()
	
	var player_is_a = GameState.current_player() == GameState.PLAYER.PLAYER_A
	player_a.pressed = player_is_a
	player_b.pressed = not player_is_a
	
	for key in GameState.STATE.keys():
		var state_container = other_states
		if key == "CODE_CREATED_BY_PLAYER_A":
			continue  # Handled in serialize function.
		if key.begins_with("SLIDING_TILE_BIT"):
			var is_set = GameState.get_state(GameState.STATE.get(key))
			new_state.set_state(GameState.STATE.get(key), is_set)
			continue  # Handled in separate window.
		if key.begins_with("KEY_"):
			state_container = key_states
		if key.begins_with("PLAYER_A") and not key == "PLAYER_A_IN_XOR_POD":
			state_container = custom_a_states
		if key.begins_with("PLAYER_B"):
			state_container = custom_b_states
		var c = CheckBox.new()
		c.pressed = GameState.get_state(GameState.STATE.get(key))
		new_state.set_state(GameState.STATE.get(key), c.pressed)
		c.text = key
		state_container.add_child(c)
		c.connect("pressed", self, "_on_toggled", [c, key])
	_update_state_code()


func update_tiles():
	for index in range(9):
		tile_options.get_child(index).select(tile_state[index])


# Swap with the chosen value.
func on_tile_selected(tile_value, tile_index):
	print(tile_value)
	var old_index = tile_state.find(tile_value)
	var old_value = tile_state[tile_index]
	tile_state[tile_index] = tile_value
	tile_state[old_index] = old_value
	update_tiles()
