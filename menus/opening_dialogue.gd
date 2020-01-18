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
	GameState.has_seen_introduction = true
	RoomUtil.load_first_room()

func convert_messages(messages):
	var result = []
	for message in messages:
		result.append({"avatar": "ai_neutral", "message" : message})
	return result