extends Control

###############################################################################

# HOW TO USE TERMINALS

## Create new scene with res://graphics/popup/TerminalBase as the root node
## Instance whatever screen you want under the ScreenContents node
## If you want to use a menu for the "root" of the terminal, instance this scene
## 		and make sure "Editable Children" is enabled from the scene viewer
## Add whatever option screens you want under the Options node. The name for
## 		each option is now literally the name of the node.
## You can now add a title by setting the title variable. Leave it blank if you
## 		just want all options and no title.

## If you want your terminal to have a submenu underneath the main menu (i.e
## 		the "Email" option leads to a menu with all the emails) then simply
## 		instance another TerminalMenu under the Options node and toggle the
## 		`submenu` variable to make sure it has an X button to return to the main
## 		menu.

# NOTE FOR MAKING SCREENS

# Please include the following variable and function to make them compatible
# with this menu setup. Also, preferably, add some kind of an X button that
# connects to `x_pressed()` as well
var parent_menu = null

func x_pressed() -> void:
	if parent_menu != null:
		visible = false
		parent_menu.set_visibility(true)

###############################################################################

export var title : String = ""
export var submenu : bool = false

onready var buttons = $MainDisplay/Buttons
onready var title_label = $MainDisplay/Title

var page := 0
var pages_enabled := false

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:unused_variable
	var ignore = $Down.connect("pressed", self, "down_pressed")
	ignore = $Up.connect("pressed", self, "up_pressed")
	ignore = $X.connect("pressed", self, "x_pressed")
	
	ignore = buttons.get_node("Button0").connect("pressed", self, "option_pressed", [0])
	ignore = buttons.get_node("Button1").connect("pressed", self, "option_pressed", [1])
	ignore = buttons.get_node("Button2").connect("pressed", self, "option_pressed", [2])
	ignore = buttons.get_node("Button3").connect("pressed", self, "option_pressed", [3])
	
	if title == "":
		ignore = buttons.get_node("Button4").connect("pressed", self, "option_pressed", [4])
		title_label.visible = false
	else:
		title_label.visible = true
		title_label.text = title
		buttons.get_node("Button4").queue_free()
	
	for child in $Options.get_children():
		child.visible = false
	
	if $Options.get_child_count() > buttons.get_child_count():
		pages_enabled = true
	
	set_buttons()

# warning-ignore:unused_argument
func _process(delta):
	var current_index = page * buttons.get_child_count()
	
	for button in buttons.get_children():
		if button.visible && button.is_hovered():
			button.text = "> " + $Options.get_child(current_index).name
		else:
			button.text = "  " + $Options.get_child(current_index).name
		
		current_index += 1
		
		if current_index > $Options.get_child_count() - 1:
			break

func down_pressed() -> void:
	if pages_enabled:
		if (page + 1) * buttons.get_child_count() > $Options.get_child_count():
			return 
		
		page += 1
	
	set_buttons()

func up_pressed() -> void:
	if pages_enabled:
		if (page - 1) * buttons.get_child_count() < 0:
			return 
		
		page -= 1
	
	set_buttons()

func option_pressed(value : int) -> void:
	var program = $Options.get_child((page * buttons.get_child_count()) + value)
	
	set_visibility(false)
	
	program.visible = true
	program.parent_menu = self

func set_buttons() -> void:
	var current_index = page * buttons.get_child_count()
	
	for button in buttons.get_children():
		button.visible = false
	
	for i in range(buttons.get_child_count()):
		if i + current_index < $Options.get_child_count():
			buttons.get_node("Button" + str(i)).text = "  " + $Options.get_child(i + current_index).name
			buttons.get_node("Button" + str(i)).visible = true
	
	if pages_enabled:
		if (page - 1) * buttons.get_child_count() < 0:
			$Up.visible = false
		else:
			$Up.visible = true
		
		if (page + 1) * buttons.get_child_count() >= $Options.get_child_count():
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
	$MainDisplay.visible = value
	
	set_process(value)
	
	if value:
		set_buttons()