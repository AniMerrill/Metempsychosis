extends Node2D

signal solved()

onready var puzzle = $PopupBase/TerminalBase/puzzle_base

func _ready():
	puzzle.connect("solved", self, "_on_puzzle_solved")

func _on_puzzle_solved():
	emit_signal("solved")
