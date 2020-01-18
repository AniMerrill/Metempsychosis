extends Node2D

onready var room = $GenericRoom
onready var popup = $Popup
onready var pod = $GenericRoom/Objects/Pod
onready var player = $GenericRoom/ControllablePlayer

onready var machine = $GenericRoom/Objects/TheMachine
onready var terminals = $EffectsOverlay/Terminals.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	room.connect("object_clicked", self, "_on_object_clicked")
	$EffectsOverlay/AnimationPlayer.connect(
			"animation_finished", 
			self, 
			"_on_animation_finished"
			)

func _input(event):
	if event.is_action_released("ui_accept"):
		deactivate_machine()

func _on_object_clicked(node):
	match node.name:
		"TheMachine":
			room.player_walk_to(machine.position)
			GameState.interaction_is_frozen = true
			yield(player, "position_reached")
			# TODO: Signal to play machine start noise?
			$EffectsOverlay/AnimationPlayer.play("Activate")

func _on_animation_finished(value : String):
	match value:
		"Activated":
			print("The machine is activated. Your fate will be sealed here today.")
			
			# TODO: Presumably here is where some dialogue prompt would appear. I have
			# an idea for, instead of a popup, this time you just see somebody talking
			# to you on the screen (probably a very basic sprite) with a normal
			# dialogue box.
			
			# I'm not sure how we want to handle the ending yet, whether the player
			# has any choice where they could walk away and give control back to the
			# other player (I do actually have a "good ending" idea we could expand upon
			# in the post jam update). Just to be safe I added a deactivate_machine
			# function that will restore the room to the state you enter and unfreeze the
			# game just like any other object.
		"Deactivated":
			pass

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

func deactivate_machine():
	# TODO: Signal to play machine stop noise?
	print("The machine is deactivated.")