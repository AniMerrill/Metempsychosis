extends Node

func load_first_room():
	if not GameState.has_seen_introduction:
		SceneTransition.change_scene('menus/OpeningDialogue.tscn', 'Second Chance Inc. - Spaceship #X02 - C.003')
		return
	match GameState.current_player():
		GameState.PLAYER.PLAYER_A:
			if GameState.get_state(GameState.STATE.PLAYER_A_IN_XOR_POD):
				SceneTransition.change_scene('rooms/room_a_xor_puzzle.tscn')
			else:
				SceneTransition.change_scene('rooms/room_a_000.tscn')
		GameState.PLAYER.PLAYER_B:
			SceneTransition.change_scene('rooms/room_b_000.tscn')
		_:
			printerr("ERROR: No player active.")


# Ugly hack. But short on time.
func wake_up_dialog():
	var messages = [
"""Welcome, {Plutonian|Neptonian} representative, to one of the finest Second Chance Inc. space stations.""",
"""Unfortunately, your species has been wiped out due to aggressive relations with the {Neptonians|Plutonians}.""",
"""Like many other species, the {Plutonians|Neptonians} have set up an insurance with us.""",
"""In this space ship, you will find the Machine Room that enables you to revive your species.""",
"""However, revival is only permitted if the species can prove they are capable of survival.""",
"""In the {Plutonian|Neptonian} case, this means you need to demonstrate your capacity to {communicate|communicate}.""",
"""For this purpose, we have set up a special testing facility in this space ship.""",
"""When walking around, pay close attention to everything you see in your environment.""",
"""Then return to sleep in the cryrochamber.""",
"""While in the cryrochamber, you can communicate your discoveries to another member of your species.""",
"""Only effective communication will give you access to the Machine Room."""
		]
	MessageDisplay.display(convert_messages(messages))
	yield(MessageDisplay, "messages_finished")
	GameState.has_seen_in_room_intro = true
	yield(get_tree().create_timer(0.1), "timeout")  ## Avoid sharing last dialog click.
	GameState.interaction_is_frozen = false

func convert_messages(messages):
	var result = []
	for message in messages:
		result.append({"avatar": "ai_neutral", "message" : message})
	return result