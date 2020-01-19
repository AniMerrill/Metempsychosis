extends Node2D

var rig

var path : PoolVector2Array setget set_path
var move_speed := 200

const move_epsilon = 10.0

signal position_reached

func _ready():
	set_process(false)
	rig = $PlayerARig if GameState.current_player() == GameState.PLAYER.PLAYER_A else $PlayerBRig
	rig.visible = true
	rig.load_from_game_state(GameState.current_player())

func swap_rig():
	rig.visible = false
	rig = $PlayerBRig if GameState.current_player() == GameState.PLAYER.PLAYER_A else $PlayerARig
	rig.visible = true

func set_path(value : PoolVector2Array) -> void:
	path = value
	set_process(true)

func _process(delta):
	if path.size() == 0:
		set_process(false)
		emit_signal("position_reached")
		return
	var next_position = path[0]
	if position.distance_to(next_position) <= move_epsilon:
		position = next_position
		path.remove(0)
		rig.walking = false
		return
	var velocity = (next_position - position).normalized() * move_speed
	position += velocity * delta
	rig.walking = true
	rig.facing_right = velocity.x > 0
	rig.facing_front = velocity.y > 0
