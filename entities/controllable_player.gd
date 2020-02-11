extends Node2D


signal position_reached

const MOVE_EPSILON = 10.0

var path : PoolVector2Array setget set_path
var move_speed := 200

var Rig : PlayerRig


func _ready():
	set_process(false)
	Rig = $PlayerARig if GameState.current_player() == GameState.PLAYER.PLAYER_A else $PlayerBRig
	Rig.visible = true
	Rig.load_from_game_state(GameState.current_player())


func _process(delta):
	if path.size() == 0:
		set_process(false)
		emit_signal("position_reached")
		return
	var next_position = path[0]
	if position.distance_to(next_position) <= MOVE_EPSILON:
		position = next_position
		path.remove(0)
		Rig.walking = false
		return
	var velocity = (next_position - position).normalized() * move_speed
	position += velocity * delta
	Rig.walking = true
	
	if velocity.x != 0:
		Rig.facing_right = velocity.x > 0
	if velocity.y != 0:
		Rig.facing_front = velocity.y > 0


func _input(event):
	if event is InputEventMouseMotion:
		Rig.look_position = event.position


func swap_rig():
	Rig.visible = false
	Rig = $PlayerBRig if GameState.current_player() == GameState.PLAYER.PLAYER_A else $PlayerARig
	Rig.visible = true


func set_path(value : PoolVector2Array) -> void:
	path = value
	set_process(true)

