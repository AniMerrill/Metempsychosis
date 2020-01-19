extends Node2D

onready var output_code = $OutputArea/OutputCode
onready var input_code = $InputArea/InputCode
onready var error_layer = $ErrorTextBG
onready var error_label = $ErrorTextBG/Label
onready var output_area = $OutputArea
onready var first_time_area = $FirstTimeArea

func _ready():
	if GameState.is_local_coop():
		SceneTransition.change_scene_direct("menus/CoopSwitchPlayer.tscn")
		return
	error_layer.visible = false
	output_code.text = GameState.last_output_code()
	if output_code.text == "(no code)":
		first_time_area.visible = true
		output_area.visible = false

func _on_InputCode_text_entered(code : String):
	var result = GameState.deserialize(code)

	if result == GameState.ERROR_CODE.OK:
		RoomUtil.load_first_room()
		return

	match result:
		GameState.ERROR_CODE.INVALID_ENCODING:
			error_label.text = "Error: Invalid encoding."
		GameState.ERROR_CODE.OTHER_PLAYER_CODE:
			error_label.text = "Error: Code is for other player."
	error_layer.visible = true

func _on_Continue_pressed():
	_on_InputCode_text_entered(input_code.text)

func _on_ChangePlayer_pressed():
	if GameState.current_player() == GameState.PLAYER.PLAYER_A:
		GameState.set_current_player(GameState.PLAYER.PLAYER_B)
	else:
		GameState.set_current_player(GameState.PLAYER.PLAYER_A)
	SceneTransition.change_scene_direct('menus/AwaitTurn.tscn')


func _on_StateEdit_pressed():
	SceneTransition.change_scene_direct('menus/GameplayDemo.tscn')

func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/MainMenu.tscn")

func _on_Customise_pressed():
	SceneTransition.change_scene("menus/CustomizePlayer.tscn")
