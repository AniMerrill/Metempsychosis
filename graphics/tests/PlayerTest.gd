extends Node2D

# The main variables of the character rig to make it animate:
## walking
## facing_front
## facing_right
## look_position

# And then these for costume pieces
## current_tool
## current_mouth
## current_hair
## current_hat
## current_face
onready var rig := $PlayerARig

var velocity := Vector2.ZERO
var speed := 100

var look_position := Vector2.ZERO

func _ready():
	rig.look_position = Vector2(200,200)
	
	var ignore
	
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer/Button.connect(
			"pressed", self, "set_tool", [rig.TOOL.NONE])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer/Button2.connect(
			"pressed", self, "set_tool", [rig.TOOL.HAMMER])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer/Button3.connect(
			"pressed", self, "set_tool", [rig.TOOL.SCREWDRIVER])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer/Button4.connect(
			"pressed", self, "set_tool", [rig.TOOL.PISTOL])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer/Button5.connect(
			"pressed", self, "set_tool", [rig.TOOL.PAINTBRUSH])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer/Button6.connect(
			"pressed", self, "set_tool", [rig.TOOL.DEBUG])
	
	
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer2/Button.connect(
			"pressed", self, "set_mouth", [rig.MOUTH.FROWN])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer2/Button2.connect(
			"pressed", self, "set_mouth", [rig.MOUTH.SMILE])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer2/Button3.connect(
			"pressed", self, "set_mouth", [rig.MOUTH.OPEN])
	
	
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer3/Button.connect(
			"pressed", self, "set_hair", [rig.HAIR.DOWN])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer3/Button2.connect(
			"pressed", self, "set_hair", [rig.HAIR.PONYTAIL])
	
	
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer4/Button.connect(
			"pressed", self, "set_hat", [rig.HAT.NONE])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer4/Button2.connect(
			"pressed", self, "set_hat", [rig.HAT.BOWLER])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer4/Button3.connect(
			"pressed", self, "set_hat", [rig.HAT.FEZ])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer4/Button4.connect(
			"pressed", self, "set_hat", [rig.HAT.HELMET])
	
	
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer5/Button.connect(
			"pressed", self, "set_face", [rig.FACE.NONE])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer5/Button2.connect(
			"pressed", self, "set_face", [rig.FACE.BEARD])
	ignore = $CanvasLayer/VBoxContainer/HBoxContainer5/Button3.connect(
			"pressed", self, "set_face", [rig.FACE.MOUSTACHE])
	
	ignore = ignore

func _input(event):
	if event is InputEventMouseMotion:
		look_position = event.position

func _process(delta):
	if Input.is_action_pressed("ui_down"):
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	else:
		velocity.y = 0
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	else:
		velocity.x = 0
	
	if velocity == Vector2.ZERO:
		rig.walking = false
	else:
		rig.walking = true
		
		if velocity.x > 0:
			rig.facing_right = true
		elif velocity.x < 0:
			rig.facing_right = false
		
		if velocity.y > 0:
			rig.facing_front = true
		elif velocity.y < 0:
			rig.facing_front = false
	
	position += velocity * delta
	
	#rig.look_position = look_position

func set_tool(new_tool : int) -> void:
	rig.current_tool = new_tool

func set_mouth(mouth : int) -> void:
	rig.current_mouth = mouth

func set_hair(hair : int) -> void:
	rig.current_hair = hair

func set_hat(hat : int) -> void:
	rig.current_hat = hat

func set_face(face : int) -> void:
	rig.current_face = face