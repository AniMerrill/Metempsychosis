extends Node2D

enum TOOL{
	DEBUG = -10,
	
	NONE = -1,
	
	HAMMER = 0,
	SCREWDRIVER = 1,
	PISTOL = 2,
	PAINTBRUSH = 3
	}

enum MOUTH{
	FROWN = 6,
	SMILE = 7,
	OPEN = 8
	}

enum HAIR{
	DOWN,
	PONYTAIL,
	}

enum HAT{
	NONE,
	BOWLER,
	FEZ,
	HELMET
	}

enum FACE{
	NONE,
	BEARD,
	MOUSTACHE
	}

onready var anim_tree = $AnimationTree

onready var eye := $Eye
onready var look_target := $LookTarget

var eye_center := Vector2(0, -41)
var eye_radius := 2.0

var facing_front := true setget set_facing_front
var facing_right := true setget set_facing_right
var walking := false setget set_walking

var current_tool : int = TOOL.NONE setget set_tool
var current_mouth : int = MOUTH.FROWN setget set_mouth
var current_hair : int = HAIR.PONYTAIL setget set_hair
var current_hat : int = HAT.NONE setget set_hat
var current_face : int = FACE.NONE setget set_face

func _ready() -> void:
# warning-ignore:return_value_discarded
	$Timer.connect("timeout", self, "blink_timer")
	anim_tree.active = true

func _process(delta : float) -> void:
	
	
	pass

func set_facing_front(value : bool) -> void:
	facing_front = value
	
	if facing_front:
		anim_tree["parameters/ZIndex/current"] = 1
	else:
		anim_tree["parameters/ZIndex/current"] = 0
	
	set_anim_states()

func set_facing_right(value : bool) -> void:
	facing_right = value
	
	if facing_right:
		scale.x = 1
	else:
		scale.x = -1

func set_walking(value : bool) -> void:
	walking = value
	
	set_anim_states()

func set_tool(value : int) -> void:
	current_tool = value
	
	set_anim_states()

func set_mouth(value : int) -> void:
	current_mouth = value
	
	$Mouth.frame = current_mouth

func set_hair(value : int) -> void:
	current_hair = value
	
	set_anim_states()

func set_hat(value : int) -> void:
	current_hat = value

func set_face(value : int) -> void:
	current_face = value

func set_anim_states() -> void:
	var body_anim = anim_tree["parameters/Body/playback"]
	var arm_anim = anim_tree["parameters/Arm/playback"]
	
	if facing_front:
		if walking:
			body_anim.travel("front_body_walk")
			
			if current_tool == TOOL.NONE:
				arm_anim.travel("front_arm_walk")
			else:
				arm_anim.travel("front_arm_walk_tool")
		else:
			body_anim.travel("front_body_idle")
			
			if current_tool == TOOL.NONE:
				arm_anim.travel("front_arm_idle")
			else:
				arm_anim.travel("front_arm_idle_tool")
		
		match current_hair:
			HAIR.DOWN:
				$Hair.frame = 12
			HAIR.PONYTAIL:
				$Hair.frame = 14
		
		match current_hat:
			HAT.NONE:
				$Hat.visible = false
			HAT.BOWLER:
				$Hat.visible = true
				$Hat.frame = 18
				
				$Hair.visible = true
				$Face.visible = true
			HAT.FEZ:
				$Hat.visible = true
				$Hat.frame = 20
				
				$Hair.visible = true
				$Face.visible = true
			HAT.HELMET:
				$Hat.visible = true
				$Hat.frame = 22
				
				$Hair.visible = false
				$Face.visible = false
		
		match current_face:
			FACE.NONE:
				$Face.visible = false
			FACE.BEARD:
				$Face.visible = true
				$Face.frame = 24
			FACE.MOUSTACHE:
				$Face.visible = true
				$Face.frame = 26
	else:
		if walking:
			body_anim.travel("back_body_walk")
			
			if current_tool == TOOL.NONE:
				arm_anim.travel("back_arm_walk")
			else:
				arm_anim.travel("back_arm_walk_tool")
		else:
			body_anim.travel("back_body_idle")
			
			if current_tool == TOOL.NONE:
				arm_anim.travel("back_arm_idle")
			else:
				arm_anim.travel("back_arm_idle_tool")
		
		match current_hair:
			HAIR.DOWN:
				$Hair.frame = 13
			HAIR.PONYTAIL:
				$Hair.frame = 15
		
		match current_hat:
			HAT.NONE:
				$Hat.visible = false
			HAT.BOWLER:
				$Hat.visible = true
				$Hat.frame = 19
				
				$Hair.visible = true
				$Face.visible = true
			HAT.FEZ:
				$Hat.visible = true
				$Hat.frame = 21
				
				$Hair.visible = true
				$Face.visible = true
			HAT.HELMET:
				$Hat.visible = true
				$Hat.frame = 23
				
				$Hair.visible = false
				$Face.visible = false
		
		match current_face:
			FACE.NONE:
				$Face.visible = false
			FACE.BEARD:
				$Face.visible = true
				$Face.frame = 25
			FACE.MOUSTACHE:
				$Face.visible = true
				$Face.frame = 27
	
	match current_tool:
		TOOL.NONE, TOOL.DEBUG:
			$Arm/Tool.visible = false
		TOOL.HAMMER:
			$Arm/Tool.visible = true
			$Arm/Tool.frame = 0
		TOOL.SCREWDRIVER:
			$Arm/Tool.visible = true
			$Arm/Tool.frame = 1
		TOOL.PAINTBRUSH:
			$Arm/Tool.visible = true
			$Arm/Tool.frame = 2

func blink_timer() -> void:
	anim_tree["parameters/Blink/active"] = true