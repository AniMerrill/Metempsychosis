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
"""

# Ugly, should be kept in sync with Room.gd
enum { EAST, NORTH, WEST, SOUTH }

const _empty = "__________"

var world_map := [
		# _0_________,  _1_________,  _2_________,  _3_________,  _4_________,  _5_________,  _6_________,  _7_________,  _8_________,  _9_________,  10_________,  11_________,  12_________,  13_________
		["__________", "a_xor_key_", "__________", "a_north___", "__________", "__________", "__________", "__________", "__________", "__________", "b_wind_key", "__________", "__________", "__________"],  # _0__
		["__________", "a_xor_puzz", "__________", "a_005_____", "a_grid_sol", "a_biome_ke", "__________", "__________", "__________", "__________", "b_wind_cod", "__________", "__________", "__________"],  # _1__
		["__________", "a_xor_star", "__________", "a_004_____", "__________", "a_biome_pa", "__________", "__________", "__________", "b_biome_pi", "b_003_____", "__________", "__________", "__________"],  # _2__
		["a_west____", "a_007_____", "a_006_____", "a_center__", "a_003_____", "a_002_____", "a_final_do", "final_room", "b_final_do", "b_001_____", "b_center__", "b_004_____", "b_grid____", "b_grid_key"],  # _3__
		["__________", "__________", "__________", "a_008_____", "__________", "a_000_____", "a_001_____", "a_dropbox_", "b_dropbox_", "b_000_____", "b_005_____", "__________", "__________", "__________"],  # _4__
		["__________", "__________", "a_tile_sta", "a_009_____", "__________", "__________", "__________", "__________", "b_008_____", "b_007_____", "b_006_____", "__________", "__________", "__________"],  # _5__
		["__________", "__________", "a_tile_key", "a_south___", "__________", "__________", "__________", "__________", "b_tile_puz", "__________", "b_xor_swit", "__________", "__________", "__________"],  # _6__
	]

# List of room-pairs that, while next to each other on the map, do not have a
# shared door.
var not_connected := [
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
	]


var prefix_map = _build_prefix_map()
const _room_dir = "res://rooms/"

func _get_prefix(roomname):
	var prefix = roomname.split(".")[0]
	if prefix.begins_with("room_"):
		prefix = prefix.substr(5)
	prefix = prefix.substr(0, 10)
	var suffix = "_".repeat(10 - prefix.length())
	return prefix + suffix
	

func _build_prefix_map():
	var prefix_map = {}
	var dir = Directory.new()
	dir.open(_room_dir)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		if not file.ends_with('.tscn'):
			continue
		prefix_map[_get_prefix(file)] = file
	
	dir.list_dir_end()
	return prefix_map


func at(pos : Vector2) -> String:
	return world_map[pos.y][pos.x]

# Locations outside the map are considered empty spaces.
func empty(pos : Vector2) -> bool:
	if pos.x < 0 or pos.y < 0:
		return true
	if pos.y >= world_map.size() or pos.x >= world_map[pos.y].size():
		return true
	return at(pos) == _empty


func has_door(from, to) -> bool:
	if empty(from) or empty(to):
		return false
	if not_connected.has(at(from) + ":" + at(to)) or \
			not_connected.has(at(to) + ":" + at(from)):
		return false
	return true

var _current_room = null

func move_to_room(prefix : String) -> void:
	var target_scene = 'rooms/' + prefix_map[prefix]
	_current_room = prefix
	SceneTransition.change_scene_fast(target_scene)

func move_to_direction(direction : int) -> void:
	assert(_current_room != null)
	var loc = Vector2()
	for y in range(world_map.size()):
		for x in range(world_map[y].size()):
			if world_map[y][x] == _current_room:
				loc = Vector2(x, y)
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
