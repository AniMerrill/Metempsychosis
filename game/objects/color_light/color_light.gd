tool
extends GameObject

enum LightColor {
	BLUE,
	RED,
	PURPLE,
	GREEN,
}

export (LightColor) var color = LightColor.BLUE setget _set_color

func _set_color(val):
	color = val
	_update_color()

func _update_color():
	match color:
		LightColor.BLUE:
			$CanvasLayer/Color.color = Color("#640019ff")
		LightColor.RED:
			$CanvasLayer/Color.color = Color("#64ff1900")
		LightColor.PURPLE:
			$CanvasLayer/Color.color = Color("#648000ff")
		LightColor.GREEN:
			$CanvasLayer/Color.color = Color("#6419ff19")
			

func _ready():
	_update_color()

func _on_click():
	match color:
		LightColor.BLUE:
			FlashText.flash("The soft blue light emitted by the lamp makes you feel sad.")
		LightColor.RED:
			FlashText.flash("The aggressive glow of this red light makes you feel unnerved.")
		LightColor.PURPLE:
			FlashText.flash("Despite the intensity, the shade of this purple light is soothing.")
		LightColor.GREEN:
			FlashText.flash("The intense glow of this green light makes you feel sick.")
