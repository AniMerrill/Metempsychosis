extends CanvasLayer

onready var display = $Display
onready var label = $Display/ColorRect2/Label
onready var ok_button = $Display/ColorRect2/Ok
onready var cancel_button = $Display/ColorRect2/Cancel

signal responded(value)

func _ready():
	display.visible = false

func prompt(text : String, ok_text : String = "continue", cancel_text : String = "cancel"):
	label.text = text
	ok_button.text = ok_text
	cancel_button.text = cancel_text
	display.visible = true

func _on_Ok_pressed():
	emit_signal("responded", true)
	display.visible = false

func _on_Cancel_pressed():
	emit_signal("responded", false)
	display.visible = false
