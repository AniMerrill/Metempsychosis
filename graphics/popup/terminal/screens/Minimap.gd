extends Control


const ROOM_NAMES := {
		"a_000_____": "Representative #1 Cryrostasis",
		"a_dropbox_": "[DROPBOX]",
		"a_biome_ke": "[KEY]",
		"a_xor_key_": "[KEY]",
		"a_tile_key": "[KEY]",
		"a_north___": "North Room",
		"a_west____": "West Room",
		"a_003_____": "East Room",
		"a_south___": "South Room",
		"a_xor_puzz": "Exclusive Suite",
		"a_biome_pa": "Noise Terminal",
		"a_final_do": "Blue Triple Lock",
		"a_tile_sta": "Sliding",
		
		# Debugging only?
		"a_tile_0__": "T_00",
		"a_tile_1__": "T_01",
		"a_tile_2__": "T_02",
		"a_tile_3__": "T_03",
		"a_tile_4__": "T_04",
		"a_tile_5__": "T_05",
		"a_tile_6__": "T_06",
		"a_tile_7__": "T_07",
		"a_tile_8__": "T_08",
		
		"b_000_____": "Representative #2 Cryrostasis",
		"b_dropbox_": "[DROPBOX]",
		"b_wind_key": "[KEY]",
		"b_grid_key": "[KEY]",
		"b_tile_puz": "Sliding Chamber Control",
		"b_wind_cod": "Colors of the Wind",
		"b_biome_pi": "Art Gallery",
		"b_final_do": "Red Triple Lock",
		"b_grid____": "Grid Room",
		"b_xor_swit": "Switch Room",
		
		"final_room": "[MACHINE]"
	}

export var current_room := Vector2()

var parent_menu = null
var blink := false


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$Up.connect("pressed", self, "direction_pressed", [Vector2(0, -1)])
	# warning-ignore:return_value_discarded
	$Down.connect("pressed", self, "direction_pressed", [Vector2(0, 1)])
	# warning-ignore:return_value_discarded
	$Left.connect("pressed", self, "direction_pressed", [Vector2(-1, 0)])
	# warning-ignore:return_value_discarded
	$Right.connect("pressed", self, "direction_pressed", [Vector2(1, 0)])
	# warning-ignore:return_value_discarded
	$X.connect("pressed", self, "x_pressed")
	
	# warning-ignore:return_value_discarded
	$Timer.connect("timeout", self, "toggle_blink")
	
	# warning-ignore:return_value_discarded
	connect("draw", self, "_draw")
	
	# warning-ignore:return_value_discarded
	connect("visibility_changed", self, "_on_visibility_changed")
	
	$RoomName.text = ROOM_NAMES.get(WorldMap.at(current_room), "")


func _draw():
	var spacing := Vector2(1.5, 1.5)
	var offset := Vector2(75, 55) - current_room * 10 * spacing
	
	for y in 9:
		for x in 15:
			var x_pos = x * 10 * spacing.x + offset.x
			var y_pos = y * 10 * spacing.y + offset.y
			
			if x_pos < 0 or y_pos < 0:
				continue
			
			_draw_door(Vector2(x, y), x_pos, y_pos)
	
	if blink:
		var x_pos = current_room.x * 10 * spacing.x + offset.x
		var y_pos = current_room.y * 10 * spacing.y + offset.y
		draw_rect(Rect2(x_pos, y_pos, 10, 10), Color("#b9ff36"), true)


func _draw_door(loc, x_pos, y_pos):
	if WorldMap.empty(loc):
		return
	# Doors.
	if WorldMap.has_door(loc, loc + Vector2(0, -1)):  # North.
		draw_rect(Rect2(x_pos + 2.5, y_pos - 5, 5, 5), Color("#576f2a"), false)
	if WorldMap.has_door(loc, loc + Vector2(0, 1)):  # South.
		draw_rect(Rect2(x_pos + 2.5, y_pos + 10, 5, 5), Color("#576f2a"), false)
	if WorldMap.has_door(loc, loc + Vector2(-1, 0)):  # West.
		draw_rect(Rect2(x_pos - 5, y_pos + 2.5, 5, 5), Color("#576f2a"), false)
	if WorldMap.has_door(loc, loc + Vector2(1, 0)):  # East.
		draw_rect(Rect2(x_pos + 10, y_pos + 2.5, 5, 5), Color("#576f2a"), false)
	# Room.
	draw_rect(Rect2(x_pos, y_pos, 10, 10), Color("#576f2a"), false)


func _on_visibility_changed():
	if not GameState.key_on_floor(GameState.STATE.KEY_B_1_POS_A):
		ROOM_NAMES["a_biome_ke"] = ""
	if not GameState.key_on_floor(GameState.STATE.KEY_B_2_POS_A):
		ROOM_NAMES["a_xor_key_"] = ""
	if not GameState.key_on_floor(GameState.STATE.KEY_B_3_POS_A):
		ROOM_NAMES["a_tile_key"] = ""
	
	# Key A_1 is in the dropbox room.
	if not GameState.key_on_floor(GameState.STATE.KEY_A_2_POS_A):
		ROOM_NAMES["b_wind_key"] = ""
	if not GameState.key_on_floor(GameState.STATE.KEY_A_3_POS_A):
		ROOM_NAMES["b_grid_key"] = ""


func x_pressed() -> void:
	if parent_menu != null:
		visible = false
		parent_menu.set_visibility(true)


func direction_pressed(direction : Vector2) -> void:
	var new_room = current_room + direction
	while WorldMap.empty(new_room):
		new_room += direction
		new_room.x = int(new_room.x + 16) % 16
		new_room.y = int(new_room.y + 9) % 9
	current_room = new_room
	
	blink = false
	toggle_blink()
	
	$RoomName.text = ROOM_NAMES.get(WorldMap.at(current_room), "")


func toggle_blink():
	blink = not blink
	update()

