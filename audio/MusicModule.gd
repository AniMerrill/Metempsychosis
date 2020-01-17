extends Node
#To do
#	- Edit audio files for smoother transitions
#

onready var mdm = $MixingDeskMusic

onready var sfx = $SFX

var current_song = "none"

# Called when the node enters the scene tree for the first time.
func _ready():
	#inititialise all the songs
#	mdm.init_song("Exploration")
#	#start with explore
#	mdm.play("Exploration")
#	current_song = "Exploration"
	
	#electronic theme
	mdm.init_song("LevelTheme")
	mdm.play("LevelTheme")
	# NOTE: I had to comment this out to run the game, AniMerrill
	#mdm.mute_below_layer("LevelTheme", 8)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#buttons for debug

#guard appears
func _on_Button_pressed():
	mdm.queue_bar_transition("GuardOnWatch")
	current_song = "GuardOnWatch"
	print("queue guard")

#Game over 
#use queue_sequence() to loop smth once, then proceed to next song
func _on_Button2_pressed():
	mdm.queue_sequence(["GameOver", "Exploration"], "beat", "loop")
	current_song = "Exploration"
	print("queue game over")


#Back to main loop
func _on_Button3_pressed():
	mdm.queue_bar_transition("Exploration")
	current_song = "Exploration"
	print("queue exploration")
		
