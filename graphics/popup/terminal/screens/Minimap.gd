extends Control

var parent_menu = null

export var current_room := Vector2()

var blink := false

const room_names := {
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
	
	$Timer.connect("timeout", self, "toggle_blink")
	
	connect("draw", self, "_draw")
	
	connect("visibility_changed", self, "visibility_changed")
	
	$RoomName.text = room_names.get(WorldMap.at(current_room), "")


func _draw():
	var spacing := Vector2(1.5, 1.5)
	var offset := Vector2(75, 55) - current_room * 10 * spacing
	
	for y in 8:
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
	
	$RoomName.text = room_names.get(WorldMap.at(current_room), "")

func toggle_blink():
	blink = not blink
	update()

func visibility_changed():
	if not GameState.key_on_floor(GameState.STATE.KEY_B_1_POS_A):
		room_names["a_biome_ke"] = ""
	if not GameState.key_on_floor(GameState.STATE.KEY_B_2_POS_A):
		room_names["a_xor_key_"] = ""
	if not GameState.key_on_floor(GameState.STATE.KEY_B_3_POS_A):
		room_names["a_tile_key"] = ""
	
	# Key A_1 is in the dropbox room.
	if not GameState.key_on_floor(GameState.STATE.KEY_A_2_POS_A):
		room_names["b_wind_key"] = ""
	if not GameState.key_on_floor(GameState.STATE.KEY_A_3_POS_A):
		room_names["b_grid_key"] = ""
