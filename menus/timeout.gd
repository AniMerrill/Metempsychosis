extends CanvasLayer

onready var timer = $Timer
onready var pretimer = $PreTimer
onready var visual = $Visual

func _ready():
	visual.visible = false

func set_timeout(seconds : float):
	timer.stop()
	pretimer.stop()
	timer.start(seconds)
	pretimer.start(seconds - 60.0)

func stop_timer():
	timer.stop()
	pretimer.stop()

func _on_Timer_timeout():
	GameState.interaction_is_frozen = true
	visual.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	var code = GameState.serialize()
	GameState.set_last_output_code(code)
	SceneTransition.change_scene('menus/AwaitTurn.tscn')
	yield(get_tree().create_timer(1.0), "timeout")
	visual.visible = false

func _on_PreTimer_timeout():
	MusicModule.state_changed("guard")
