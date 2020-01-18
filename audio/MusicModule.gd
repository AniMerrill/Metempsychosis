extends Node
#To do
#	- Edit audio files for smoother transitions
#

onready var mdm = $MixingDeskMusic

onready var FilterTween = $FilterTween

onready var LPF = AudioServer.get_bus_effect(AudioServer.get_bus_index("Music"), 0)

var current_song = "none"

var state = "init"

# Called when the node enters the scene tree for the first time.
func _ready():
	#inititialise all the songs
#	mdm.init_song("Exploration")
#	#start with explore
#	mdm.play("Exploration")
#	current_song = "Exploration"
	
	#electronic theme
	mdm.init_song("LevelTheme")
	mdm.start_alone("LevelTheme", 8)
	mdm.toggle_mute("LevelTheme", 7)
	
	#init tween
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#buttons for debug

#guard appears
func _on_Button_pressed():
#	mdm.queue_bar_transition("GuardOnWatch")
#	current_song = "GuardOnWatch"
#	print("queue guard")
#	mdm.toggle_fade("LevelTheme", 9)
	state_changed("puzzle")

#Game over 
#use queue_sequence() to loop smth once, then proceed to next song
func _on_Button2_pressed():
#	mdm.queue_sequence(["GameOver", "Exploration"], "beat", "loop")
#	current_song = "Exploration"
#	print("queue game over")
#	_fadein_above_layer("LevelTheme", 6, 0)
#
#	_fadeout_below_layer("LevelTheme", 9, 11)
	state_changed("guard")

#Back to main loop
func _on_Button3_pressed():
#	mdm.queue_bar_transition("Exploration")
#	current_song = "Exploration"
#	print("queue exploration")
#	_fadein_below_layer("LevelTheme", 9, 11) 
#
#	_fadeout_above_layer("LevelTheme", 6, 0)
	state_changed("explore")
	
func state_changed(state:String):
	if state == "puzzle":
		_turn_on_filter()
	elif state == "guard":
		_fade_guard_layers()
	elif state == "explore":
		_fade_explore_layers()

func _turn_on_filter():
	_fadein_above_layer("LevelTheme", 6, 0)
	_interpolate_filter_cutoff(null, 300, 1.5)
	current_song = "puzzle"
	
func _fade_guard_layers():
	_fadein_below_layer("LevelTheme", 9, 11) 
	
	_fadeout_above_layer("LevelTheme", 6, 0)
	
	current_song = "guard"
	
func _fade_explore_layers():
	_fadeout_above_layer("LevelTheme", 6, 0)
	_fadeout_below_layer("LevelTheme",9, 11)
	
	_interpolate_filter_cutoff(null, 20000, 1.5)
	
	current_song = "explore"

#custom functions
#fade functions. Requires song name (node name), min, and max. Range is inclusive
#fade in above track up until last_track
func _fadein_above_layer(song:String, track:int, last_track:int):
	for i in range(last_track, track + 1):
		mdm.fade_in(song, i)
		
#fade out above track up until last_track
func _fadeout_above_layer(song:String, track:int, last_track:int):
	for i in range(last_track, track + 1):
		mdm.fade_out(song, i)
		
#fade in below track up until last_track
func _fadein_below_layer(song:String, track:int, last_track:int):
	for i in range(track, last_track + 1):
		mdm.fade_in(song, i)
		
#fade out below track up until last_track
func _fadeout_below_layer(song:String, track:int, last_track:int):
	for i in range(track, last_track + 1):
		mdm.fade_out(song, i)

func _interpolate_filter_cutoff(start_value, target_value:float, transition_time:float):
	FilterTween.interpolate_property(LPF, "cutoff_hz", start_value, target_value, transition_time, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	FilterTween.start()