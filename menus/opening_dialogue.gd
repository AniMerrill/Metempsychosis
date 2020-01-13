extends Node2D

func _ready():
	
	var messages = [
"""Incoming alert. The following species has been annihilated: {Human|Martian}.

(Click or tap to continue.)""",

"""Activating Second Chance module for species: {humans|martians}.""",

"""Determining perpetrator responsible for species annihilations.
...
Determined: the {Martian|Human} species.""",

"""Determining {human|martian} weakness that caused annihilations.
...
Determined: {Failure to communicate|Failure to communicate}.""",

"""Releasing Second Chance representative {#1|#2}."""
		]
	MessageDisplay.display(convert_messages(messages))
	yield(MessageDisplay, "messages_finished")
	SceneTransition.change_scene('menus/AwaitTurn.tscn', 'Second Chance Release Chambers', 2.0)

func convert_messages(messages):
	var result = []
	for message in messages:
		result.append({"avatar": "ai_neutral", "message" : message})
	return result