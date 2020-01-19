extends Node2D

onready var input_code = $InputCode
onready var label = $ResponseMessage/Label
onready var response_message = $ResponseMessage
onready var output_code = $ResponseMessage/OutputCode

func _ready():
	response_message.visible = false

func _on_BackButton_pressed():
	SceneTransition.change_scene("menus/AwaitTurn.tscn")


func _on_Button_pressed():
	response_message.visible = true
	input_code.visible = false
	var ai_game_state = load('res://util/game_state.gd').new()
	ai_game_state.is_ai_state = true
	var error_code = ai_game_state.deserialize(input_code.text)
	if error_code != 0:
		report_error(error_code)
		return
	if GameState.current_player() == GameState.PLAYER.PLAYER_A:
		play_as_b(ai_game_state)
	else:
		play_as_a(ai_game_state)

func play_as_b(ai_game_state):
	if not ai_game_state.get_state(GameState.STATE.CODE_CREATED_BY_PLAYER_A):
		label.text = "Hey, that code is for you, not me!"
		return
	
	if not ai_game_state.get_state(GameState.STATE.POD_ROOMS_UNLOCKED):
		label.text = "I found a table in my pod room that says the number 11690. Does that help?"
	
	elif not (ai_game_state.get_state(GameState.STATE.KEY_A_1_POS_A) or
			ai_game_state.get_state(GameState.STATE.KEY_A_1_POS_B) or
			ai_game_state.get_state(GameState.STATE.KEY_A_1_POS_BOX) or
			ai_game_state.get_state(GameState.STATE.KEY_A_1_POS_DOOR)):
		label.text = "Thanks for unlocking the door! I found a blue key outside my room. I also found a blue drawer, so I left the key in there."
		ai_game_state.set_state(GameState.STATE.KEY_A_1_POS_BOX, true)
	
	elif not (
			ai_game_state.get_state(GameState.STATE.KEY_B_1_POS_BOX) or
			ai_game_state.get_state(GameState.STATE.KEY_B_1_POS_B) or
			ai_game_state.get_state(GameState.STATE.KEY_B_1_POS_DOOR)):
		if not ai_game_state.get_state(GameState.STATE.KEY_B_1_POS_A):
			label.text = "I found a room that has three beautiful paintings in it. The first one is of the jungle, the second of the ocean and the third one is of the air."
		else:
			label.text = "Hey if you have that red key, why not leave it in the drawer for me to pick up on the other side?"

	else:
		ai_game_state.set_state(GameState.STATE.KEY_B_1_POS_BOX, false)
		ai_game_state.set_state(GameState.STATE.KEY_B_1_POS_B, true)
		
		if not (ai_game_state.get_state(GameState.STATE.KEY_A_3_POS_A) or
				ai_game_state.get_state(GameState.STATE.KEY_A_3_POS_B) or
				ai_game_state.get_state(GameState.STATE.KEY_A_3_POS_BOX) or
				ai_game_state.get_state(GameState.STATE.KEY_A_3_POS_DOOR)):
			label.text = "I found another blue key lying around. I left it in the drawer"
			ai_game_state.set_state(GameState.STATE.KEY_A_3_POS_BOX, true)
		
		
		elif not (
				ai_game_state.get_state(GameState.STATE.KEY_B_2_POS_BOX) or
				ai_game_state.get_state(GameState.STATE.KEY_B_2_POS_B) or
				ai_game_state.get_state(GameState.STATE.KEY_B_2_POS_DOOR)):
			if not ai_game_state.get_state(GameState.STATE.KEY_B_2_POS_A):
				if ai_game_state.get_state(GameState.STATE.PLAYER_A_IN_XOR_POD):
					label.text = "I flipped a switch marked with an \"exclusive or\" logical gate symbol. When I switched it, I heared doors locking and unlocking."
					ai_game_state.set_state(GameState.STATE.XOR_ROOM_SWITCHED, true)
				else:
					label.text = "There is a room here with a switch. When I switch it, I hear doors locking and unlocking. There is a symbol of an \"exclusive or\" logical gate next to it."
			else:
				label.text = "Hey if you have that red key, why not leave it in the drawer for me to pick up on the other side? I undid the switch btw."
				ai_game_state.set_state(GameState.STATE.XOR_ROOM_SWITCHED, false)
	
		else:
			ai_game_state.set_state(GameState.STATE.XOR_ROOM_SWITCHED, false)
			ai_game_state.set_state(GameState.STATE.KEY_B_2_POS_BOX, false)
			ai_game_state.set_state(GameState.STATE.KEY_B_2_POS_B, true)
			
			if not (ai_game_state.get_state(GameState.STATE.KEY_A_2_POS_A) or
					ai_game_state.get_state(GameState.STATE.KEY_A_2_POS_B) or
					ai_game_state.get_state(GameState.STATE.KEY_A_2_POS_BOX) or
					ai_game_state.get_state(GameState.STATE.KEY_A_2_POS_DOOR)):
				label.text = "Thank you for telling me about the lights you saw. It allowed me to unlock a door and I left another key in the drawer."
				ai_game_state.set_state(GameState.STATE.KEY_A_2_POS_BOX, true)
			else:
				label.text = "There is nothing more to do here. Don't you have 3 blue keys now? And didn't you tell me there was a blue door somewhere...?"

	output_code.text = ai_game_state.serialize()
	return

func play_as_a(ai_game_state):
	label.text = "Player #1 AI is not yet implemented. Sad."

func report_error(error):
	if error == GameState.ERROR_CODE.INVALID_ENCODING:
		label.text = "My game reports that this is not a valid code."
	else:
		label.text = "My game does not accept that code."