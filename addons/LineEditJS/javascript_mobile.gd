extends Node

# NOTE: This node's functionality could probably be added to the GameState
# singleton but I didn't want to directly mess with the code. The purpose of
# this singleton is to detect and handle recognition of mobile devices and
# javascript prompts/queries/etc as necessary. It is mostly a way from making
# sure each of the LineEditJS nodes I created don't have to uniquely make the
# check.

# It is also possible that down the line it could be used to check for mobile so
# that certain rendering/quality options are available.

# Flag for native exports (Win, Mac, X11) which don't have javascript at all.
var javascript := false
# Flag for whether or not the game is on a mobile device (phone/tablet)
var mobile := false

func _ready():
	if OS.has_feature("JavaScript"):
		javascript = true
		
		# Mobile detection script from StackOverflow, unfortunately could not
		# get the more advanced regex function to work:
		# https://stackoverflow.com/questions/11381673/detecting-a-mobile-browser#11381730
		mobile = JavaScript.eval(
				"""
				var value;
				
				if( navigator.userAgent.match(/Android/i)
				|| navigator.userAgent.match(/webOS/i)
				|| navigator.userAgent.match(/iPhone/i)
				|| navigator.userAgent.match(/iPad/i)
				|| navigator.userAgent.match(/iPod/i)
				|| navigator.userAgent.match(/BlackBerry/i)
				|| navigator.userAgent.match(/Windows Phone/i)
				){
					value = true;
				 }
				else {
					value = false;
				}
				""",
				true
				)
