extends Node2D

onready var player = $ControllablePlayer
onready var nav_map = $Navigation2D
onready var map = $Map

func _input(event):
	if event.is_action_pressed("click"):
		player.path = nav_map.get_simple_path(player.position, event.position)

# Ugly trick to make player walk in front of and behind objects.
#
# All map objects need to be Node2D's and their position should be in the
# center of the objects.
# At the beginning, set the Z index of all map objects to their y position.
# Next, constantly update the Z index of the player to be their y position as
# well. This will (in general) place the player at the right relative position.

func _ready():
	for node in map.get_children():
		node.z_index = node.position.y

func _process(delta):
	player.z_index = player.position.y