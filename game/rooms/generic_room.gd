tool
extends Node2D


enum DOOR_STATUS {
		NO_DOOR = 1,
		CLOSED_DOOR = 3,
		LOCKED_DOOR = 4
	}

# Just before exiting
const EXIT_DOOR_POS = [Vector2(435, 270), Vector2(240, 180), Vector2(42, 270), Vector2(230, 340)]
# Outside the room
const EXIT_ROOM_POS = [Vector2(500, 270), Vector2(240, 120), Vector2(-42, 270), Vector2(230, 400)]
# Just after entering
const ENTER_DOOR_POS = [Vector2(405, 275), Vector2(240, 210), Vector2(72, 275), Vector2(230, 310)]

const DIRECTION_NAMES = ["east", "north", "west", "south"]

export (DOOR_STATUS) var east_door : int = DOOR_STATUS.NO_DOOR setget _set_east_door
export (DOOR_STATUS) var north_door : int = DOOR_STATUS.NO_DOOR setget _set_north_door
export (DOOR_STATUS) var west_door : int = DOOR_STATUS.NO_DOOR setget _set_west_door
export (DOOR_STATUS) var south_door : int = DOOR_STATUS.NO_DOOR setget _set_south_door

var _is_object_click = false

onready var room = $Room
onready var door_areas = $DoorAreas
onready var player := $ControllablePlayer
onready var room_map := $Navigation2D
onready var map_objects := $Objects
onready var current_name_label = $CurrentRoom/Label


func _ready():
	if Engine.is_editor_hint():
		return
	GameState.interaction_is_frozen = false
	MusicModule.state_changed("explore")
	_update_doors()
	refresh_objects()
	update_final_door()
	current_name_label.text = self.get_parent().name if self.get_parent() else "----"
	# Hacky code to allow loading from a particular room during dev.
	if WorldMap._current_room == null:
		WorldMap._current_room = WorldMap._get_prefix(current_name_label.text)
	if GameState.entering_from_direction >= 0:
		player.position = EXIT_DOOR_POS[GameState.entering_from_direction]
		player.path = [EXIT_DOOR_POS[GameState.entering_from_direction], ENTER_DOOR_POS[GameState.entering_from_direction]]


func _process(_delta):
	# Trick to make player walk in front of and behind objects (part 2).
	if player:
		player.z_index = player.position.y


func _unhandled_input(event):
	yield(get_tree(), "idle_frame")  ## To update _is_object_click if needed.
	if _is_object_click:
		_is_object_click = false
		return
	if event.is_action_pressed("click"):
		if GameState.interaction_is_frozen:
			return
		player_walk_to(event.position)


func _set_east_door(value : int) -> void:
	east_door = value
	_update_doors()

func _set_north_door(value : int) -> void:
	north_door = value
	_update_doors()

func _set_west_door(value : int) -> void:
	west_door = value
	_update_doors()

func _set_south_door(value : int) -> void:
	south_door = value
	_update_doors()


func _update_doors():
	if not room:
		return
	var doors = []
	
	var door_index = -1
	for status in [east_door, north_door, west_door, south_door]:
		door_index += 1
		if status == DOOR_STATUS.NO_DOOR:
			doors.append(null)
		else:
			var opened = GameState.entering_from_direction == door_index and self.get_parent().name != "final_room"
			var locked = status == DOOR_STATUS.LOCKED_DOOR
			doors.append(room.Door.new(locked, opened, not opened))
			var area = door_areas.get_child(door_index)
			if not area.is_connected("input_event", self, "_on_input_event"):
				area.connect("input_event", self, "_on_input_event", [area])

	room.doors = doors
	room.initialize_room()


func _on_input_event(_a, event, _c, node):
	if event is InputEventMouseButton and event.pressed and not GameState.interaction_is_frozen:
		_is_object_click = true
		_handle_object_click(node)
		SoundModule.play_sfx("Click")  # Remove?


func _handle_object_click(node):
	match node.name:
		"East":
			_handle_door_click(room.EAST)
		"North":
			_handle_door_click(room.NORTH)
		"West":
			_handle_door_click(room.WEST)
		"South":
			_handle_door_click(room.SOUTH)
		_:
			if node.has_method("_on_click"):
				node._on_click()


func _handle_door_click(direction):
	var door = room.doors[direction]
	if door.opened and not door.locked:
		player_walk_to(EXIT_DOOR_POS[direction])
		GameState.interaction_is_frozen = true
		yield(player, "position_reached")
		if door.processing:
			yield(door, "action_finished")
		player.path = [EXIT_DOOR_POS[direction], EXIT_ROOM_POS[direction]]
		WorldMap.move_to_direction(direction)
	else:
		door.opened = true


func refresh_objects() -> void:
	if not map_objects:
		return
	for node in map_objects.get_children():
		# Trick to make player walk in front of and behind objects (part 1).
		node.z_index = node.position.y
		if node.has_node("Area2D"):
			var area = node.get_node("Area2D")
			if not area.is_connected("input_event", self, "_on_input_event"):
				area.connect("input_event", self, "_on_input_event", [node])


func player_walk_to(target_position, forced=false):
	if GameState.interaction_is_frozen and not forced:
		return
	
	var path = room_map.get_simple_path(player.position, target_position)
	
	if path.size() > 1:
		# If distance between first two path points is less than a footstep,
		# ignore and remain in place
		if path[0].distance_to(path[1]) > player.MOVE_EPSILON * 2.0:
			player.path = path
		else:
			# This allows the "position_reached" signal to emit w/o moving
			player.path = [path[0]]


var final_door_east = false
var final_door_west = false

func set_final_door_east():
	final_door_east = true
	
func set_final_door_west():
	final_door_west = true

func update_final_door():
	if final_door_east:
		room.set_final_door_east()
	if final_door_west:
		room.set_final_door_west()
