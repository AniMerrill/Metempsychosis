tool
extends Node2D

onready var room = $Room
onready var door_areas = $DoorAreas
onready var player := $ControllablePlayer
onready var room_map := $Navigation2D
onready var map_objects := $Objects

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

func _ready():
	GameState.interaction_is_frozen = false
	_update_doors()
	refresh_objects()

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
			doors.append(room.Door.new(status == DOOR_STATUS.LOCKED_DOOR))
			var area = door_areas.get_child(door_index)
			if not area.is_connected("mouse_entered", self, "_on_mouse_entered"):
				area.connect("mouse_entered", self, "_on_mouse_entered", [area])
				area.connect("mouse_exited", self, "_on_mouse_exited")

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
			if not area.is_connected("mouse_entered", self, "_on_mouse_entered"):
				area.connect("mouse_entered", self, "_on_mouse_entered", [node])
				area.connect("mouse_exited", self, "_on_mouse_exited")


func _process(delta):
	# Trick to make player walk in front of and behind objects (part 2).
	if player:
		player.z_index = player.position.y


var _current_hovered_node = null

func _on_mouse_entered(node : Node2D) -> void:
	_current_hovered_node = node

func _on_mouse_exited() -> void:
	_current_hovered_node = null


func _input(event):
	if event.is_action_pressed("click"):
		if _current_hovered_node == null:
			_walk_to(event.position)
		else:
			_handle_object_click(_current_hovered_node)


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

const exit_door_pos = [Vector2(435, 270), Vector2(0,0), Vector2(42,270), Vector2(0,0)]

const direction_names = ["east", "north", "west", "south"]

func _handle_door_click(direction):
	var door = room.doors[direction]
	if door.opened and not GameState.interaction_is_frozen:
		_walk_to(exit_door_pos[direction])
		GameState.interaction_is_frozen = true
		yield(player, "position_reached")
		var target_scene = 'rooms/' + door_targets[direction] + '.tscn'
		print(target_scene)
		SceneTransition.change_scene(target_scene)
	else:
		door.opened = true
		GameState.interaction_is_frozen = true
		yield(door, "action_finished")
		GameState.interaction_is_frozen = false

func _walk_to(target_position):
	if GameState.interaction_is_frozen:
		return
	var path = room_map.get_simple_path(player.position, target_position)
	if path.size() > 0:
		player.path = path
