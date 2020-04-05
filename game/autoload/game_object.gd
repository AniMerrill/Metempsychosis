extends Node2D

signal position_reached()

# Default behaviour: Find and open the first popup.
func _on_click():
	for child in get_children():
		if _try_popup(child):
			return
		for grand_child in child.get_children():
			if _try_popup(grand_child):
				return

func _try_popup(node) -> bool:
	if node.has_method("popup"):
		GameState.interaction_is_frozen = true
		_walk_player_to_here()
		yield(self, "position_reached")
		node.popup()
		MusicModule.state_changed("puzzle")
		if not node.is_connected("closed", self, "_on_popup_closed"):
			node.connect("closed", self, "_on_popup_closed")
		return true
	return false

func _on_popup_closed():
	GameState.interaction_is_frozen = false
	MusicModule.state_changed("explore")

func _room():
	return self.find_parent("GenericRoom")

# Note: freezes interaction.
func _walk_player_to_here():
	var room = _room()
	var player = room.get_node("ControllablePlayer")
	GameState.interaction_is_frozen = true
	room.player_walk_to(self.position, true)
	yield(player, "position_reached")
	emit_signal("position_reached")
