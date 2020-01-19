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
"""
extends Node

const PlayerRig = preload("res://graphics/players/PlayerRig.gd")


# Human-readable names for the state booleans.
#
# Values should be given explicitly to ensure consisted encoding.
# Negative values should not be used.
#
## NEXT_TAG: 56
enum STATE {
		CODE_CREATED_BY_PLAYER_A = 0,
		
		## Puzzle 1: Opening.
		POD_ROOMS_UNLOCKED = 1,
		
		## Puzzle 5: Mutual exclusive doors puzzle.
		PLAYER_A_IN_XOR_POD = 2,
		XOR_ROOM_SWITCHED = 3,
		
		## Key locations. If none are true, they are in their starting place.
		## Each group should be mutually exclusive.
		## We are using 3 bits where we only need 2 per key. Oh well.
		KEY_A_1_POS_A = 4,
		KEY_A_1_POS_B = 5,
		KEY_A_1_POS_BOX = 6,
		KEY_A_1_POS_DOOR = 22,
		
		KEY_A_2_POS_A = 7,
		KEY_A_2_POS_B = 8,
		KEY_A_2_POS_BOX = 9,
		KEY_A_2_POS_DOOR = 23,
		
		KEY_A_3_POS_A = 10,
		KEY_A_3_POS_B = 11,
		KEY_A_3_POS_BOX = 12,
		KEY_A_3_POS_DOOR = 24,
		
		KEY_B_1_POS_A = 13,
		KEY_B_1_POS_B = 14,
		KEY_B_1_POS_BOX = 15,
		KEY_B_1_POS_DOOR = 25,
		
		KEY_B_2_POS_A = 16,
		KEY_B_2_POS_B = 17,
		KEY_B_2_POS_BOX = 18,
		KEY_B_2_POS_DOOR = 26,
		
		KEY_B_3_POS_A = 19,
		KEY_B_3_POS_B = 20,
		KEY_B_3_POS_BOX = 21,
		KEY_B_3_POS_DOOR = 27,
		
		## Colours of the wind.
		WIND_PUZZLE_SOLVED = 28,
		
		## Biome puzzle.
		BIOME_PUZZLE_SOLVED = 31,
		
		## Finale States
		FINALE_PLAYER_GIVEN_WARNING = 29,
		GAME_OVER = 30,
		
		## Customisation
		PLAYER_A_TOOL_HAMMER = 32,
		PLAYER_A_TOOL_SCREWDRIVER = 33,
		PLAYER_A_TOOL_PISTOL = 34,
		PLAYER_A_TOOL_PAINTBRUSH = 35,
		
		PLAYER_A_MOUTH_SMILE = 36,
		PLAYER_A_MOUTH_OPEN = 37,
		
		PLAYER_A_HAIR_PONYTAIL = 38,
		
		PLAYER_A_HAT_BOWLER = 39,
		PLAYER_A_HAT_FEZ = 40,
		PLAYER_A_HAT_HELMET = 41,
		
		PLAYER_A_FACE_BEARD = 42,
		PLAYER_A_FACE_MOUSTACHE = 43,
		
		## NOTE: Auto-reserved 44 through 55 (inclusive) for PLAYER_B customs.
		# So any next state should be 56.
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


export var is_ai_state = false

## Local state:

# The player controlled in this game.
var _my_player : int = PLAYER.INVALID_PLAYER

# The most recent code to be communicated to the other player.
var _my_last_output_code := '(no code)'

var _is_local_coop : bool = false
var _has_seen_introduction_a := false
var _has_seen_in_room_intro_a := false
var _has_seen_introduction_b := false
var _has_seen_in_room_intro_b := false

# Codes I  used and am not allowed to enter or output again.
var my_input_codes = []
var my_output_codes = []

## Volatile states:

# Whether the player can start a new interaction or not.
var interaction_is_frozen := false

# From which direction the player enters the room.
# Negative number leaves the player alone.
var entering_from_direction : int = -1


var opening_dialogue_is_outro := false
var final_room_replay := false

var last_input_code : String = ".|.Nothing.here.|."



func reset_for_new_game():
	interaction_is_frozen = false
	entering_from_direction = -1
	_has_seen_in_room_intro_a = false
	_has_seen_introduction_a = false
	_has_seen_in_room_intro_b = false
	_has_seen_introduction_b = false
	opening_dialogue_is_outro = false
	final_room_replay = false
	_my_last_output_code = '(no code)'
	_my_player = PLAYER.INVALID_PLAYER
	_is_local_coop = false
	my_input_codes = []
	my_output_codes = []
	_save_local_data()
	clear_state()

func custom_tool(player : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	if get_state(STATE.PLAYER_A_TOOL_HAMMER + offset):
		return PlayerRig.TOOL.HAMMER
	if get_state(STATE.PLAYER_A_TOOL_SCREWDRIVER + offset):
		return PlayerRig.TOOL.SCREWDRIVER
	if get_state(STATE.PLAYER_A_TOOL_PISTOL + offset):
		return PlayerRig.TOOL.PISTOL
	if get_state(STATE.PLAYER_A_TOOL_PAINTBRUSH + offset):
		return PlayerRig.TOOL.PAINTBRUSH
	return PlayerRig.TOOL.NONE

func set_custom_tool(player : int, value : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	set_state(STATE.PLAYER_A_TOOL_HAMMER + offset, value == PlayerRig.TOOL.HAMMER)
	set_state(STATE.PLAYER_A_TOOL_SCREWDRIVER + offset, value == PlayerRig.TOOL.SCREWDRIVER)
	set_state(STATE.PLAYER_A_TOOL_PISTOL + offset, value == PlayerRig.TOOL.PISTOL)
	set_state(STATE.PLAYER_A_TOOL_PAINTBRUSH + offset, value == PlayerRig.TOOL.PAINTBRUSH)


func custom_mouth(player : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	if get_state(STATE.PLAYER_A_MOUTH_SMILE + offset):
		return PlayerRig.MOUTH.SMILE
	if get_state(STATE.PLAYER_A_MOUTH_OPEN + offset):
		return PlayerRig.MOUTH.OPEN
	return PlayerRig.MOUTH.FROWN

func set_custom_mouth(player : int, value : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	set_state(STATE.PLAYER_A_MOUTH_SMILE + offset, value == PlayerRig.MOUTH.SMILE)
	set_state(STATE.PLAYER_A_MOUTH_OPEN + offset, value == PlayerRig.MOUTH.OPEN)

func custom_hair(player : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	if get_state(STATE.PLAYER_A_HAIR_PONYTAIL + offset):
		return PlayerRig.HAIR.PONYTAIL
	return PlayerRig.HAIR.DOWN

func set_custom_hair(player : int, value : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	set_state(STATE.PLAYER_A_HAIR_PONYTAIL + offset, value == PlayerRig.HAIR.PONYTAIL)

func custom_hat(player : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	if get_state(STATE.PLAYER_A_HAT_BOWLER + offset):
		return PlayerRig.HAT.BOWLER
	if get_state(STATE.PLAYER_A_HAT_FEZ + offset):
		return PlayerRig.HAT.FEZ
	if get_state(STATE.PLAYER_A_HAT_HELMET + offset):
		return PlayerRig.HAT.HELMET
	return PlayerRig.HAT.NONE

func set_custom_hat(player : int, value : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	set_state(STATE.PLAYER_A_HAT_BOWLER + offset, value == PlayerRig.HAT.BOWLER)
	set_state(STATE.PLAYER_A_HAT_FEZ + offset, value == PlayerRig.HAT.FEZ)
	set_state(STATE.PLAYER_A_HAT_HELMET + offset, value == PlayerRig.HAT.HELMET)

func custom_face(player : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	if get_state(STATE.PLAYER_A_FACE_BEARD + offset):
		return PlayerRig.FACE.BEARD
	if get_state(STATE.PLAYER_A_FACE_MOUSTACHE + offset):
		return PlayerRig.FACE.MOUSTACHE
	return PlayerRig.FACE.NONE

func set_custom_face(player : int, value : int):
	var offset = 12 if player == PLAYER.PLAYER_B else 0
	set_state(STATE.PLAYER_A_FACE_BEARD + offset, value == PlayerRig.FACE.BEARD)
	set_state(STATE.PLAYER_A_FACE_MOUSTACHE + offset, value == PlayerRig.FACE.MOUSTACHE)

# Get the current player.
func current_player() -> int:
	if _my_player == PLAYER.INVALID_PLAYER:
		_load_local_data()
	return _my_player


# Set the current player.
func set_current_player(player : int) -> void:
	_my_player = player
	_save_local_data()


func is_local_coop() -> bool:
	_load_local_data()
	return _is_local_coop


func set_coop_mode(mode : bool) -> void:
	_is_local_coop = mode
	_save_local_data()


func add_input_code(code : String):
	my_input_codes.append(code)
	_save_local_data()


func add_output_code(code : String):
	my_output_codes.append(code)
	_save_local_data()

# Get the most recent code that has to be communicated to the other player.
func last_output_code() -> String:
	_load_local_data()
	return _my_last_output_code


# Set the most recent code to be communicated.
func set_last_output_code(code : String) -> void:
	_my_last_output_code = code
	_save_local_data()

func has_seen_in_room_intro():
	_load_local_data()
	if _my_player == PLAYER.PLAYER_A:
		return _has_seen_in_room_intro_a
	else:
		return _has_seen_in_room_intro_b

func set_has_seen_in_room_intro(value : bool) -> void:
	if _my_player == PLAYER.PLAYER_A:
		_has_seen_in_room_intro_a = value
	else:
		_has_seen_in_room_intro_b = value
	_save_local_data()
	
func has_seen_introduction():
	_load_local_data()
	if _my_player == PLAYER.PLAYER_A:
		return _has_seen_introduction_a
	else:
		return _has_seen_introduction_b
	
	
func set_has_seen_introduction(value : bool) -> void:
	if _my_player == PLAYER.PLAYER_A:
		_has_seen_introduction_a = value
	else:
		_has_seen_introduction_b = value
	_save_local_data()


const save_file = 'user://save_game_state.save'

# Save data local to the player.
func _save_local_data():
	var save_dict = {
		"my_player" : _my_player,
		"my_last_output_code": _my_last_output_code,
		"is_local_coop": _is_local_coop,
		"has_seen_introduction_a": _has_seen_introduction_a,
		"has_seen_introduction_b": _has_seen_introduction_b,
		"has_seen_in_room_intro_a": _has_seen_in_room_intro_a,
		"has_seen_in_room_intro_b": _has_seen_in_room_intro_b,
		"my_input_codes" : my_input_codes,
		"my_output_codes" : my_output_codes,
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
	if saved_data.has("is_local_coop"):
		_is_local_coop = saved_data["is_local_coop"]
	if saved_data.has("has_seen_introduction_a"):
		_has_seen_introduction_a = saved_data["has_seen_introduction_a"]
		_has_seen_introduction_b = saved_data["has_seen_introduction_b"]
		_has_seen_in_room_intro_a = saved_data["has_seen_in_room_intro_a"]
		_has_seen_in_room_intro_b = saved_data["has_seen_in_room_intro_b"]
	if saved_data.has("my_input_codes"):
		my_input_codes = saved_data["my_input_codes"]
		my_output_codes = saved_data["my_output_codes"]
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
	# Keep your character's customisation.
	var new_state = []
	var offset = 12 if current_player() == PLAYER.PLAYER_B else 0
	for i in range(STATE.PLAYER_A_TOOL_HAMMER + offset, STATE.PLAYER_A_TOOL_HAMMER + offset + 12):
		if state.has(i):
			new_state.append(i)
	state = new_state


# Auxiliary function for serialization.
func _get_highest_enum():
	var enum_values = STATE.values()
	enum_values.sort()
	return enum_values[-1]

func pbd(txt, bytes):
	print(txt + ' ', bytes.size(), ' ', _bytes_to_string(bytes))
	


# Serializes the state to a hexadecimal string.
func serialize() -> String:
	randomize()
	while true:
		var by_a = current_player() == PLAYER.PLAYER_A
		if is_ai_state:
			by_a = not by_a
		set_state(STATE.CODE_CREATED_BY_PLAYER_A, by_a)
		var bytes = _state_as_bytes()	
		bytes = _add_integrity_check(bytes)
		bytes = _add_player_xor(bytes)
		bytes = _add_rot_noise(bytes)
		bytes = _add_shift_noise(bytes)
		var code = _bytes_to_string(bytes)
		if not my_output_codes.has(code):
			add_output_code(code)
			return code
	return "error."


enum ERROR_CODE {
		OK = 0,
		INVALID_ENCODING = 1,
		OTHER_PLAYER_CODE = 2,
	}


# Overwrites the current state with the provided serialized state.
func deserialize(serialized_state : String) -> int:
	var bytes = _string_to_bytes(serialized_state)
	if bytes.size() < 2:
		return ERROR_CODE.INVALID_ENCODING
	bytes = _remove_shift_noise(bytes)
	if bytes.size() < 2:
		return ERROR_CODE.INVALID_ENCODING
	bytes = _remove_rot_noise(bytes)
	if bytes.size() < 2:
		return ERROR_CODE.INVALID_ENCODING
	bytes = _remove_player_xor(bytes)
	if bytes.size() < 2:
		return ERROR_CODE.INVALID_ENCODING
	if not _check_integrity_byte(bytes):
		return ERROR_CODE.INVALID_ENCODING
	bytes = _remove_integrity_byte(bytes)
	_bytes_to_state(bytes)

	var code_by_a = get_state(STATE.CODE_CREATED_BY_PLAYER_A)
	var player_is_a = current_player() == PLAYER.PLAYER_A
	if not is_ai_state and code_by_a == player_is_a:
		return ERROR_CODE.OTHER_PLAYER_CODE

	return ERROR_CODE.OK



func _state_as_bytes() -> PoolByteArray:
	var bytes = PoolByteArray([])
	var highest_enum = _get_highest_enum()
	var byte : int = 0
	for enum_value in range(8 * int(ceil(highest_enum / 8.0))):
		if get_state(enum_value):
			byte += 1 << (enum_value % 8)
		if (enum_value + 1) % 8 == 0:
			bytes.append(byte)
			byte = 0
	return bytes


func _bytes_to_state(bytes : PoolByteArray) -> void:
	clear_state()
	var highest_enum = _get_highest_enum()
	for byte_i in range(bytes.size()):
		var byte = bytes[byte_i]
		for i in range(8):
			var enum_index = byte_i * 8 + i
			if enum_index > highest_enum:
				return
			if byte & (1 << i):
				set_state(enum_index, true)


func _compute_integrity_byte(bytes : PoolByteArray) -> int:
	var check_byte : int = 0
	for byte in bytes:
		check_byte = check_byte ^ byte
	return check_byte


func _add_integrity_check(bytes : PoolByteArray) -> PoolByteArray:
	bytes.append(_compute_integrity_byte(bytes))
	return bytes


func _drop_last_byte(bytes : PoolByteArray) -> PoolByteArray:
	return bytes.subarray(0, bytes.size() - 2)

func _check_integrity_byte(bytes : PoolByteArray) -> bool:
	var check_byte = _compute_integrity_byte(_drop_last_byte(bytes))
	return check_byte == bytes[-1]


func _remove_integrity_byte(bytes : PoolByteArray) -> PoolByteArray:
	return bytes.subarray(0, bytes.size() - 2)


const xor_a = "VerySuperSecretCodeThatIsLongEnoughToEncryptSomethingWith"
const xor_b = "AnotherButVeryDifferentSecretCodeThatWeUseToEncryptStuff"

func _add_player_xor(bytes : PoolByteArray) -> PoolByteArray:
	var xor_text = xor_a if current_player() == PLAYER.PLAYER_A else xor_b
	var xor_bytes = xor_text.to_ascii()
	for i in range(bytes.size()):
		bytes[i] = bytes[i] ^ xor_bytes[i % xor_bytes.size()]
	var xor_token = (randi() * 2) % 254  # Random even value between [0, 254].
	if current_player() == PLAYER.PLAYER_B:
		xor_token += 1  # Make the value odd.
	bytes.append(xor_token)
	return bytes


func _remove_player_xor(bytes : PoolByteArray) -> PoolByteArray:
	var xor_byte = bytes[-1]
	var xor_text = xor_a if xor_byte % 2 == 0 else xor_b
	var xor_bytes = xor_text.to_ascii()
	var remainder = _drop_last_byte(bytes)
	for i in range(remainder.size()):
		remainder[i] = remainder[i] ^ xor_bytes[i % xor_bytes.size()]
	return remainder


func _add_rot_noise(bytes : PoolByteArray) -> PoolByteArray:
	var random_rot = randi() % 255
	for i in range(bytes.size()):
		bytes[i] = bytes[i] ^ random_rot
	bytes.append(random_rot)
	return bytes


func _remove_rot_noise(bytes : PoolByteArray) -> PoolByteArray:
	var random_rot = bytes[-1]
	var result = PoolByteArray()
	for i in range(bytes.size() - 1):
		result.append(bytes[i] ^ random_rot)
	return result


func _add_shift_noise(bytes : PoolByteArray) -> PoolByteArray:
	var random_shift = randi() % bytes.size()
	var shifted_bytes = PoolByteArray()
	for i in range(bytes.size()):
		shifted_bytes.append(bytes[(i + random_shift) % bytes.size()])
	shifted_bytes.append(random_shift)
	return shifted_bytes


func _remove_shift_noise(bytes : PoolByteArray) -> PoolByteArray:
	var random_shift = bytes[-1]
	var remainder = _drop_last_byte(bytes)
	var shifted_bytes = PoolByteArray()
	shifted_bytes.append_array(remainder)
	var nbytes = remainder.size()
	for i in range(nbytes):
		shifted_bytes[i] = remainder[(i - random_shift) % nbytes]
	return shifted_bytes


func _bytes_to_string(bytes : PoolByteArray) -> String:
	return Marshalls.raw_to_base64(bytes)


func _string_to_bytes(string : String) -> PoolByteArray:
	return Marshalls.base64_to_raw(string)

