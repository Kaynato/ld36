# 7

# probably make this configurable
actionKey = ['enter', 'space', 'z']
returnKey = ['escape', 'x']

# KEY DOWN
onKeyDown = (event) ->
	switch window.GameContext
		when 'menu'
			if event.key is 'down' or event.key is 'up'
				# Unselect previous
				Menu.options[Menu.cursor].position.x += setting.menu.xSelectOffset
				# Move cursor
				if event.key is 'down' then Menu.cursor++ else Menu.cursor--
				if Menu.cursor >= Menu.options.length
					Menu.cursor %= Menu.options.length
				if Menu.cursor < 0
					Menu.cursor += Menu.options.length
				# Select next
				Menu.options[Menu.cursor].position.x -= setting.menu.xSelectOffset
			if event.key in actionKey
				Menu.select Menu.options[Menu.cursor]
		when 'scene'
			if event.key in actionKey
				Scene.advance()
			if event.key in returnKey
				Visuals.textBox.skip()
	if Cursor.enabled
		if event.key is 'up'
			Cursor.up()
		if event.key is 'down'
			Cursor.down()
		if event.key is 'left'
			Cursor.left()
		if event.key is 'right'
			Cursor.right()

# Frame event
onFrame = (event) ->
	window.time = event.time
	# Handle timers
	if Timers.list.length isnt 0
		Timers.list.forEach (x, i, a) ->
			while x.target <= event.time and x.target isnt -1
				x.event()
				if x.repeat
					x.target += x.interval
				else
					# equivalent of setting deleted memory to null
					x.target = -1
					a.splice i, 1
			return
	


