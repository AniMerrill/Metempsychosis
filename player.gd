extends Area2D

export var speed = 200

var velocity = Vector2()

var target : PoolVector2Array

func _ready():
	set_process(false)

func _process(delta):
	var _speed = speed * delta
	_move(_speed)
	
func _move(speed):
	var last_point = position
	for i in range(target.size()):
		var distance_between_points = last_point.distance_to(target[0])
		if speed <= distance_between_points:
			position = last_point.linear_interpolate(target[0], speed/distance_between_points)
			break
		elif speed < 0.0:
			position = target[0]
			set_process(false)
			break
			
		speed -= distance_between_points
		last_point = target[0]
		target.remove(0)
	pass