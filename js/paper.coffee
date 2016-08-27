menubg = new Raster "menubg"
menubg.position = view.center

format =
	menu:
		xpos: 620
		xSelectOffset: 30
		ypos: 240
		yint: 20
		textColor: 'black'
		fontFamily: '"Palatino Linotype", "Book Antiqua", Palatino, serif'
		justification: 'right'
		fontSize: 20

generate =
	menuText: (yoffset, content) ->
		xpos = format.menu.xpos
		# Initial offset
		preselect = yoffset is menu.cursor
		if preselect then xpos -= format.menu.xSelectOffset
		new PointText
			position: [xpos, format.menu.ypos + yoffset*format.menu.yint]
			fontFamily: format.menu.fontFamily
			justification: format.menu.justification
			fontSize: format.menu.fontSize
			textColor: format.menu.textColor
			content: content


# THE CURSE OF USING MENU.CURSOR
menu = cursor: 1 # preset used in further creation
menu.m_new = generate.menuText 0, "NEW"
menu.m_continue = generate.menuText 1, "CONTINUE"
menu.m_load = generate.menuText 2, "LOAD FROM FILE"
menu.m_export = generate.menuText 3, "SAVE TO FILE"
menu.m_settings = generate.menuText 4, "SETTINGS"
menu.m_sandbox = generate.menuText 5, "SANDBOX"
menu.options = [ # kinda hacky
	menu.m_new
	menu.m_continue
	menu.m_load
	menu.m_export
	menu.m_settings
	menu.m_sandbox
	]

# SET CONTEXT
context = menu

# KEY DOWN
onKeyDown = (event) ->
	if context is menu
		if event.key is 'down' or event.key is 'up'
			console.log "Moved menu cursor #{event.key}"
			# Unselect previous
			menu.options[menu.cursor].position.x += format.menu.xSelectOffset
			# Move cursor
			if event.key is 'down' then menu.cursor++ else menu.cursor--
			if menu.cursor >= menu.options.length
				menu.cursor %= menu.options.length
			# Select next
			menu.options[menu.cursor].position.x -= format.menu.xSelectOffset
