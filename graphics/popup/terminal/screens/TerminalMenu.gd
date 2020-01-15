extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:unused_variable
	var ignore = $Down.connect("pressed", self, "down_pressed")
	ignore = $Up.connect("pressed", self, "up_pressed")
	
	ignore = $Options/Button0.connect("pressed", self, "option_pressed", [0])
	ignore = $Options/Button1.connect("pressed", self, "option_pressed", [1])
	ignore = $Options/Button2.connect("pressed", self, "option_pressed", [2])
	ignore = $Options/Button3.connect("pressed", self, "option_pressed", [3])
	ignore = $Options/Button4.connect("pressed", self, "option_pressed", [4])

func down_pressed() -> void:
	print("down")

func up_pressed() -> void:
	print("up")

func option_pressed(value : int) -> void:
	print("value")
