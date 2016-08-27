# 7
# KEY DOWN
onKeyDown = (event) ->
	if window.GameContext is 'menu'
		if event.key is 'down' or event.key is 'up'
			# Unselect previous
			menu.options[menu.cursor].position.x += setting.menu.xSelectOffset
			# Move cursor
			if event.key is 'down' then menu.cursor++ else menu.cursor--
			if menu.cursor >= menu.options.length
				menu.cursor %= menu.options.length
			if menu.cursor < 0
				menu.cursor += menu.options.length
			# Select next
			menu.options[menu.cursor].position.x -= setting.menu.xSelectOffset
		if event.key is 'enter' or event.key is 'space' or event.key is 'z'
			Game.function menu.options[menu.cursor]

# Frame event
onFrame = (event) ->
	window.time = event.time
	# Handle timers
	if Timers.list.length isnt 0
		Timers.list.forEach (x, i, a) ->
			while x.target <= event.time and x.target isnt -1
				console.log "Fired timer '#{x.name}'"
				x.event()
				if x.repeat
					x.target += x.interval
				else
					# equivalent of setting deleted memory to null
					x.target = -1
					a.splice i, 1
			return
		return
	# if Visuals.textBox.visible
		# TODO textbox jitters, I guess
		