extends CanvasLayer

signal scene_changed()

onready var animation_player = $AnimationPlayer
onready var transition_text = $TransitionText

var current_scene = null
var fade_speed := 1.0

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	transition_text.visible = false
	$AnimationPlayer.play("init")

func change_scene(path, text = null, txt_duration = 4.0):
	fade_speed = 1.0
	call_deferred("_deferred_change_scene", path, text, txt_duration)

func change_scene_fast(path, text = null, txt_duration = 4.0):
	fade_speed = 2.0
	call_deferred("_deferred_change_scene", path, text, txt_duration)

func change_scene_direct(path):
	call_deferred("_deferred_change_scene_direct", path)

func _deferred_change_scene(path, text = null, txt_duration = 4.0):
	$AnimationPlayer.play("fade", -1, fade_speed)
	yield(animation_player, "animation_finished")
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	current_scene.free()
	if text != null:
		transition_text.text = text
		transition_text.visible = true
		yield(get_tree().create_timer(txt_duration), "timeout")
		transition_text.visible = false
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	# optional, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	if fade_speed <= 1.0:
		yield(get_tree().create_timer(1 / fade_speed), "timeout")
	$AnimationPlayer.play("fade", -1, -1 * fade_speed, true)
#	animation_player.play_backwards("fade")
	yield(animation_player, "animation_finished")
	emit_signal("scene_changed")

func _deferred_change_scene_direct(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
	emit_signal("scene_changed")
