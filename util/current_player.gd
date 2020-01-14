extends Node2D

onready var label = $Label

func _ready():
	refresh()

func refresh():
	match GameState.current_player():
		GameState.PLAYER.INVALID_PLAYER:
			label.text = '----'
		GameState.PLAYER.PLAYER_A:
			label.text = 'Player A'
		GameState.PLAYER.PLAYER_B:
			label.text = 'Player B'
