extends Control

export var submenu : bool = false
export (PoolStringArray) var option_names : PoolStringArray = []

var page := 0
var pages_enabled := false

var parent_menu = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:unused_variable
	var ignore = $Down.connect("pressed", self, "down_pressed")
	ignore = $Up.connect("pressed", self, "up_pressed")
	ignore = $X.connect("pressed", self, "x_pressed")
	
	ignore = $Buttons/Button0.connect("pressed", self, "option_pressed", [0])
	ignore = $Buttons/Button1.connect("pressed", self, "option_pressed", [1])
	ignore = $Buttons/Button2.connect("pressed", self, "option_pressed", [2])
	ignore = $Buttons/Button3.connect("pressed", self, "option_pressed", [3])
	ignore = $Buttons/Button4.connect("pressed", self, "option_pressed", [4])
	
	# TODO: Really need to find a way to make this congruent no matter what,
	# the solution I have now is really kind of a hack.
	if option_names.size() != $Options.get_child_count():
		print("TerminalMenu.gd : The amount of names does not match the amount of options.")
		print(name)
	
	for child in $Options.get_children():
		child.visible = false
	
	if option_names.size() > $Buttons.get_child_count():
		pages_enabled = true
	
	set_buttons()

# warning-ignore:unused_argument
func _process(delta):
	var current_index = page * $Buttons.get_child_count()
	
	for button in $Buttons.get_children():
		if button.visible && button.is_hovered():
			button.text = "> " + option_names[current_index]
		else:
			button.text = "  " + option_names[current_index]
		
		current_index += 1
		
		if current_index > option_names.size() - 1:
			break

func down_pressed() -> void:
	if pages_enabled:
		if (page + 1) * $Buttons.get_child_count() > option_names.size():
			return 
		
		page += 1
	
	set_buttons()

func up_pressed() -> void:
	if pages_enabled:
		if (page - 1) * $Buttons.get_child_count() < 0:
			return 
		
		page -= 1
	
	set_buttons()
	
func x_pressed() -> void:
	if parent_menu != null:
		visible = false
		parent_menu.set_visibility(true)

func option_pressed(value : int) -> void:
	var program = $Options.get_child((page * $Buttons.get_child_count()) + value)
	
	set_visibility(false)
	
	program.visible = true
	program.parent_menu = self

func set_buttons() -> void:
	var current_index = page * $Buttons.get_child_count()
	
	for button in $Buttons.get_children():
		button.visible = false
	
	for i in range($Buttons.get_child_count()):
		if i + current_index < option_names.size():
			get_node("Buttons/Button" + str(i)).text = "  " + option_names[i + current_index]
			get_node("Buttons/Button" + str(i)).visible = true
	
	if pages_enabled:
		if (page - 1) * $Buttons.get_child_count() < 0:
			$Up.visible = false
		else:
			$Up.visible = true
		
		if (page + 1) * $Buttons.get_child_count() > option_names.size():
			$Down.visible = false
		else:
			$Down.visible = true
	else:
		$Up.visible = false
		$Down.visible = false
	
	if submenu:
		$X.visible = true
	else:
		$X.visible = false

func set_visibility(value : bool) -> void:
	$Down.visible = value
	$Up.visible = value
	$X.visible = value
	$Buttons.visible = value
	
	set_process(value)
	
	if value:
		set_buttons()