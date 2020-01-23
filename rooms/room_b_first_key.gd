extends Node2D

onready var room = $GenericRoom
onready var key := $GenericRoom/Objects/Key
onready var player = $GenericRoom/ControllablePlayer
onready var terminal = $GenericRoom/Objects/Terminal
onready var popup = $Popup/TerminalPopupBase

func _ready():
	popup.visible = false
	
	if (GameState.get_state(GameState.STATE.KEY_A_1_POS_A) or
		GameState.get_state(GameState.STATE.KEY_A_1_POS_B) or
		GameState.get_state(GameState.STATE.KEY_A_1_POS_BOX) or
		GameState.get_state(GameState.STATE.KEY_A_1_POS_DOOR)):
		key.visible = false
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"Key":
			room.player_walk_to(key.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			key.visible = false
			GameState.set_state(GameState.STATE.KEY_A_1_POS_B, true)
			GameState.interaction_is_frozen = false
			FlashText.flash("You pick up a blue key.")
			SoundModule.play_sfx("ItemPickedUp")
		"Terminal":
			room.player_walk_to(terminal.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			popup.visible = true
			GameState.interaction_is_frozen = false
