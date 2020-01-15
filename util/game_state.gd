""" Manages the state of the game.

The state is simply a collection of booleans. These are used to represent:
	- What dialog the player has already seen (and need not be replayed);
	- What state the world is in (doors opened, bombs dismanteled, etc.)

The state is stored for both players A and B, even though only one of the
players will be actually playing the game in a current run.

The state can be serialized to a hexadecimal string which can be shared between
the players by whichever communication method they like.

This module is auto-loaded as GameState. All state querying and manipulation
must be done through this module.

Additionally, this module ensures that the game preserves whether the player
is playing as player A or B (also when the game is closed in-between).

TODO(ereborn): Add simple XOR encryption to avoid obvious tweaking of the
  exported state.
TODO(ereborn): Add one char serving as integrity check.
"""
extends Node


# Human-readable names for the state booleans.
#
# Values should be given explicitly to ensure consisted encoding.
# Negative values should not be used.
enum STATE {
		POD_ROOMS_UNLOCKED = 0,
		CODE_CREATED_BY_PLAYER_A = 1,
		
		# NOTE: Example values below.
		
		# Common / player-independent progress.
		GUARD_ROBOT_BROKEN = 10,  # Added higher value for test purposes.
	}


# Representing the two players.
enum PLAYER {
		INVALID_PLAYER = 0,  # No player selected yet.
		PLAYER_A = 1,
		PLAYER_B = 2,
	}


# The current state of the game.
# Enums listed here are "true", all others are "false".
var state := []


# The player controlled in this game.
var _my_player : int = PLAYER.INVALID_PLAYER


# The most recent code to be communicated to the other player.
var _my_last_output_code := '(no code)'


# Whether the player can start a new interaction or not. Volatile state.
var interaction_is_frozen = false

# Get the current player.
func current_player() -> int:
	if _my_player == PLAYER.INVALID_PLAYER:
		_load_local_data()
	return _my_player


# Set the current player.
func set_current_player(player : int) -> void:
	_my_player = player
	_save_local_data()


# Get the most recent code that has to be communicated to the other player.
func last_output_code() -> String:
	_load_local_data()
	return _my_last_output_code


# Set the most recent code to be communicated.
func set_last_output_code(code : String) -> void:
	_my_last_output_code = code
	_save_local_data()


const save_file = 'user://save_game_state.save'

# Save data local to the player.
func _save_local_data():
	var save_dict = {
		"my_player" : _my_player,
		"my_last_output_code": _my_last_output_code,
	}
	var save_game = File.new()
	save_game.open(save_file, File.WRITE)
	save_game.store_line(to_json(save_dict))
	save_game.close()


# Load data local to the player.
func _load_local_data():
	var save_game = File.new()
	if not save_game.file_exists(save_file):
		return # No save yet to load.
	save_game.open(save_file, File.READ)
	var saved_data = parse_json(save_game.get_line())
	_my_player = saved_data["my_player"]
	_my_last_output_code = saved_data["my_last_output_code"]
	save_game.close()


# Returns true if the requested enum is true in the current state, false
# otherwise.
func get_state(state_enum : int) -> bool:
	return state.has(state_enum)


# Updates the state to represent the new value of the provide enum.
func set_state(state_enum : int, value : bool) -> void:
	if value and not state.has(state_enum):
		state.append(state_enum)
	if not value and state.has(state_enum):
		state.erase(state_enum)


# Updates all enums to false.
func clear_state():
	state = []


# Auxiliary function for serialization.
func _get_highest_enum():
	var enum_values = STATE.values()
	enum_values.sort()
	return enum_values[-1]


# Serializes the state to a hexadecimal string.
func serialize() -> String:
	set_state(STATE.CODE_CREATED_BY_PLAYER_A, current_player() == PLAYER.PLAYER_A)
	
	var highest_enum = _get_highest_enum()
	var byte_value : int = 0
	for enum_value in range(highest_enum):
		if get_state(enum_value):
			byte_value += 1 << enum_value
	var format := '%0' + str(ceil(highest_enum / 4.0)) + 'X'
	return format % byte_value


# Overwrites the current state with the provided serialized state.
enum ERROR_CODE {
		OK = 0,
		INVALID_ENCODING = 1,
		OTHER_PLAYER_CODE = 2,
	}

func deserialize(serialized_state : String) -> int:
	if not serialized_state.is_valid_hex_number():
		return ERROR_CODE.INVALID_ENCODING
	var state_value := ('0x' + serialized_state).hex_to_int()
	clear_state()
	var highest_enum = _get_highest_enum()
	for enum_value in range(highest_enum):
		if state_value & (1 << enum_value):
			set_state(enum_value, true)
	
	var code_by_a = get_state(STATE.CODE_CREATED_BY_PLAYER_A)
	var player_is_a = current_player() == PLAYER.PLAYER_A
	if code_by_a == player_is_a:
		return ERROR_CODE.OTHER_PLAYER_CODE
	return ERROR_CODE.OK
