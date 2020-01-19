extends Node

func load_first_room():
	if not GameState.has_seen_introduction():
		SceneTransition.change_scene('menus/OpeningDialogue.tscn', 'Second Chance, Inc. - Spaceship #X02 - C.003')
		return
	Timeout.set_timeout(5 * 60.0)
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

func display_message(messages, bottom := false):
	MessageDisplay.display(convert_messages(messages), bottom)
	yield(MessageDisplay, "messages_finished")
	yield(get_tree().create_timer(0.1), "timeout")  ## Avoid sharing last dialog click.
	GameState.interaction_is_frozen = false

# Ugly hack. But short on time.
func wake_up_dialog():
	var messages = [
"""Welcome, {Plutonian|Neptonian} representative, to one of the finest Second Chance, Inc. space stations.""",
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
	GameState.set_has_seen_in_room_intro(true)
	yield(get_tree().create_timer(0.1), "timeout")  ## Avoid sharing last dialog click.
	GameState.interaction_is_frozen = false


# Ugly hack. But short on time.
func game_over_dialog():
	var messages = [
"""Congratulations. Your fellow representative has reached the final room.""",
"""Enjoy this video feed of them reviving your species.""",
		]
	MessageDisplay.display(convert_messages(messages))
	yield(MessageDisplay, "messages_finished")
	GameState.final_room_replay = true
	SceneTransition.change_scene('rooms/final_room.tscn')

func finale_dialog(part : String):
	var messages := []
	
	match part:
		# Plays when first player initially uses machine
		"intro":
			messages = [
"""Congratulations, you have shown your species is able to communicate effectively""",
"""Probability of survival based on demonstration deemed sufficient."""
			]
			
		# Plays after first confirmation
		"live_feed":
			messages = [
"""Bringing up live-feed with the other representative of your species to share in this victorious moment."""
			]
		"warning":
			messages = [
"""[WARNING]: Representative {#2|#1} is not of the same species. Determined to be {Neptonian|Plutonian}.""",
"""[WARNING]: Mismatch in representatives is not according to protocol. Implementation error detected.""",
"""{[WARNING OVERRIDE]|[WARNING OVERRIDE]}""",
"""Representative {#1|#2} has still successfully shown ability to communicate regardless. Proceed with simulation.""",
"""Reading emotional state of {Neptonian|Plutonian}. . .""",
"""Status: {Thankful for successful cooperation and the potential of peace between the species.|Thankful for successful cooperation and the potential of peace between the species.}""",
"""Continuing revival."""
			]
			
		# Plays when player confirms revival anyway
		"threat":
			messages = [
"""Determining species survival chances. . .""",
"""{[THREAT DETECTED!!!]|[THREAT DETECTED!!!]}""",
"""[THREAT]: {Neptonians|Plutonians} previously annihilated all {Plutonians|Neptonians}!""",
"""The extermination of your species is inevitable while in proximity of {Neptonians|Plutonians}.""",
"""[RESOLUTION]: Exterminate all local {Neptonians|Plutonians}.""",
#"""Confirm?"""
			]
			
		# Plays if first player confirms the annihilation request
		"mutually_assured_destruction":
			messages = [
"""Affirmative, proceeding to exterminate all {Nepto|Pluto}-""",
"""[CRITICAL ERROR!!!]""",
"""[PROCESSING]""",
"""[PROCESSING.]""",
"""[PROCESSING. .]""",
"""[PROCESSING. . .]""",
"""[PRo{CES|CES}iaaaaaaaaaa aa {a|a} aaa a ]a a """,
"""[REINITIALIZING STATE]""",
"""[EVALUATING]""",
"""[WARNING]: Presence of a {Plutonian|Neptonian} poses risk to representative {#2|#1}. Exterminating all local {Plutonians|Neptonians} to ensure safety of specimen."""
			]
			
		# If the first player refuses a prompt at any time, this sequence plays
		# and forces player asleep to hand off the choice to the other player
		"refuse":
			messages = [
"""[UNEXPECTED INPUT]""",
"""[PROCESSING]""",
"""Understandable, you probably want to meditate on such a monumental decision.""",
"""Please take as long as you need to think in your cryrostasis chamber."""
			]
			
			
	
	if messages != []:
		MessageDisplay.display(convert_messages(messages), true)
		yield(MessageDisplay, "messages_finished")
		yield(get_tree().create_timer(0.1), "timeout")  ## Avoid sharing last dialog click.

func convert_messages(messages):
	var result = []
	for message in messages:
		result.append({"avatar": "ai_neutral", "message" : message})
	return result