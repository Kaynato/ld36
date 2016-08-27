# 6
# Cutscene handler and container
Scene =
	# write text with character (or no character)
	write: (char, text) ->
		# clean textbox and prep writing
		Visuals.textBox.reset()
		Visuals.textBox.visible = true
		Visuals.textBox.text = text
		if !Visuals.textBox.write
			generate.timer "startWriting", setting.textBox.loadPause, ( ->
				generate.timer "writing", setting.textBox.letterPause, ( ->
					if !Visuals.textBox.type() then Timers.remove "writing"
					), true
				)
		Visuals.faces[char].visible = true
		

	s1: ->
		@write 0, "HELLO WORLD."
		@wait()


