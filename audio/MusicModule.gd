extends Node
#To do
#	- Edit audio files for smoother transitions
#

onready var mdm = $MixingDeskMusic

onready var FilterTween = $FilterTween

onready var LPF = AudioServer.get_bus_effect(AudioServer.get_bus_index("Music"), 0)

var current_song = "none"

var state = "explore"

var current_state = "explore"

# Called when the node enters the scene tree for the first time.
func _ready():
	#inititialise all the songs
#	mdm.init_song("Exploration")
#	#start with explore
#	mdm.play("Exploration")
#	current_song = "Exploration"
	
	#electronic theme
	mdm.init_song("LevelTheme")
	mdm.start_alone("LevelTheme", 1)
	
	#init tween
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

	
func state_changed(state:String):
	if state == "menu": 
		mdm.fade_out("LevelTheme", 0)
		mdm.fade_out("LevelTheme", 2)
		_interpolate_filter_cutoff(null, 20000, 1.5)
	elif state == "puzzle":
		_interpolate_filter_cutoff(null, 800, 1.5)
		current_state = "puzzle"
#		print("Music state: " + current_state)
		
	elif state == "guard":
		#fades in the guard layer
		mdm.fade_in("LevelTheme", 2)
		mdm.fade_out("LevelTheme", 0)
		_interpolate_filter_cutoff(null, 20000, 1.5)
		current_state = "guard"
		
		
	elif state == "explore":
		#fades in explore layer
		mdm.fade_in("LevelTheme", 0)
		mdm.fade_out("LevelTheme", 2)
		_interpolate_filter_cutoff(null, 20000, 1.5)
		current_state = "explore"
		
	elif state == "final":
		#few options
		#fade in guard layers for bass drum effect
		#just the base layer
		mdm.fade_in("LevelTheme", 2)
		_interpolate_filter_cutoff(null, 120, 6)

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
	
func _on_Button4_pressed():
	state_changed("menu")
	
func _on_Button5_pressed():
	state_changed("final")
