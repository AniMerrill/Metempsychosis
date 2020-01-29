extends TextEdit

# WIP, need to get ratio of window/viewport to be able to place objects

func _ready() -> void:
	if $"/root/JavaScriptMobile".javascript:
		JavaScript.eval(
				"""
				text_area = document.createElement('textarea')
				text_area.id = '""" + name + """'
				
				text_area.value = ''
				text_area.placeholder = ''
				
				text_area.style = 
					'position: absolute;\\
					top: 45%;\\
					left: 40%;\\
					width: 20%;\\
					height: 10%;\\
					color: #ffffff;\\
					background-color: #f004;\\
					border-color: #0000;\\
					maxlength: 160;\\
					resize: none;\\
					'
				
				document.body.appendChild(text_area)
				"""
				)
		
		set_process(true)
	else:
		set_process(false)


func _process(delta : float) -> void:
	if $"/root/JavaScriptMobile".javascript:
		var value = JavaScript.eval(
				"""
				var value = ''
				text_area = document.getElementById('""" + name + """')
				value = text_area.value
				""",
				true
				)
		
		text = value
		

