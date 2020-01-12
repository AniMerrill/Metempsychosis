extends Node

onready var mdm = $MixingDeskMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	#inititialise all the songs
	mdm.init_song("Exploration")
	#start with explore
	mdm.play("Exploration")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		mdm.queue_bar_transition("GuardOnWatch")
		print("queue guard")


#guard appears
func _on_Button_pressed():
	mdm.queue_bar_transition("GuardOnWatch")
	print("queue guard")

#Game over 
func _on_Button2_pressed():
	mdm.queue_bar_transition("GameOver")
	print("queue game over")


#Back to main loop
func _on_Button3_pressed():
	mdm.queue_bar_transition("Exploration")
	print("queue exploration")

