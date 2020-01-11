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
		# NOTE: Example values for now.
		
		# Store whether each player has read the introduction text.
		A_SEEN_INTRODUCTION = 0,
		B_SEEN_INTRODUCTION = 1,
		
		# Store each player's progress through the game.
		A_PRISON_DOOR_OPEN = 2,
		B_PRISON_DOOR_OPEN = 3,
		A_HAS_YELLOW_KEY = 4,
		B_DISABLED_TURRET = 5,
		
		# Common / player-independent progress.
		GUARD_ROBOT_BROKEN = 60,  # Added higher value for test purposes.
	}


# The current state of the game.
# Enums listed here are "true", all others are "false".
var state := []


# Whether the current player of the game is player A or B.
#
# TODO(ereborn): Expose API.
var i_am_player_a := true


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
#
# TODO(ereborn): Figure out whether the encoding should look different when
# called as player A from when called as player B.
func serialize() -> String:
	var highest_enum = _get_highest_enum()
	var byte_value : int = 0
	for enum_value in range(highest_enum):
		if get_state(enum_value):
			byte_value += 1 << enum_value
	var format := '%0' + str(ceil(highest_enum / 4)) + 'X'
	return format % byte_value


# Overwrites the current state with the provided serialized state.
func deserialize(serialized_state : String) -> void:
	assert(serialized_state.is_valid_hex_number())
	var state_value := ('0x' + serialized_state).hex_to_int()
	clear_state()
	var highest_enum = _get_highest_enum()
	for enum_value in range(highest_enum):
		if state_value & (1 << enum_value):
			set_state(enum_value, true)
