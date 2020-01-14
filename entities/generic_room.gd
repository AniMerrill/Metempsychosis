""" Displays a room as specified in a JSON file.

The JSON file is dictionary of entries of the following format:
(NOTE that the actual JSON format does not support comments)

{
	'room_name': {
			## If a direction is not listed, no door is shown.
			'east': {
				## If not listed, the default will be unlocked.
				'default_locked': true,
				## Required. The room that lies behind this door.
				'target': 'other_room_name',
			},
			## List of objects present in this room.
			'objects': [
					'sleeping_pod_left',
					'info_table',
				],
		}
}

Note: Everything can be overridden by the GameState. For example, after solving
a puzzle a door that is locked by default will now be unlocked when entering
the room. Or an object that was not there before is not visible and vice-versa.

The elements specified in the JSON file need to be present in the GenericRoom
scene as follows:
	- Every 'room_name' should have an equivalently named navigation map in the
	  NavigationMaps node. You can copy the example map, but make sure to *Make
	  Unique* the NavigationPolygonInstance otherwise you will accidentally
	  change other maps as well. The example map is also the fallback map in
	  case no map is specified (can be useful for empty / no obstacle rooms).
	- Every listed object should correspond to a similarly named Node2D under
	  the 'Objects' node.
"""

extends Node2D

onready var player := $ControllablePlayer
onready var navigation_maps := $NavigationMaps
onready var current_map := $CurrentMap
onready var map_objects := $Objects
onready var room := $Room

const map_file = "res://data/map_data_json.txt"
const current_room_name = "room_a_000"  # TODO(ereborn): Get as argument.
var current_room_data


func _input(event):
	if event.is_action_pressed("click"):
		var path = current_map.get_simple_path(player.position, event.position)
		if path.size() > 0:
			player.path = path


func _ready():
	visible = false
	_load_current_room()
	_prepare_room_objects()
	_set_current_map()
	_install_doors()
	visible = true




func _load_current_room():
	var map_fp := File.new()
	map_fp.open(map_file, File.READ)
	var map_data = parse_json(map_fp.get_as_text())
	map_fp.close()
	if not map_data.has(current_room_name):
		printerr("ERROR: No map data available for room " + current_room_name)
	current_room_data = map_data[current_room_name]


func _prepare_room_objects():
	var visible_objects = current_room_data['objects'] if current_room_data.has("objects") else []
	for node in map_objects.get_children():
		node.visible = visible_objects.has(node.name)
		if node.visible:
			# Trick to make player walk in front of and behind objects.
			node.z_index = node.position.y


func _set_current_map():
	var room_map
	if not navigation_maps.has_node(current_room_name):
		printerr("WARNING: No navigation map available for room " + current_room_name)
		printerr("WARNING: Using default map")
		room_map = navigation_maps.get_node("__example_map__MAKE_UNIQUE")
	else:
		room_map = navigation_maps.get_node(current_room_name)
	var room_map_poly = room_map.get_node("NavigationPolygonInstance").navpoly
	current_map.navpoly_add(room_map_poly, Transform2D.IDENTITY)


func _install_doors():
	var doors = []
	for direction in ["east", "north", "west", "south"]:
		if not current_room_data.has(direction):
			doors.append(null)
			continue
		var door_data = current_room_data[direction]
		var locked = door_data.has("default_locked") and door_data["default_locked"]
		doors.append(room.Door.new(locked))
	room.doors = doors


func _process(delta):
	# Trick to make player walk in front of and behind objects.
	player.z_index = player.position.y