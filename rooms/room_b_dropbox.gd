extends Node2D

onready var room = $GenericRoom
onready var dropbox := $GenericRoom/Objects/Dropbox
onready var player = $GenericRoom/ControllablePlayer
onready var exchange_popup = $ExchangePopup

func _ready():
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"Dropbox":
			room.player_walk_to(dropbox.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			exchange_popup.show()
			yield(exchange_popup, "done")
			GameState.interaction_is_frozen = false
