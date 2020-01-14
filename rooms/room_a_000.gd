extends Node2D

onready var room = $GenericRoom

func _ready():
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"Table":
			print("What an ugly table.")
		"Pod":
			print("Time to sleep already?")
