extends Node2D

signal solved()

onready var numpad = $PopupBase/TerminalBase/NumpadScreen

func _ready():
	numpad.solution = "451"
	numpad.connect("solved", self, "_on_puzzle_solved")
	numpad.connect("number_pressed", self, "_on_number_pressed")

func _on_puzzle_solved():
	emit_signal("solved")

func _on_number_pressed(value):
	SoundModule.play_sfx("SoundPuzzle" + str(value))
