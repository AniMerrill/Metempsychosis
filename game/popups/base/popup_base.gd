extends Node2D

"""
Add an element to the popup simply by making them a child of the popup.
The only caveat is that the path changes after the _ready function is called,
so make sure to store any children you want to access later in either _ready
or as onready variables. E.g.:

onready var my_content = $Popup/MyContent
"""

onready var content = $CanvasLayer/ActualPopup/Content
onready var canvas_layer = $CanvasLayer
onready var popup = $CanvasLayer/ActualPopup

signal closed()
signal opened()

func _ready():
	visible = false
	self.position = get_global_transform().origin * Vector2(-1,-1) + Vector2(38,38) * 2
	if not find_parent("GenericRoom"):  # Show if only loading popup scene
		# Allow _ready from other nodes to finish.
		yield(get_tree().create_timer(0.5), "timeout")
		popup()

func popup():
	if content.get_child_count() == 0:
		move_children_inside_rec(self)
	visible = true
	get_parent().visible = true
	emit_signal("opened")

func _on_XButton_pressed():
	visible = false
	emit_signal("closed")

func get_inner_content_node():
	return content

func get_own_top_level_nodes():
	return [canvas_layer]

func move_children_inside_rec(node):
	for child in node.get_children():
		move_children_inside_rec(child)
	move_children_inside(node)

func move_children_inside(node):
	if (not node.has_method("get_inner_content_node") or
		not node.has_method("get_own_top_level_nodes")):
		return
	var content = node.get_inner_content_node()
	var own_nodes = node.get_own_top_level_nodes()
	if content.get_child_count() > 0:
		# Already moved kids inside.
		return
	for child in node.get_children():
		if not own_nodes.has(child):
			node.remove_child(child)
			content.add_child(child)
			child.set_owner(content)
	if node.has_method("_on_children_moved_inside"):
		node._on_children_moved_inside()
