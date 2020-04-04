extends Control


enum {WHITE, RED, BLUE, GREEN, PURPLE}
enum {NORTH, EAST, WEST, SOUTH}

signal solved()

var colors := [
		Color.white,
		Color.red,
		Color.blue,
		Color.green,
		Color.purple
		]
var directions := [WHITE, WHITE, WHITE, WHITE]
var solution := [RED, BLUE, GREEN, PURPLE]


func _ready():
	$north.connect("pressed", self, "_on_pressed", [NORTH])
	$east.connect("pressed", self, "_on_pressed", [EAST])
	$west.connect("pressed", self, "_on_pressed", [WEST])
	$south.connect("pressed", self, "_on_pressed", [SOUTH])


func _on_pressed(direction : int) -> void:
	# TODO: I eventually want to make sprites instead of just switching
	# through a color array
	if puzzle_solved():
		return  # Freeze solution.
	
	match direction:
		NORTH:
			directions[NORTH] = change_color(directions[NORTH])
			$north_rect.color = colors[directions[NORTH]]
		EAST:
			directions[EAST] = change_color(directions[EAST])
			$east_rect.color = colors[directions[EAST]]
		WEST:
			directions[WEST] = change_color(directions[WEST])
			$west_rect.color = colors[directions[WEST]]
		SOUTH:
			directions[SOUTH] = change_color(directions[SOUTH])
			$south_rect.color = colors[directions[SOUTH]]
	
	node_color_updated()


func change_color(color : int) -> int:
	match color:
		WHITE:
			return RED
		RED:
			return BLUE
		BLUE:
			return GREEN
		GREEN:
			return PURPLE
		_:
			return WHITE


func node_color_updated() -> void:
	if puzzle_solved():
		emit_signal("solved")


func puzzle_solved():
	return (
			directions[NORTH] == solution[NORTH] and
			directions[EAST] == solution[EAST] and
			directions[WEST] == solution[WEST] and
			directions[SOUTH] == solution[SOUTH] 
			)
