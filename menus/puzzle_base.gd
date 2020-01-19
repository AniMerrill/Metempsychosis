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

signal solved()

func _ready():
	north_element.connect("mouse_entered", self, "_on_mouse_entered", [north_element])
	south_element.connect("mouse_entered", self, "_on_mouse_entered", [south_element])
	west_element.connect("mouse_entered", self, "_on_mouse_entered", [west_element])
	east_element.connect("mouse_entered", self, "_on_mouse_entered", [east_element])
	
	north_element.connect("mouse_exited", self, "_on_mouse_exited")
	south_element.connect("mouse_exited", self, "_on_mouse_exited")
	west_element.connect("mouse_exited", self, "_on_mouse_exited")
	east_element.connect("mouse_exited", self, "_on_mouse_exited")

var _current_hovered_node = null

func _on_mouse_entered(node) -> void:
	_current_hovered_node = node

func _on_mouse_exited() -> void:
	_current_hovered_node = null

func _input(event):
	if event.is_action_pressed("click") and _current_hovered_node != null:
		_change_color(_current_hovered_node)
		get_tree().set_input_as_handled()

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
	if _solved():
		emit_signal("solved")

func _solved():
	return (
			north_element.color == Color.red and
			south_element.color == Color.purple and
			west_element.color == Color.green and
			east_element.color == Color.blue
		)