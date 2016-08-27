# 2
# Wrapper Constructors
generate =
	raster: (id, pos, visible) ->
		r = new Raster id
		r.position = pos
		r.visible = visible
		return r

	menuText: (yoffset, content) ->
		xpos = setting.menu.xpos
		# Initial offset
		preselect = yoffset is menu.cursor
		if preselect then xpos -= setting.menu.xSelectOffset
		new PointText
			position: [xpos, setting.menu.ypos + yoffset*setting.menu.yint]
			fontFamily: setting.menu.fontFamily
			justification: setting.menu.justification
			fontSize: setting.menu.fontSize
			textColor: setting.menu.textColor
			content: content
	# sets a timer that will fire event after seconds
	timer: (name, seconds, event, repeat = false) ->
		timer = 
			name: name
			target: window.time + seconds
			interval: seconds
			event: event
			repeat: repeat
		console.log "Created timer #{timer.name} @#{window.time} > #{seconds}"
		Timers.add timer
		return