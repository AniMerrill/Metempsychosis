extends Control

"""
WARNING: The way the code below is written might disappoint you


The scene this script is attached too is not currently affecting
anything, but it works
"""

onready var north_element = get_node("north")
onready var south_element = get_node("south")
onready var west_element = get_node("west")
onready var east_element = get_node("east")

func _ready():
	north_element.connect("mouse_entered", self, "_on_mouse_entered", [north_element])
	south_element.connect("mouse_entered", self, "_on_mouse_entered", [south_element])
	west_element.connect("mouse_entered", self, "_on_mouse_entered", [west_element])
	east_element.connect("mouse_entered", self, "_on_mouse_entered", [east_element])

var _current_hovered_node = null

func _on_mouse_entered(node) -> void:
	_current_hovered_node = node

func _on_mouse_exited() -> void:
	_current_hovered_node = null

func _input(event):
	if event.is_action_pressed("click"):
		_change_color(_current_hovered_node)

func _change_color(node : ColorRect):
	if node.color == Color.red:
		node.color = Color.blue
	elif node.color == Color.blue:
		node.color = Color.green
	elif node.color == Color.green:
		node.color = Color.purple
	elif node.color == Color.purple:
		node.color = Color.red
	else:
		node.color = Color.red
	
	_node_color_updated(node)

func _node_color_updated(node):
	if node.name == "north":
		if node.color == Color.red:
			print("North is the correct color")
	if node.name == "south":
		if node.color == Color.blue:
			print("South is the correcct color")
	if node.name == "west":
		if node.color == Color.green:
			print("West is the correct color")
	if node.name == "east":
		if node.color == Color.purple:
			print("East color is correct")