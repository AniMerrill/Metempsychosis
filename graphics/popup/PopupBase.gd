extends Control

func _ready():
	# warning-ignore:return_value_discarded
	$XButton.connect("pressed", self, "x_button_pressed")
	
	var bitmap = BitMap.new()
	bitmap.create($XButton.texture_normal.get_size())
	
	# Note: Also works with lower res, but obviously inaccurate
	#bitmap.create(Vector2(4, 4))
	
	for bit_y in bitmap.get_size().y:
		for bit_x in bitmap.get_size().x:
			if bit_x > bit_y:
				bitmap.set_bit(Vector2(bit_x, bit_y), true)
			else:
				bitmap.set_bit(Vector2(bit_x, bit_y), false)
	
	$XButton.texture_click_mask = bitmap

func x_button_pressed() -> void:
	queue_free()