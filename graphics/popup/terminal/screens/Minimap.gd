extends Control

enum {UP, DOWN, LEFT, RIGHT}

var parent_menu = null

export var current_room := Vector2()

var blink := false

# Machine 7,3 and 8,3
var map := {
	str(Vector2(1,0)) : {
			"name" : "[KEY]", 
			"doors" : [DOWN]
			},
	str(Vector2(3,0)) : {
			"name" : "North Room", 
			"doors" : [DOWN]
			},
	str(Vector2(11,0)) : {
			"name" : "[KEY]", 
			"doors" : [DOWN]
			},
	str(Vector2(1,1)) : {
			"name" : "Exclusive Suite", 
			"doors" : [UP, DOWN]
			},
	str(Vector2(3,1)) : {
			"name" : "", 
			"doors" : [UP, DOWN, RIGHT]
			},
	str(Vector2(4,2)) : {
			"name" : "Sliding Chamber Control", 
			"doors" : [LEFT]
			},
	str(Vector2(5,1)) : {
			"name" : "[KEY]", 
			"doors" : [DOWN]
			},
	str(Vector2(11,1)) : {
			"name" : "Colors of the Wind", 
			"doors" : [DOWN]
			},
	str(Vector2(1,2)) : {
			"name" : "", 
			"doors" : [DOWN]
			},
	str(Vector2(3,2)) : {
			"name" : "", 
			"doors" : [UP, DOWN]
			},
	str(Vector2(5,2)) : {
			"name" : "Noise Terminal", 
			"doors" : [UP, DOWN]
			},
	str(Vector2(10,2)) : {
			"name" : "Art Gallery", 
			"doors" : [UP, DOWN, LEFT, RIGHT]
			},
	str(Vector2(11,2)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT]
			},
	str(Vector2(0,3)) : {
			"name" : "West Room", 
			"doors" : [LEFT]
			},
	str(Vector2(1,3)) : {
			"name" : "", 
			"doors" : [UP, LEFT, RIGHT]
			},
	str(Vector2(2,3)) : {
			"name" : "", 
			"doors" : [LEFT, RIGHT]
			},
	str(Vector2(3,3)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT, RIGHT]
			},
	str(Vector2(4,3)) : {
			"name" : "", 
			"doors" : [LEFT, RIGHT]
			},
	str(Vector2(5,3)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT, RIGHT]
			},
	str(Vector2(6,3)) : {
			"name" : "Blue Triple Lock", 
			"doors" : [ DOWN, LEFT]
			},
	str(Vector2(9,3)) : {
			"name" : "Red Triple Lock", 
			"doors" : [DOWN, RIGHT]
			},
	str(Vector2(10,3)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT, RIGHT]
			},
	str(Vector2(11,3)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT, RIGHT]
			},
	str(Vector2(12,3)) : {
			"name" : "", 
			"doors" : [LEFT, RIGHT]
			},
	str(Vector2(13,3)) : {
			"name" : "Grid Room", 
			"doors" : [ LEFT, RIGHT]
			},
	str(Vector2(14,3)) : {
			"name" : "[KEY]", 
			"doors" : [LEFT]
			},
	str(Vector2(3,4)) : {
			"name" : "", 
			"doors" : [UP, DOWN,]
			},
	str(Vector2(5,4)) : {
			"name" : "Representative #1 Cryrostasis", 
			"doors" : [RIGHT]
			},
	str(Vector2(6,4)) : {
			"name" : "", 
			"doors" : [UP, LEFT, RIGHT]
			},
	str(Vector2(7,4)) : {
			"name" : "[DROPBOX]", 
			"doors" : [LEFT]
			},
	str(Vector2(8,4)) : {
			"name" : "[DROPBOX]", 
			"doors" : [RIGHT]
			},
	str(Vector2(9,4)) : {
			"name" : "[KEY]", 
			"doors" : [RIGHT]
			},
	str(Vector2(10,4)) : {
			"name" : "Representative #2 Cryrostasis", 
			"doors" : [LEFT]
			},
	str(Vector2(11,4)) : {
			"name" : "", 
			"doors" : [UP, DOWN]
			},
	str(Vector2(2,5)) : {
			"name" : "Sliding", 
			"doors" : [RIGHT]
			},
	str(Vector2(3,5)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT, RIGHT]
			},
	str(Vector2(9,5)) : {
			"name" : "", 
			"doors" : [UP, DOWN]
			},
	str(Vector2(10,5)) : {
			"name" : "", 
			"doors" : [ DOWN, LEFT, RIGHT]
			},
	str(Vector2(11,5)) : {
			"name" : "", 
			"doors" : [UP, DOWN, LEFT]
			},
	str(Vector2(2,6)) : {
			"name" : "[KEY]", 
			"doors" : [UP]
			},
	str(Vector2(3,6)) : {
			"name" : "South Room", 
			"doors" : [UP]
			},
	str(Vector2(9,6)) : {
			"name" : "", 
			"doors" : [UP, DOWN]
			},
	str(Vector2(11, 6)) : {
			"name" : "Switch Room", 
			"doors" : [UP]
			},
	str(Vector2(9,7)) : {
			"name" : "Sliding Puzzle", 
			"doors" : [UP]
			}
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	$Up.connect("pressed", self, "direction_pressed", [UP])
	# warning-ignore:return_value_discarded
	$Down.connect("pressed", self, "direction_pressed", [DOWN])
	# warning-ignore:return_value_discarded
	$Left.connect("pressed", self, "direction_pressed", [LEFT])
	# warning-ignore:return_value_discarded
	$Right.connect("pressed", self, "direction_pressed", [RIGHT])
	# warning-ignore:return_value_discarded
	$X.connect("pressed", self, "x_pressed")
	
	$Timer.connect("timeout", self, "toggle_blink")
	
	connect("draw", self, "_draw")
	
	if map.has(str(current_room)):
		$RoomName.text = map[str(current_room)]["name"]

func _draw():
	var spacing := Vector2(1.5, 1.5)
	var offset := Vector2(75, 55) - current_room * 10 * spacing
	
	for y in 8:
		for x in 15:
			
			if x * 10 * spacing.x + offset.x < 0:
				continue
			
			if y * 10 * spacing.y + offset.y < 0:
				continue
			
			if map.has(str(Vector2(x, y))):
				for door in map[str(Vector2(x, y))]["doors"]:
					match door:
						UP:
							draw_rect(
									Rect2(
											x * 10 * spacing.x + offset.x + 2.5, 
											y * 10 * spacing.y + offset.y - 5, 
											5, 
											5
											), 
									Color("#576f2a"), 
									false
									)
						DOWN:
							draw_rect(
									Rect2(
											x * 10 * spacing.x + offset.x + 2.5, 
											y * 10 * spacing.y + offset.y + 10, 
											5, 
											5
											), 
									Color("#576f2a"), 
									false
									)
						LEFT:
							draw_rect(
									Rect2(
											x * 10 * spacing.x + offset.x - 5, 
											y * 10 * spacing.y + offset.y + 2.5, 
											5, 
											5
											), 
									Color("#576f2a"), 
									false
									)
						RIGHT:
							draw_rect(
									Rect2(
											x * 10 * spacing.x + offset.x + 10, 
											y * 10 * spacing.y + offset.y + 2.5, 
											5, 
											5
											), 
									Color("#576f2a"), 
									false
									)
				
				
				draw_rect(
						Rect2(
								x * 10 * spacing.x + offset.x, 
								y * 10 * spacing.y + offset.y, 
								10, 
								10
								), 
						Color("#576f2a"), 
						false
						)
	
	if blink:
		draw_rect(
			Rect2(
					current_room.x * 10 * spacing.x + offset.x, 
					current_room.y * 10 * spacing.y + offset.y, 
					10, 
					10
					), 
			Color("#b9ff36"), 
			true
			)
	
	# Draw machine room
	draw_rect(Rect2(105 + 8 + offset.x, 45 + offset.y,10,10),Color("#576f2a"), false)
	draw_rect(
			Rect2(
					6 * 10 * spacing.x + offset.x + 10, 
					3 * 10 * spacing.y + offset.y + 2.5, 
					13, 
					5
					), 
			Color("#576f2a"), 
			false
			)
	draw_rect(
			Rect2(
					8 * 10 * spacing.x + offset.x + 3, 
					3 * 10 * spacing.y + offset.y + 2.5, 
					12, 
					5
					), 
			Color("#576f2a"), 
			false
			)

func x_pressed() -> void:
	if parent_menu != null:
		visible = false
		parent_menu.set_visibility(true)

func direction_pressed(direction) -> void:
	var search_direction := Vector2()
	var new_room := Vector2()
	
	match direction:
		UP:
			search_direction = Vector2(0, -1)
		DOWN:
			search_direction = Vector2(0, 1)
		LEFT:
			search_direction = Vector2(-1, 0)
		RIGHT:
			search_direction = Vector2(1, 0)
	
	new_room = current_room + search_direction
	
	while !map.has(str(new_room)):
		
		if new_room.x < 0:
			new_room.x = 15
		elif new_room.x > 15:
			new_room.x = 0
		
		if new_room.y < 0:
			new_room.y = 8
		elif new_room.y > 8:
			new_room.y = 0
		
		new_room += search_direction
	
	current_room = new_room
	
	blink = false
	toggle_blink()
	$Timer.start()
	
	$RoomName.text = map[str(current_room)]["name"]

func toggle_blink():
	blink = not blink
	
	update()