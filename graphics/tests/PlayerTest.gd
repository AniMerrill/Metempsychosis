extends Node2D

onready var rig := $PlayerARig

var velocity := Vector2.ZERO
var speed := 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseMotion:
		rig.look_target.global_position = event.position

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
