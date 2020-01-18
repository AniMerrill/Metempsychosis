extends Node2D

onready var room = $GenericRoom
onready var player = $GenericRoom/ControllablePlayer
onready var popup = $Popup/Popup
onready var sky = $GenericRoom/Objects/Sky
onready var sea = $GenericRoom/Objects/Sea
onready var jungle = $GenericRoom/Objects/Jungle
onready var sky_popup = $Popup/Popup/Content/SkyPopup
onready var sea_popup = $Popup/Popup/Content/SeaPopup
onready var jungle_popup = $Popup/Popup/Content/JunglePopup

func _ready():
	MusicModule.state_changed("puzzle")
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"Jungle":
			room.player_walk_to(jungle.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			sky_popup.visible = false
			sea_popup.visible = false
			jungle_popup.visible = true
			popup.visible = true
			GameState.interaction_is_frozen = false

		"Sky":
			room.player_walk_to(sky.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			sky_popup.visible = true
			sea_popup.visible = false
			jungle_popup.visible = false
			popup.visible = true
			GameState.interaction_is_frozen = false

		"Sea":
			room.player_walk_to(sea.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			sky_popup.visible = false
			sea_popup.visible = true
			jungle_popup.visible = false
			popup.visible = true
			GameState.interaction_is_frozen = false
