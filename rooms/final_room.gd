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

func _ready():
	Timeout.stop_timer()  # Don't timeout in the final room.
	if GameState.get_state(GameState.STATE.FINALE_PLAYER_GIVEN_WARNING):
		finale_state = FinaleState.THREAT
	
	$"/root/MusicModule".state_changed("final")
	
	room.connect("object_clicked", self, "_on_object_clicked")
	
	# warning-ignore:return_value_discarded
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
			Timeout.stop_timer()
			room.player_walk_to(machine.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			$EffectsOverlay/AnimationPlayer.play("Activate")
			
			SoundModule.play_sfx("FinalRoom") 

func _on_animation_finished(value : String):
	match value:
		"Activate":
			finale_cutscene()
		"Deactivate":
			var code = GameState.serialize()
			GameState.set_last_output_code(code)
			SceneTransition.change_scene('menus/AwaitTurn.tscn')
			
			#stops terminal sound
			SoundModule.stop_sfx("FinalRoom")

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
			SoundModule.play_sfx("TerminalScreenOn")
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
				

#light blink sfx
func play_light_blink_sfx():
	SoundModule.play_sfx("TerminalLights")

func warning_glitch():
	$GenericRoom/Objects/TheMachine/Screen/Display.frame = randi() % 6 + 57

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
			
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play_backwards("Activate")
			yield($GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer, "animation_finished")
			
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play("Activate")
			$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Loading")
			$GenericRoom/Objects/TheMachine/Screen/ColorRect.visible = true
			$GenericRoom/Objects/TheMachine/Screen/ColorRect/AnimationPlayer.play("Loading")
			yield($GenericRoom/Objects/TheMachine/Screen/ColorRect/AnimationPlayer, "animation_finished")
			
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play_backwards("Activate")
			yield($GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer, "animation_finished")
			$GenericRoom/Objects/TheMachine/Screen/ColorRect.visible = false
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play("Activate")
			
			set_live_feed(true)
			
			finale_state = FinaleState.WARNING
			finale_cutscene()
		FinaleState.WARNING:
			GameState.set_state(GameState.STATE.FINALE_PLAYER_GIVEN_WARNING, true)
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
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play_backwards("Activate")
			yield($GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer, "animation_finished")
			set_live_feed(false)
			
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play("Activate")
			$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Warning")
			
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
			$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Warning_Glitch")
			
			RoomUtil.finale_dialog("mutually_assured_destruction")
			yield(MessageDisplay, "messages_finished")
			
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play_backwards("Activate")
			yield($GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer, "animation_finished")
			
			$GenericRoom/Objects/TheMachine/Screen/Block/AnimationPlayer.play("Activate")
			$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Death")
			SoundModule.play_sfx("TerminalScreenOn")
			
			yield(get_tree().create_timer(2.0), "timeout")
			
			GameState.opening_dialogue_is_outro = true
			if GameState.final_room_replay:
				var other_player = GameState.PLAYER.PLAYER_A \
					if GameState.current_player() == GameState.PLAYER.PLAYER_B \
					else GameState.PLAYER.PLAYER_B
				GameState.set_current_player(other_player)  ## Reset.
				GameState.final_room_replay = false
				
			SceneTransition.change_scene('menus/OpeningDialogue.tscn', 'Second Chance Inc. - Spaceship #X02 - C.003')
			MusicModule.state_changed("menu")
			SoundModule.stop_sfx("FinalRoom")

func set_info_screen():
	if GameState.current_player() == GameState.PLAYER.PLAYER_A:
		$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Plutonian")
	else:
		$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Neptonian")

func set_live_feed(turn_on : bool):
	if turn_on:
		$GenericRoom/Objects/TheMachine/Screen/Mouth.visible = true
		$GenericRoom/Objects/TheMachine/Screen/Hair.visible = true
		$GenericRoom/Objects/TheMachine/Screen/Face.visible = true
		$GenericRoom/Objects/TheMachine/Screen/Hat.visible = true
		$GenericRoom/Objects/TheMachine/Screen/Tool.visible = true
		
		if GameState.current_player() == GameState.PLAYER.PLAYER_A:
			$GenericRoom/Objects/TheMachine/Screen/Hair.frame = 0
			
			match GameState.custom_mouth(GameState.PLAYER.PLAYER_B):
				GameState.PlayerRig.MOUTH.FROWN:
					$GenericRoom/Objects/TheMachine/Screen/Mouth.frame = 43
				GameState.PlayerRig.MOUTH.SMILE:
					$GenericRoom/Objects/TheMachine/Screen/Mouth.frame = 44
				GameState.PlayerRig.MOUTH.OPEN:
					$GenericRoom/Objects/TheMachine/Screen/Mouth.frame = 45
			
			match GameState.custom_face(GameState.PLAYER.PLAYER_B):
				GameState.PlayerRig.FACE.NONE:
					$GenericRoom/Objects/TheMachine/Screen/Face.frame = 0
				GameState.PlayerRig.FACE.BEARD:
					$GenericRoom/Objects/TheMachine/Screen/Face.frame = 37
				GameState.PlayerRig.FACE.MOUSTACHE:
					$GenericRoom/Objects/TheMachine/Screen/Face.frame = 38
			
			match GameState.custom_hat(GameState.PLAYER.PLAYER_B):
				GameState.PlayerRig.HAT.NONE:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 0
				GameState.PlayerRig.HAT.BOWLER:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 34
				GameState.PlayerRig.HAT.FEZ:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 35
				GameState.PlayerRig.HAT.HELMET:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 36
			
			match GameState.custom_tool(GameState.PLAYER.PLAYER_B):
				GameState.PlayerRig.TOOL.NONE:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 0
				GameState.PlayerRig.TOOL.HAMMER:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 48
				GameState.PlayerRig.TOOL.SCREWDRIVER:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 49
				GameState.PlayerRig.TOOL.PISTOL:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 50
				GameState.PlayerRig.TOOL.PAINTBRUSH:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 51
			
			$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Neptonian_Wave")
			
		else:
			match GameState.custom_mouth(GameState.PLAYER.PLAYER_A):
				GameState.PlayerRig.MOUTH.FROWN:
					$GenericRoom/Objects/TheMachine/Screen/Mouth.frame = 40
				GameState.PlayerRig.MOUTH.SMILE:
					$GenericRoom/Objects/TheMachine/Screen/Mouth.frame = 41
				GameState.PlayerRig.MOUTH.OPEN:
					$GenericRoom/Objects/TheMachine/Screen/Mouth.frame = 42
			
			match GameState.custom_hair(GameState.PLAYER.PLAYER_A):
				GameState.PlayerRig.HAIR.DOWN:
					$GenericRoom/Objects/TheMachine/Screen/Hair.frame = 32
				GameState.PlayerRig.HAIR.PONYTAIL:
					$GenericRoom/Objects/TheMachine/Screen/Hair.frame = 33
			
			match GameState.custom_face(GameState.PLAYER.PLAYER_A):
				GameState.PlayerRig.FACE.NONE:
					$GenericRoom/Objects/TheMachine/Screen/Face.frame = 0
				GameState.PlayerRig.FACE.BEARD:
					$GenericRoom/Objects/TheMachine/Screen/Face.frame = 37
				GameState.PlayerRig.FACE.MOUSTACHE:
					$GenericRoom/Objects/TheMachine/Screen/Face.frame = 38
			
			match GameState.custom_hat(GameState.PLAYER.PLAYER_A):
				GameState.PlayerRig.HAT.NONE:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 0
				GameState.PlayerRig.HAT.BOWLER:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 34
				GameState.PlayerRig.HAT.FEZ:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 35
				GameState.PlayerRig.HAT.HELMET:
					$GenericRoom/Objects/TheMachine/Screen/Hat.frame = 36
			
			match GameState.custom_tool(GameState.PLAYER.PLAYER_A):
				GameState.PlayerRig.TOOL.NONE:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 0
				GameState.PlayerRig.TOOL.HAMMER:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 48
				GameState.PlayerRig.TOOL.SCREWDRIVER:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 49
				GameState.PlayerRig.TOOL.PISTOL:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 50
				GameState.PlayerRig.TOOL.PAINTBRUSH:
					$GenericRoom/Objects/TheMachine/Screen/Tool.frame = 51
			
			$GenericRoom/Objects/TheMachine/Screen/Display/AnimationPlayer.play("Plutonian_Wave")
			
	else:
		$GenericRoom/Objects/TheMachine/Screen/Mouth.visible = false
		$GenericRoom/Objects/TheMachine/Screen/Hair.visible = false
		$GenericRoom/Objects/TheMachine/Screen/Face.visible = false
		$GenericRoom/Objects/TheMachine/Screen/Hat.visible = false
		$GenericRoom/Objects/TheMachine/Screen/Tool.visible = false