extends LineEdit

# NOTE: This node uses res://menus/LineEditJS/javascript_mobile.gd loaded as a
# singleton in order to work.

# warning-ignore:unused_class_variable
# This is the line that shows in the prompt to enter text, if it is editable.
export var instruction : String = ""

# Essentially if it is being played on desktop, it behaves no differently than
# a normal LineEdit node
func _ready():
	if $"/root/JavaScriptMobile".javascript: # and $"/root/JavaScriptMobile".mobile:
		if editable:
			# warning-ignore:return_value_discarded
			connect("focus_entered", self, "js_text_entry")
		else:
			# warning-ignore:return_value_discarded
			connect("focus_entered", self, "js_clipboard")

# Credit to u/MrMinimal for the help with JavaScript function calls in Godot:
# https://www.reddit.com/r/godot/comments/ep6puz/virtual_keyboard_workaround_in_html5/fehkzzz/
func js_text_entry():
	text = JavaScript.eval(
			"prompt('%s', '%s');" % [instruction, text], 
			true
			)
	
	release_focus()

# https://techoverflow.net/2018/03/30/copying-strings-to-the-clipboard-using-pure-javascript/
func js_clipboard():
	JavaScript.eval(
			"""
			// Create new element
			var el = document.createElement('textarea');
			// Set value (string to be copied)
			el.value = '""" + text + """';
			// Set non-editable to avoid focus and move outside of view
			el.setAttribute('readonly', '');
			el.style = {position: 'absolute', left: '-9999px'};
			document.body.appendChild(el);
			// Select text inside element
			el.select();
			// Copy text to clipboard
			document.execCommand('copy');
			// Remove temporary element
			document.body.removeChild(el);
			""", 
			true
			)
	
	JavaScript.eval(
			"window.alert('\"" + text + "\" copied to clipboard.');",
			true
			)
	
	release_focus()