extends Node2D

onready var output_code = $Frame/OutputCodeBG/OutputCode
onready var input_code = $Frame/InputCode

func _ready():
	output_code.text = GameState.last_output_code()


func _on_InputCode_text_entered(new_text):
	print(new_text)


func _on_Continue_pressed():
	_on_InputCode_text_entered(input_code.text)
