""" Testing the Game State code.

The tests abuse the fact that enum values are really just integers to avoid
depending on the concrete names of the enum values.
"""
extends WATTest

var game_state

func title():
	return 'Test Game State'

# Runs before each test.
func pre():
	# Make sure we always start with a fresh state.
	game_state = load('res://game_state.gd').new()

# Runs after each test.
func post():
	game_state.free()

func test_get_state_default_false():
	describe('get_state: All enums are false by default')
	asserts.is_false(game_state.get_state(1))
	asserts.is_false(game_state.get_state(1337))

func test_set_state_updates():
	describe('set_state: Updates specified enum')
	game_state.set_state(8, true)
	asserts.is_true(game_state.get_state(8))

func test_set_state_unaffected():
	describe('set_state: Does not affect other enums')
	game_state.set_state(8, true)
	asserts.is_false(game_state.get_state(7))

func test_set_state_overrides():
	describe('set_state: Overrides value')
	asserts.is_false(game_state.get_state(8))
	game_state.set_state(8, true)
	asserts.is_true(game_state.get_state(8))
	game_state.set_state(8, false)
	asserts.is_false(game_state.get_state(8))

func test_serialize_empty_state():
	describe('serialize: Serializes empty state')
	asserts.is_equal(('0x' + game_state.serialize()).hex_to_int(), 0)

func test_serialize_single_bit():
	describe('serialize: Serializes single bit')
	game_state.set_state(0, true)
	asserts.is_equal(('0x' + game_state.serialize()).hex_to_int(), 1)

func test_serialize_multiple_bits():
	describe('serialize: Serializes multiple bits')
	game_state.set_state(1, true)
	game_state.set_state(6, true)
	game_state.set_state(7, true)
	game_state.set_state(8, true)
	asserts.is_equal(('0x' + game_state.serialize()).hex_to_int(), 450)

func test_deserialize_empty_state():
	describe('deserialize: Empty state')
	game_state.deserialize('00')
	asserts.is_false(game_state.get_state(0))
	
func test_deserialize_resets_state():
	describe('deserialize: Resets state')
	game_state.set_state(0, true)
	asserts.is_true(game_state.get_state(0))
	game_state.deserialize('00')
	asserts.is_false(game_state.get_state(0))

func test_deserialize_single_bit_state():
	describe('deserialize: Reads single bit')
	game_state.deserialize('008')
	asserts.is_true(game_state.get_state(3))
	asserts.is_false(game_state.get_state(2))
	asserts.is_false(game_state.get_state(0))

func test_deserialize_multiple_bits_state():
	describe('deserialize: Reads multiple bits')
	game_state.deserialize('019')
	asserts.is_true(game_state.get_state(3))
	asserts.is_false(game_state.get_state(2))
	asserts.is_true(game_state.get_state(0))
	asserts.is_true(game_state.get_state(4))
