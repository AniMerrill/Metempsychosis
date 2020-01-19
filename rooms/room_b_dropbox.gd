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
			if (
					GameState.get_state(GameState.STATE.KEY_A_1_POS_B) or
					GameState.get_state(GameState.STATE.KEY_A_2_POS_B) or
					GameState.get_state(GameState.STATE.KEY_A_3_POS_B) or
					GameState.get_state(GameState.STATE.KEY_B_1_POS_B) or
					GameState.get_state(GameState.STATE.KEY_B_2_POS_B) or
					GameState.get_state(GameState.STATE.KEY_B_3_POS_B)
				):
				FlashText.flash("You take the keys that are on the table with you.")
