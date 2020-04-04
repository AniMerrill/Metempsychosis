extends Node2D

signal solved()

onready var numpad = $Popup/TerminalBase/TerminalMenu/Numpad

func _ready():
	numpad.solution = "11690"
	numpad.connect("solved", self, "_on_solved")

func _on_solved():
	emit_signal("solved")

