tool
extends Node2D

# Please give door data in this order
enum { EAST, NORTH, WEST, SOUTH }

# To control the doors in the array:
## locked - changes the light indicator
## opened - gives a light warning signal, then either opens or closes the door

# Additionally, when the command is given to open the door, the class uses
# 'processing' to prevent two opening events from happening at the same time.
# Please do not change this variable manually, but it might be a good idea
# to check it when the player tries to open the door to give them a negative
# noise signal to let them know the attempt to open was not successful.
class Door:
	var door_anim : AnimationPlayer
	var light_anim : AnimationPlayer
	var sprite : Sprite
	
	var locked := false setget set_locked
	var opened := false setget set_opened
	var visible := true
	
	var processing := false
	
	signal action_finished
	
	func _init(_locked : bool, _opened := false, _visible := true) -> void:
		locked = _locked
		opened = _opened
		visible = _visible
	
	func initialize_nodes(_door_anim, _light_anim, _sprite) -> void:
		door_anim = _door_anim
		light_anim = _light_anim
		sprite = _sprite
		
		if not visible:
			sprite.visible = false
		
		if opened:
			door_anim.play("DoorOpened")
		
		# warning-ignore:return_value_discarded
		door_anim.connect("animation_finished", self, "anim_finished")
		# warning-ignore:return_value_discarded
		light_anim.connect("animation_finished", self, "anim_finished")
	
	func set_locked(value : bool) -> void:
		locked = value
		
		if locked:
			light_anim.play("Locked")
			
		else:
			light_anim.play("Opened")
			
	
	func set_opened(value : bool) -> void:
		if !processing:
			SoundModule.play_sfx("DoorOpenWarning")
			opened = value
			processing = true
			
			if locked:
				light_anim.play("Locked_Warning")
			else:
				light_anim.play("Opened_Warning")
	
	func anim_finished(anim_name : String) -> void:
		if anim_name == "Opened_Warning" || anim_name == "Locked_Warning":
			if locked:
				light_anim.play("Locked")
				opened = false
			else:
				light_anim.play("Opened")
				SoundModule.play_sfx("DoorSlideUp")
				
			if opened:
				door_anim.play("Open")
				
				
				SoundModule.play_sfx("DoorSlideUp")
			
			elif not locked:
				door_anim.play_backwards("Open")
				
				SoundModule.play_sfx("DoorSlideDown")
				
				sprite.visible = true
			else:
				processing = false
				emit_signal("action_finished")
		elif anim_name == "Open":
			if opened:
				sprite.visible = false
			
			processing = false
			emit_signal("action_finished")

onready var north_wall_no_door = preload("res://graphics/room/back_wall_no_door.png")
onready var north_wall_door = preload("res://graphics/room/back_wall_door.png")

# EAST, NORTH, WEST, SOUTH
var doors := [null, null, null, null]

func _ready() -> void:
	initialize_room()

# This was just a test to see if it was possible, this scene can be reused
# over and over for rooms by simply resetting the doors[] array with new
# values and reinitializing the room.
#func _process(delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		doors.clear()
#
#		for i in range(4):
#			match randi() % 3:
#				0:
#					doors.append(null)
#				1:
#					doors.append(Door.new(true))
#				2:
#					doors.append(Door.new(false))
#
#		initialize_room()

func initialize_room() -> void:
	for i in range(doors.size()):
		if doors[i] != null:
			match i:
				EAST:
					$EastWallNoDoor.visible = false
					
					$EastWallDoorA.visible = true
					$EastWallDoorB.visible = true
					$EastDoor.visible = true
					$EastDoorLight.visible = true
					
					doors[i].initialize_nodes(
							$EastDoor/AnimationPlayer, 
							$EastDoorLight/AnimationPlayer,
							$EastDoor
							)
					
					if doors[i].locked:
						doors[i].light_anim.play("Locked")
					else:
						doors[i].light_anim.play("Opened")
				NORTH:
					$NorthWall.texture = north_wall_door
					$NorthWallTop.visible = true
					
					$NorthDoor.visible = true
					$NorthDoorLight.visible = true
					
					doors[i].initialize_nodes(
							$NorthDoor/AnimationPlayer, 
							$NorthDoorLight/AnimationPlayer,
							$NorthDoor
							)
					
					if doors[i].locked:
						doors[i].light_anim.play("Locked")
					else:
						doors[i].light_anim.play("Opened")
				WEST:
					$WestWallNoDoor.visible = false
					
					$WestWallDoorA.visible = true
					$WestWallDoorB.visible = true
					$WestDoor.visible = true
					$WestDoorLight.visible = true
					
					doors[i].initialize_nodes(
							$WestDoor/AnimationPlayer, 
							$WestDoorLight/AnimationPlayer,
							$WestDoor
							)
					
					if doors[i].locked:
						doors[i].light_anim.play("Locked")
					else:
						doors[i].light_anim.play("Opened")
				SOUTH:
					$SouthDoorFrame.visible = true
					$SouthDoor.visible = true
					$SouthDoorLight.visible = true
					
					doors[i].initialize_nodes(
							$SouthDoor/AnimationPlayer, 
							$SouthDoorLight/AnimationPlayer,
							$SouthDoor
							)
					
					if doors[i].locked:
						doors[i].light_anim.play("Locked")
					else:
						doors[i].light_anim.play("Opened")
		else:
			match i:
				EAST:
					$EastWallNoDoor.visible = true
					
					$EastWallDoorA.visible = false
					$EastWallDoorB.visible = false
					$EastDoor.visible = false
					$EastDoorLight.visible = false
				NORTH:
					$NorthWall.texture = north_wall_no_door
					$NorthWallTop.visible = false
					
					$NorthDoor.visible = false
					$NorthDoorLight.visible = false
				WEST:
					$WestWallNoDoor.visible = true
					
					$WestWallDoorA.visible = false
					$WestWallDoorB.visible = false
					$WestDoor.visible = false
					$WestDoorLight.visible = false
				SOUTH:
					$SouthDoorFrame.visible = false
					$SouthDoor.visible = false
					$SouthDoorLight.visible = false

func set_final_door_east():
	$EastDoor.texture = load("res://graphics/room/blue_side_door.png")

func set_final_door_west():
	$WestDoor.texture = load("res://graphics/room/red_side_door.png")
	

func play_sound_door_open() -> void:
	SoundModule.play_sfx("DoorSlideUp")