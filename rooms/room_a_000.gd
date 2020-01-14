extends Node2D

onready var room = $GenericRoom
onready var popup = $Popup
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer
onready var codepad = $GenericRoom/Objects/CodePad
onready var codepad_popup = $CodePadPopup
onready var code = $CodePadPopup/Code

func _ready():
	popup.visible = false
	codepad_popup.visible = false
	if GameState.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		room.east_door = room.DOOR_STATUS.CLOSED_DOOR
	room.connect("object_clicked", self, "_on_object_clicked")

func _on_object_clicked(node):
	match node.name:
		"CodePad":
			room.player_walk_to(codepad.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			codepad_popup.visible = true
		"Pod":
			popup.text = "Going to sleep. Surrending control."
			popup.visible = true
			room.player_walk_to(pod.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			var code = GameState.serialize()
			GameState.set_last_output_code(code)
			SceneTransition.change_scene('menus/AwaitTurn.tscn')

func _on_CancelCodeButton_pressed():
	codepad_popup.visible = false
	GameState.interaction_is_frozen = false

func _on_EnterCodeButton_pressed():
	_on_Code_text_entered(code.text)

func _on_Code_text_entered(code):
	if code == "3456":
		popup.text = "Code correct! Unlocked doors."
		codepad_popup.visible = false
		GameState.interaction_is_frozen = false
		GameState.set_state(GameState.STATE.POD_ROOMS_UNLOCKED, true)
		room.east_door = room.DOOR_STATUS.CLOSED_DOOR
		popup.visible = true
		yield(get_tree().create_timer(2.0), "timeout")
		popup.visible = false
	else:
		popup.text = "Code incorrect"
		popup.visible = true
		yield(get_tree().create_timer(0.8), "timeout")
		popup.visible = false
