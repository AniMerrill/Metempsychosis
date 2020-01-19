extends CanvasLayer

onready var timer = $Timer
onready var visual = $Visual

func _ready():
	visual.visible = false

func set_timeout(seconds : float):
	timer.stop()
	timer.start(seconds)

func stop_timer():
	timer.stop()

func _on_Timer_timeout():
	GameState.interaction_is_frozen = true
	visual.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	var code = GameState.serialize()
	GameState.set_last_output_code(code)
	SceneTransition.change_scene('menus/AwaitTurn.tscn')
	yield(get_tree().create_timer(1.0), "timeout")
	visual.visible = false
	
