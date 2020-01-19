extends Node2D

enum FinaleState {
	INTRO,
	LIVE_FEED,
	WARNING,
	THREAT,
	M_A_D
	}

onready var room = $GenericRoom
onready var player = $GenericRoom/ControllablePlayer

onready var machine = $GenericRoom/Objects/TheMachine
onready var terminals = $EffectsOverlay/Terminals.get_children()

var finale_state : int = FinaleState.INTRO

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameState.get_state(GameState.STATE.FINALE_PLAYER_GIVEN_WARNING):
		finale_state = FinaleState.THREAT
	
	$"/root/MusicModule".state_changed("final")
	
	room.connect("object_clicked", self, "_on_object_clicked")
	
	# warning-ignore:return_value_discarded
	$EffectsOverlay/AnimationPlayer.connect(
			"animation_finished", 
			self, 
			"_on_animation_finished"
			)
	
	# warning-ignore:return_value_discarded
	Prompt.connect("responded", self, "_on_responded")
	
	if GameState.final_room_replay:
		player.swap_rig()
		player.position = machine.position + Vector2(0, 30)
		room.player_walk_to(machine.position)
		GameState.interaction_is_frozen = true
		var other_player = GameState.PLAYER.PLAYER_A \
			if GameState.current_player() == GameState.PLAYER.PLAYER_B \
			else GameState.PLAYER.PLAYER_B
		GameState.set_current_player(other_player)  # Bit risky but easy option.
		$EffectsOverlay/AnimationPlayer.play("Activate")

func _on_object_clicked(node):
	match node.name:
		"TheMachine":
			room.player_walk_to(machine.position)
			# NOTE: I never set it to unfreeze anywhere, and I'm not sure when
			# is most optimal since both options take control away from the player.
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			# TODO: Signal to play machine sfx in animation player?
			$EffectsOverlay/AnimationPlayer.play("Activate")

func _on_animation_finished(value : String):
	match value:
		"Activate":
			finale_cutscene()
		"Deactivate":
			var code = GameState.serialize()
			GameState.set_last_output_code(code)
			SceneTransition.change_scene('menus/AwaitTurn.tscn')

func _on_responded(response):
	if response:
		match finale_state:
			FinaleState.INTRO:
				finale_state = FinaleState.LIVE_FEED
			FinaleState.LIVE_FEED:
				finale_state = FinaleState.WARNING
			FinaleState.WARNING:
				finale_state = FinaleState.THREAT
			FinaleState.THREAT:
				finale_state = FinaleState.M_A_D
			FinaleState.M_A_D:
				pass
		
		finale_cutscene()
	else:
		RoomUtil.finale_dialog("refuse")
		yield(MessageDisplay, "messages_finished")
		$EffectsOverlay/AnimationPlayer.play("Deactivate")

func activate_terminal():
	for terminal in terminals:
		if terminal.visible == false:
			terminal.visible = true
			terminal.get_node("AnimationPlayer").play("data")
			return

func deactivate_terminals():
	for terminal in terminals:
		terminal.visible = false
		terminal.get_node("AnimationPlayer").stop()

func effects_anim_blink():
	for light in $EffectsOverlay/Lights.get_children():
		if light.name != "AnimationPlayer":
			if randi() % 2 == 0:
				light.visible = false
			else:
				light.visible = true

func finale_cutscene():
	var species := "Plutonians" if GameState._my_player == GameState.PLAYER.PLAYER_A else "Neptonians"
	var other_species := "Neptonians" if GameState._my_player == GameState.PLAYER.PLAYER_A \
			else "Plutonians"
	
	match finale_state:
		FinaleState.INTRO:
			RoomUtil.finale_dialog("intro")
			yield(MessageDisplay, "messages_finished")
			yield(get_tree().create_timer(0.5), "timeout")
			if GameState.final_room_replay:
				_on_responded(true)
			else:
				Prompt.prompt(
						"Revive species: " + species + ". Confirm?", 
						"Confirm", 
						"Refuse"
						)
		FinaleState.LIVE_FEED:
			RoomUtil.finale_dialog("live_feed")
			yield(MessageDisplay, "messages_finished")
			# TODO: Insert animation  trigger for live feed
			# Change state there when finished
			finale_state = FinaleState.WARNING
			finale_cutscene()
		FinaleState.WARNING:
			GameState.set_state(GameState.STATE.FINALE_PLAYER_GIVEN_WARNING, false)
			RoomUtil.finale_dialog("warning")
			yield(MessageDisplay, "messages_finished")
			yield(get_tree().create_timer(0.5), "timeout")
			if GameState.final_room_replay:
				_on_responded(true)
			else:
				Prompt.prompt(
						"Revive species: " + species + ". Confirm?", 
						"Confirm", 
						"Refuse"
						)
		FinaleState.THREAT:
			RoomUtil.finale_dialog("threat")
			yield(MessageDisplay, "messages_finished")
			yield(get_tree().create_timer(0.5), "timeout")
			if GameState.final_room_replay:
				_on_responded(true)
			else:
				Prompt.prompt(
						"Exterminate " + other_species + "?", 
						"Confirm", 
						"Refuse"
						)
		FinaleState.M_A_D:
			RoomUtil.finale_dialog("mutually_assured_destruction")
			yield(MessageDisplay, "messages_finished")
			GameState.opening_dialogue_is_outro = true
			if GameState.final_room_replay:
				var other_player = GameState.PLAYER.PLAYER_A \
					if GameState.current_player() == GameState.PLAYER.PLAYER_B \
					else GameState.PLAYER.PLAYER_B
				GameState.set_current_player(other_player)  ## Reset.
				GameState.final_room_replay = false
			SceneTransition.change_scene('menus/OpeningDialogue.tscn', 'Second Chance Inc. - Spaceship #X02 - C.003')