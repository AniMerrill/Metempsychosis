extends Node2D

onready var content = $TerminalBase/Screen/ScreenContents
onready var base = $TerminalBase

func get_inner_content_node():
	return content

func get_own_top_level_nodes():
	return [base]
