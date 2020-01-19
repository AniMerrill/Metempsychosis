extends Control

# NOTE: Screens can pretty comfortably fit inside a 240x160 area, although some
# minor bleed over the edges probably just helps the effect.

export var solution : String = ""
export var code_length : int = 6
export var solved_message : String = "Correct."

var code : String = ""
var blink : bool = false

var parent_menu = null

signal solved()
signal number_pressed(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:unused_variable
	var ignore = $Button0.connect("pressed", self, "number_pressed", [0])
	ignore = $Button1.connect("pressed", self, "number_pressed", [1])
	ignore = $Button2.connect("pressed", self, "number_pressed", [2])
	ignore = $Button3.connect("pressed", self, "number_pressed", [3])
	ignore = $Button4.connect("pressed", self, "number_pressed", [4])
	ignore = $Button5.connect("pressed", self, "number_pressed", [5])
	ignore = $Button6.connect("pressed", self, "number_pressed", [6])
	ignore = $Button7.connect("pressed", self, "number_pressed", [7])
	ignore = $Button8.connect("pressed", self, "number_pressed", [8])
	ignore = $Button9.connect("pressed", self, "number_pressed", [9])
	
	ignore = $OK.connect("pressed", self, "ok_pressed")
	ignore = $X.connect("pressed", self, "x_pressed")
	
	ignore = $Timer.connect("timeout", self, "set_blink")
	
	$Code.bbcode_text = "[center]"
	
	# warning-ignore:unused_variable
	for i in range(code_length):
		$Code.bbcode_text += "_"
	
	$Code.bbcode_text += "[/center]"

func number_pressed(value : int) -> void:
	emit_signal("number_pressed", value)
	if code.length() < code_length:
		code = str(value) + code
		blink = false
		$Timer.start()
		set_code_text()
	else:
		# TODO: Add error noise?
		print("NumpadScreen.gd : You have reached the maximum code limit!")
		pass

func ok_pressed() -> void:
	if solution == code:
		$Message.text = solved_message
		emit_signal("solved")
	else:
		# TODO: Insert error noise
		$Message.text = "Incorrect Passcode! Please try again:"
		code = ""
		set_code_text()

func x_pressed() -> void:
	if parent_menu != null:
		visible = false
		parent_menu.set_visibility(true)
	else:
		code = ""
		set_code_text()

func set_blink() -> void:
	blink = !blink
	
	set_code_text()

func set_code_text() -> void:
	var code_text : String = ""
	var extra_characters : int = code_length - code.length()
	
	if extra_characters > 1:
		for i in range(extra_characters):
			if i == extra_characters - 1 && blink:
				code_text += " "
			else:
				code_text += "_"
	elif extra_characters == 1 && blink:
		code_text += " "
	elif extra_characters == 1:
		code_text += "_"
	
	code_text += code
	
	$Code.bbcode_text = "[center]" + code_text + "[/center]"