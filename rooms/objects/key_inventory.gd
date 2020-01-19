extends Node2D

onready var keys = []

signal key_removed(key)

export var actionable = true

func _ready():
	keys = [$KeyA1, $KeyA2, $KeyA3, $KeyB1, $KeyB2, $KeyB3]
	for key in keys:
		key.get_node("Area2D").connect("input_event", self, "_on_input_event", [key])
		key.visible = false

func _on_input_event(a, event, c, node):
	if event is InputEventMouseButton and event.pressed and actionable:
		emit_signal("key_removed", keys.find(node))
		node.visible = false

func add_key(index):
	keys[index].visible = true

func get_keys():
	var result = []
	for i in range(keys.size()):
		if keys[i].visible:
			result.append(i)
	return result
