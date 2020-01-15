extends Control

# NOTE/TODO: I am really running on empty but I wanted to make something that
# could show off some basic functionality here, ideally these terminal programs
# probably need to inherit from some base class with parent_menu and
# x_pressed() automatically inherited. Hopefully this gives you some inspiration
# going forward.

var parent_menu = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$Button.connect("pressed", self, "x_pressed")

func x_pressed() -> void:
	if parent_menu != null:
		visible = false
		parent_menu.set_visibility(true)
