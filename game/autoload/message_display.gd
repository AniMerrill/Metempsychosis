extends CanvasLayer
"""
Use to display a sequence of messages that the user needs to click through.

Call: MessageDisplay.display(messages)
Messages is a list of dictionaries, each with two fields:
	- avatar: name of the png file in graphics/avatars to be shown.
	- message: textual message. BB formatting is supported.

Additionally, the message can contain the special structure: {TextA|TextB}.
This will be replaced with TextA when the current player is player A, and
respectively with TextB if the current player is player B. 

NOTE: The symbols '{', '|' and '}' can exclusively be used for this purpose.
"""


signal messages_finished

var current_index = 0
var current_messages = []

onready var container = $Container
onready var avatar_sprite = $Container/Overlay/AvatarBG/Sprite
onready var avatar_label = $Container/Overlay/AvatarLabel
onready var message_label = $Container/Overlay/MessageContainer/MessageLabel

onready var current_y_position : float = $Container/Overlay.rect_position.y 


func _ready():
	container.visible = false


func _input(_event):
	if Input.is_action_just_pressed("click"):
		_next_message()


func display(messages, bottom := false) -> void:
	if bottom:
		$Container/Overlay.rect_position.y = 200
	else:
		$Container/Overlay.rect_position.y = current_y_position
	
	current_messages = messages
	current_index = 0
	_next_message()


# Replace all {TextA|TextB} substrings with either TextA or TextB depending on
# which player is currently playing.
func format_player_values(text : String) -> String:
	var regex = RegEx.new()
	regex.compile("\\{([^|]*)\\|([^}]*)\\}")
	for result in regex.search_all(text):
		var new_value = "ERROR"
		match GameState.current_player():
			GameState.PLAYER.PLAYER_A:
				new_value = result.get_string(1)
			GameState.PLAYER.PLAYER_B:
				new_value = result.get_string(2)
		new_value = "[b][color=#a00060]" + new_value + "[/color][/b]"
		text = text.replace(result.get_string(), new_value)
	return text


func _next_message() -> void:
	if current_index >= current_messages.size():
		container.visible = false
		emit_signal("messages_finished")
		return
	var avatar = current_messages[current_index]['avatar']
	var bb_text = current_messages[current_index]['message']
	current_index += 1
	avatar_sprite.texture = load('res://graphics/avatars/' + avatar + '.png')
	message_label.bbcode_text = "[color=#202020]" + format_player_values(bb_text) + "[/color]"
	container.visible = true

