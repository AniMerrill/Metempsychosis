extends GameObject

signal clicked()

func _on_click():
	emit_signal("clicked")
