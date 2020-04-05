extends Node

""" World Map representation.

The 'world_map' variable below holds the current locations of rooms in the game.
It is used within the game as a ground truth, i.e., changes to this variable
will result in rooms being in different locations in the game.

Throughout the game, rooms are references by the 10-character prefix of their
scene name, dropping any leading 'room_' prefix and adding '_' as a suffix to
get a 10-character long prefix. Examples:
	room_a_xor_key    ==> a_xor_key_
	room_a_xor_puzzle ==> a_xor_puzz
	final_room        ==> final_room
	room_a_002        ==> a_002_____
Note that this means that all room scene names must be unique within this prefix
space to work in the world map. So we can't add a 'room_a_xor_puzzle2' scene.

The world map assumes that all rooms connecting in the 'world_map' variable also
have connecting doors. If this is not the case, add a room-pair to the
'not_connected' variable. One direction is enough; the code checks for both
directions.

NOTE: Rooms still need to set their doors corresponding to the connection on the
map (but don't need to specify what the doors connect to).

This module also holds a variable '_current_room' which tracks the current
location of the player.

SLIDING TILES PUZZLE:
This module contains specific functions for the sliding tile puzzle. Note that
it makes the assumption that the 'entry' room for the puzzle is located to the
top-left of the puzzle, and the 'key' room to the bottom-right. If this is
changed, please update the function '_tile_has_door' accordingly.
"""

# Ugly, should be kept in sync with Room.gd
enum { EAST, NORTH, WEST, SOUTH }

const _empty = "__________"

const world_map := [
		# _0_________,  _1_________,  _2_________,  _3_________,  _4_________,  _5_________,  _6_________,  _7_________,  _8_________,  _9_________,  10_________,  11_________,  12_________,  13_________
		["__________", "a_xor_key_", "__________", "a_north___", "__________", "__________", "__________", "__________", "__________", "__________", "b_wind_key", "__________", "__________", "__________"],  # _0__
		["__________", "a_xor_puzz", "__________", "a_005_____", "a_grid_sol", "a_biome_ke", "__________", "__________", "__________", "__________", "b_wind_cod", "__________", "__________", "__________"],  # _1__
		["__________", "a_xor_star", "__________", "a_004_____", "__________", "a_biome_pa", "__________", "__________", "__________", "b_biome_pi", "b_003_____", "__________", "__________", "__________"],  # _2__
		["a_west____", "a_007_____", "a_006_____", "a_center__", "a_003_____", "a_002_____", "a_final_do", "final_room", "b_final_do", "b_001_____", "b_center__", "b_004_____", "b_grid____", "b_grid_key"],  # _3__
		["__________", "__________", "__________", "a_008_____", "__________", "a_000_____", "a_001_____", "a_dropbox_", "b_dropbox_", "b_000_____", "b_005_____", "__________", "__________", "__________"],  # _4__
		["__________", "__________", "a_tile_sta", "a_009_____", "__________", "__________", "__________", "__________", "b_008_____", "b_007_____", "b_006_____", "__________", "__________", "__________"],  # _5__
		["a_tile_0__", "a_tile_1__", "a_tile_2__", "a_south___", "__________", "__________", "__________", "__________", "b_tile_puz", "__________", "b_xor_swit", "__________", "__________", "__________"],  # _6__
		["a_tile_3__", "a_tile_4__", "a_tile_5__", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________"],  # _7__
		["a_tile_6__", "a_tile_7__", "a_tile_8__", "a_tile_key", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________", "__________"],  # _8__
	]

# List of room-pairs that, while next to each other on the map, do not have a
# shared door.
const not_connected := [
		"a_grid_sol:a_biome_ke",
		"a_tile_key:a_south___",
		"a_002_____:a_000_____",
		"a_dropbox_:b_dropbox_",
		"a_dropbox_:final_room",
		"b_008_____:b_dropbox_",
		"b_000_____:b_007_____",
		"b_000_____:b_005_____",
		"b_000_____:b_001_____",
		"b_biome_pi:b_001_____",
		# Tile rooms:
		"a_tile_0__:a_south___",
		"a_tile_1__:a_south___",
		"a_tile_2__:a_south___",
		"a_tile_3__:a_south___",
		"a_tile_4__:a_south___",
		"a_tile_5__:a_south___",
		"a_tile_6__:a_south___",
		"a_tile_7__:a_south___",
		"a_tile_8__:a_south___",
	]

# The doors in the tile rooms:
# TODO(AniMerrill): Update with the true values.
const tile_room_doors := [
		[EAST, NORTH],   # Room 0.
		[WEST, NORTH],   # Room 1.
		[EAST, SOUTH],   # Room 2.
		[SOUTH, NORTH],  # Room 3.
		[],              # Room 4.
		[EAST, SOUTH],   # Room 5.
		[EAST, WEST],    # Room 6.
		[EAST],          # Room 7.
		[EAST, NORTH],   # Room 8.
	]


var prefix_map = _build_prefix_map()
const _room_dir = "res://game/rooms/"
const _relative_room_dir = "game/rooms/"

func _get_prefix(roomname):
	var prefix = roomname.split(".")[0]
	if prefix.begins_with("room_"):
		prefix = prefix.substr(5)
	prefix = prefix.substr(0, 10)
	var suffix = "_".repeat(10 - prefix.length())
	return prefix + suffix
	

func _build_prefix_map():
	var new_prefix_map = {}
	var dir = Directory.new()
	dir.open(_room_dir)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if not file.ends_with('.tscn'):
			continue
		new_prefix_map[_get_prefix(file)] = file
	
	dir.list_dir_end()
	return new_prefix_map


func loc(room_name : String) -> Vector2:
	var prefix = _get_prefix(room_name)
	for y in range(world_map.size()):
		for x in range(world_map[y].size()):
			if world_map[y][x] == prefix:
				return Vector2(x, y)
	return Vector2(0, 0)

func at(pos : Vector2) -> String:
	return world_map[pos.y][pos.x]

# Locations outside the map are considered empty spaces.
func empty(pos : Vector2) -> bool:
	if pos.x < 0 or pos.y < 0:
		return true
	if pos.y >= world_map.size() or pos.x >= world_map[pos.y].size():
		return true
	return at(pos) == _empty


# Returns true if there is a door between "from" and "to" location. Assumes that
# locations are adjecent on the map.
func has_door(from : Vector2, to : Vector2) -> bool:
	if empty(from) or empty(to):
		return false
	if not_connected.has(at(from) + ":" + at(to)) or \
			not_connected.has(at(to) + ":" + at(from)):
		return false
	if at(from).begins_with("a_tile_") and at(to).begins_with("a_tile_"):
		return _tile_has_door(from, to)
	return true


var _current_room = null

func move_to_room(prefix : String) -> void:
	var target_scene = _relative_room_dir + prefix_map[prefix]
	_current_room = prefix
	SceneTransition.change_scene_fast(target_scene)

func move_to_direction(direction : int) -> void:
	assert(_current_room != null)
	var loc = loc(_current_room)
	match direction:
		NORTH:
			loc += Vector2(0, -1)
		EAST:
			loc += Vector2(1, 0)
		SOUTH:
			loc += Vector2(0, 1)
		WEST:
			loc += Vector2(-1, 0)
	assert(not empty(loc))
	GameState.entering_from_direction = (direction + 2) % 4  # Yay.
	move_to_room(at(loc))

## Below: special API for updating and querying the tile rooms.

var _current_tiles = [0,1,2,3,4,5,6,7,8]
const tile_offset_x = 0
const tile_offset_y = 6

# Updates the world so that the tile rooms are in the specified order.
func set_tile_rooms(room_order : Array) -> void:
	assert(_is_valid_room_order(room_order))
	_current_tiles = room_order
	for y in range(3):
		for x in range(3):
			var room = room_order[y * 3 + x]
			var prefix = "a_tile_" + str(room) + "__"
			world_map[tile_offset_y + y][tile_offset_x + x] = prefix


#  Special logic for the moving tiles.
func _tile_has_door(from : Vector2, to : Vector2) -> bool:
	var from_index = (from.y - tile_offset_y) * 3 + (from.x - tile_offset_x)
	var to_index = (to.y - tile_offset_y) * 3 + (to.x - tile_offset_x)
	var from_doors : Array
	var to_doors : Array
	if from_index >= 0 and from_index <= 8:
		from_doors = tile_room_doors[_current_tiles[from_index]]
	if to_index >= 0 and to_index <= 8:
		to_doors = tile_room_doors[_current_tiles[to_index]]
	
	# Special entry / exit cases.
	if from_index < 0:
		return to_doors.has(NORTH)
	if to_index < 0:
		return from_doors.has(NORTH)
	if from_index > 8:
		return to_doors.has(EAST)
	if to_index > 8:
		return from_doors.has(EAST)
	
	# Recover direction.
	var direction : int
	if from + Vector2(1, 0) == to:
		direction = EAST
	if from + Vector2(-1, 0) == to:
		direction = WEST
	if from + Vector2(0, -1) == to:
		direction = NORTH
	if from + Vector2(0, 1) == to:
		direction = SOUTH
	var other_direction = (direction + 2) % 4
	
	return from_doors.has(direction) and to_doors.has(other_direction)


func _is_valid_room_order(room_order : Array) -> bool:
	if room_order.size() != 9:
		return false
	return room_order.has(0) and room_order.has(1) and room_order.has(2) \
		and room_order.has(3) and room_order.has(4) and room_order.has(5) \
		and room_order.has(6) and room_order.has(7) and room_order.has(8)
