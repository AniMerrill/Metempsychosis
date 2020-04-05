""" Verify that doors are connected in the right fashion.

Verifies that if door NORTH in room A is connected to room B, then room B should
exist and have a SOUTH door connected to room A. Similarly for all directions.

File -> Run.
"""
tool
extends EditorScript

var all_rooms := []

func _get_rooms():
	var files = []
	var dir = Directory.new()
	dir.open("res://rooms")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with('.tscn'):
			files.append(file)
	
	dir.list_dir_end()
	files.sort()
	return files

func _get_door(room, direction):
	match direction:
		'east':
			return room.east_door
		'north':
			return room.north_door
		'west':
			return room.west_door
		'south':
			return room.south_door

func _get_target(room, direction):
	match direction:
		'east':
			return room.east_target
		'north':
			return room.north_target
		'west':
			return room.west_target
		'south':
			return room.south_target

func _get_opposite(direction):
	match direction:
		'east':
			return 'west'
		'north':
			return 'south'
		'west':
			return 'east'
		'south':
			return 'north'

func _verify_door(scene_name, room, direction):
	if _get_door(room, direction) == room.DOOR_STATUS.NO_DOOR:
		return
	var target = _get_target(room, direction) + '.tscn'
	if not all_rooms.has(target):
		print("ERROR: " + scene_name + " connects " + direction + " to " + target + " which does not exist.")
		return
	var t_roomscene = load("res://rooms/" + target).instance()
	if not t_roomscene.has_node("GenericRoom"):
		print("ERROR: " + scene_name + " connects " + direction + " to " + target + " which has no GenericRoom node.")
		return
	var t_room = t_roomscene.get_node("GenericRoom")
	var t_direction = _get_opposite(direction)
	if _get_door(t_room, t_direction) == room.DOOR_STATUS.NO_DOOR:
		print("ERROR: " + scene_name + " connects " + direction + " to " + target + " which has no door going " + t_direction + ".")
		return
	var ret_target = _get_target(t_room, t_direction) + '.tscn'
	if ret_target != scene_name:
		print("ERROR: " + scene_name + " connects " + direction + " to " + target + " but its " + t_direction + " door goes to " + ret_target)


func _verify_doors(scene_name):
	var scene = load("res://rooms/" + scene_name).instance()
	if scene_name != scene.name + ".tscn":
		print("ERROR: " + scene_name + " has incorrect name: " + scene.name)
	
	if not scene.has_node("GenericRoom"):
		print("Warning: No GenericRoom node in " + scene_name)
		return
	var room = scene.get_node("GenericRoom")
	
#	_verify_door(scene_name, room, 'east')
#	_verify_door(scene_name, room, 'north')
#	_verify_door(scene_name, room, 'west')
#	_verify_door(scene_name, room, 'south')

func _run():
	all_rooms = _get_rooms()
	print("Starting verification...")
	for room in all_rooms:
		_verify_doors(room)
	print("Done.")
