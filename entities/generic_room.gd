tool
extends Node2D

onready var room = $Room
onready var door_areas = $DoorAreas
onready var player := $ControllablePlayer
onready var room_map := $Navigation2D
onready var map_objects := $Objects
onready var current_name_label = $CurrentRoom/Label

signal object_clicked(node)

enum DOOR_STATUS {
		NO_DOOR = 1,
		CLOSED_DOOR = 3,
		LOCKED_DOOR = 4
	}

export (DOOR_STATUS) var east_door : int = DOOR_STATUS.NO_DOOR setget _set_east_door
export (String) var east_target : String = "" setget _set_east_door_target

export (DOOR_STATUS) var north_door : int = DOOR_STATUS.NO_DOOR setget _set_north_door
export (String) var north_target : String = "" setget _set_north_door_target

export (DOOR_STATUS) var west_door : int = DOOR_STATUS.NO_DOOR setget _set_west_door
export (String) var west_target : String = "" setget _set_west_door_target

export (DOOR_STATUS) var south_door : int = DOOR_STATUS.NO_DOOR setget _set_south_door
export (String) var south_target : String = "" setget _set_south_door_target


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


var door_targets = ['', '', '', '']

func _set_east_door_target(value : String) -> void:
	east_target = value
	door_targets[0] = value

func _set_north_door_target(value : String) -> void:
	north_target = value
	door_targets[1] = value

func _set_west_door_target(value : String) -> void:
	west_target = value
	door_targets[2] = value

func _set_south_door_target(value : String) -> void:
	south_target = value
	door_targets[3] = value


# Just before exiting
const exit_door_pos = [Vector2(435, 270), Vector2(240, 180), Vector2(42, 270), Vector2(230, 340)]
# Outside the room
const exit_room_pos = [Vector2(500, 270), Vector2(240, 120), Vector2(-42, 270), Vector2(230, 400)]
# Just after entering
const enter_door_pos = [Vector2(405, 275), Vector2(240, 210), Vector2(72, 275), Vector2(230, 310)]

func _ready():
	if not room:
		return
	if GameState:
		GameState.interaction_is_frozen = false
	_update_doors()
	refresh_objects()
	current_name_label.text = self.get_parent().name if self.get_parent() else "----"
	if GameState.entering_from_direction >= 0:
		player.position = exit_door_pos[GameState.entering_from_direction]
		player.path = [exit_door_pos[GameState.entering_from_direction], enter_door_pos[GameState.entering_from_direction]]
	

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
			doors.append(room.Door.new(locked, opened))
			var area = door_areas.get_child(door_index)
			if not area.is_connected("input_event", self, "_on_input_event"):
				area.connect("input_event", self, "_on_input_event", [area])

	room.doors = doors
	room.initialize_room()


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


func _process(delta):
	# Trick to make player walk in front of and behind objects (part 2).
	if player:
		player.z_index = player.position.y


var _is_object_click = false
func _on_input_event(a, event, c, node):
	if event is InputEventMouseButton and event.pressed:
		_is_object_click = true
		_handle_object_click(node)


func _unhandled_input(event):
	yield(get_tree(), "idle_frame")
#	yield(get_tree().create_timer(0.01), "timeout")
	if _is_object_click:
		_is_object_click = false
		return
	if event.is_action_pressed("click"):
		if GameState.interaction_is_frozen:
			return
		player_walk_to(event.position)


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
			emit_signal("object_clicked", node)

const direction_names = ["east", "north", "west", "south"]

func _handle_door_click(direction):
	var door = room.doors[direction]
	if door.opened and not door.locked:
		player_walk_to(exit_door_pos[direction])
		GameState.interaction_is_frozen = true
		yield(player, "position_reached")
		if door.processing:
			yield(door, "action_finished")
		player.path = [exit_door_pos[direction], exit_room_pos[direction]]
		var target_scene = 'rooms/' + door_targets[direction] + '.tscn'
		GameState.entering_from_direction = (direction + 2) % 4  # Yay.
		SceneTransition.change_scene_fast(target_scene)
	else:
		door.opened = true

func player_walk_to(target_position):
	if GameState.interaction_is_frozen:
		return
	var path = room_map.get_simple_path(player.position, target_position)
	if path.size() > 0:
		player.path = path


func set_final_door_east():
	room.set_final_door_east()
	
func set_final_door_west():
	room.set_final_door_west()