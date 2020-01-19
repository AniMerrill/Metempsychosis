extends Node2D

onready var room = $GenericRoom
onready var player = $GenericRoom/ControllablePlayer

export var light_message := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"ColorLight":
			RoomUtil.display_message([light_message])
			yield(MessageDisplay, "messages_finished")