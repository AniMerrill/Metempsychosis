extends Node
""" 
DONT FORGET
SoundPuzzle0 and SoundPuzzle 8 still need their sound"""

"""KNOWN ISSUE: When calling stop_sfx() there is a click"""

#sound module
#call $SFX.play(sfxname:String) to play the sound. String name is the node name.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		play_sfx("Footsteps")
		
		

func play_sfx(sfxname:String):
	if has_node(sfxname):
		get_node(sfxname).play()
	else:
		print("Sound effect ", sfxname, " doesn't exist")
		
func stop_sfx(sfxname:String):
	if has_node(sfxname):
		get_node(sfxname).stop()
	else:
		print("Sound effect ", sfxname, " doesn't exist")
