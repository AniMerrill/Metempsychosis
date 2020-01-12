extends Node

onready var mdm = $MixingDeskMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	#inititialise all the songs
	mdm.init_song("Exploration")
	#start with explore
	mdm.play("Exploration")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_down():
	pass


func _on_Button2_button_down():
	pass # Replace with function body.


func _on_Button3_button_down():
	pass # Replace with function body.
