extends Node2D

"""
The detector is a child node that holds the graphic
itself, it detects if the player clicks on it and 
brings up the extra info
The mouse texture holds what the mouse should look like
when it's over that object, if it's empty, the mouse cursor
won't change
"""

export (Texture) var _mouse_texture: Texture

export (Texture) var _graphic_object: Texture
export (Texture) var _detailed_pop_up: Texture

onready var _detector = get_node("detector")
onready var _pop_up_overlay = get_node("detector/TextureRect")

func _ready():
	_detector.texture = _graphic_object
	_pop_up_overlay.texture = _detailed_pop_up
	_pop_up_overlay.self_modulate = Color(1,1,1,0)
	
	_detector.rect_size = _graphic_object.get_size()
	_pop_up_overlay.rect_size = _detailed_pop_up.get_size()

func _on_TextureRect_mouse_exited():
	_pop_up_overlay.self_modulate = Color(1, 1, 1, 0)

func _on_detector_gui_input(event):
	Input.set_custom_mouse_cursor(_mouse_texture)
	if event and Input.is_action_just_pressed("click"):
		_pop_up_overlay.self_modulate = Color(1, 1, 1, 1)
