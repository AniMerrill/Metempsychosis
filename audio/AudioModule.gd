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

func _on_Button_pressed():
	mdm.queue_beat_transition("GuardOnWatch")
	print("queue guard")

func _on_Button2_pressed():
	pass # Replace with function body.


func _on_Button3_pressed():
	pass # Replace with function body.
