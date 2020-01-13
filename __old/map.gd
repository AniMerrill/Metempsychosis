extends Navigation2D

" Will need a NavigationPolygonInstance as child node "


onready var _player = $"../player"

var target_position = Vector2()
var path = []

func _input(event):
	if (event.is_action_pressed("click")):
		target_position = event.position
		_update_path(_player.get_position(), target_position)
	else:
		return
	
func _update_path(start_position, target_position):
	path = get_simple_path(start_position, target_position)
	path.remove(0)
	_player.target = path
	_player.set_process(true)
