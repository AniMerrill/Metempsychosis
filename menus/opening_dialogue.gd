extends Node2D

func _ready():
	var messages = [
"""Incoming alert. The following species has been annihilated: {Plutonian|Neptonian}.""",
"""Activating Second Chance module for species: {Plutonians|Neptonians}.""",
"""Determining perpetrator responsible for species annihilations.""",
"""Determined: the {Neptonian|Plutonian} species.""",
"""Determining {Plutonian|Neptonian} weakness that caused annihilations.""",
"""Determined: {Failure to communicate|Failure to communicate}.""",
"""Releasing Second Chance representative {#1|#2}."""
		]
	MessageDisplay.display(convert_messages(messages))
	yield(MessageDisplay, "messages_finished")
	if GameState.opening_dialogue_is_outro:
		GameState.opening_dialogue_is_outro = false
		if GameState.get_state(GameState.STATE.GAME_OVER):
			## Game finished already. No need to share code to other player.
			SceneTransition.change_scene('menus/MainMenu.tscn')
			return
		GameState.set_state(GameState.STATE.GAME_OVER, true)
		var code = GameState.serialize()
		GameState.set_last_output_code(code)
		SceneTransition.change_scene('menus/AwaitTurn.tscn')
	else:
		GameState.set_has_seen_introduction(true)
		RoomUtil.load_first_room()

func convert_messages(messages):
	var result = []
	for message in messages:
		result.append({"avatar": "ai_neutral", "message" : message})
	return result