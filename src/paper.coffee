# 1
# Remove~
Array::remove = (o) ->
	if this.indexOf(o) >= 0 then this.splice this.indexOf(o), 1
	else console.error "Element not in array!"

Math.randInt = (min, max) ->
	min + Math.floor(Math.random()*(max-min+1))

# SET CONTEXT
window.GameContext = 'menu'
window.time = 0

# Constants - SHOULD BE JSON EVENTUALLY
setting =
	game:
		height: 480
		width: 640
		gridInterval: 20
		gridColor: 'silver'
		gridWidth: 1
		cursorColor: new Color 0.9, 0.9, 0.2, 0.4
		crossRadius: 4
		crossColor: 'black'
		crossWidth: 0.8
	menu:
		xpos: 620
		xSelectOffset: 30
		ypos: 240
		yint: 20
		textColor: 'black'
		fontFamily: '"Palatino Linotype", "Book Antiqua", Palatino, serif'
		justification: 'right'
		fontSize: 20
	textBox:
		loadPause: .2
		letterPause: .05
		arrowPause: .2
		jitterSpeed: .1
		berth: 30
		jitter: 3
		height: 120
		fillColor: 'silver'
		strokeColor: 'grey'
		faceXOffset: 20
		faceHeight: 176
		textOffset: [20, 20]
		fontSize: 20

calculated =
	facePos: do -> [
		78 + setting.textBox.berth + setting.textBox.faceXOffset
		88 + setting.game.height - setting.textBox.berth - setting.textBox.height - setting.textBox.faceHeight
	]
	resolution: do ->
		R = [(setting.game.width // setting.game.gridInterval), (setting.game.height // setting.game.gridInterval)]
		console.log "Grid has resolution #{R[0]}, #{R[1]}."
		return R

Timers =
	list: []
	add: (timer) ->
		@list.push timer
	remove: (name) ->
		@list.forEach (x,i,a)->
			if x.name is name
				a.splice i, 1

contextTransition = (newContext) ->
	# Do whatever is necessary to transition to new context here
	# And then finally set context
	window.GameContext = newContext

# setup proper layering
Layers =
	backlight: new Layer()
	# BG
	background: new Layer()
	
	grid: new Layer()
	backWall: new Layer()
	holes: new Layer()
	cover: new Layer()
	liquid: new Layer()
	# Side wall or wedge
	construct: new Layer()
	rope: new Layer()
	# Gate or Wheel
	mechanism: new Layer()
	cursor: new Layer()
	# Talk
	textBox: new Layer()
	# Text Layer (includes menu)
	text: new Layer()
	# talksprite
	faces: new Layer()
	# Overlay (just in case)
	overlay: new Layer()

Layers.background.activate()
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
		preselect = yoffset is Menu.cursor
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
		return# 3
# Setup all visuals
Visuals =
	# BACKGROUND
	backlight: do ->
		Layers.backlight.activate()
		light = new Path [
			[0, 0]
			[setting.game.width, 0]
			[setting.game.width, setting.game.height]
			[0, setting.game.height]
		]
		light.fillColor = 'white'
		return light

	menubg: do ->
		Layers.background.activate()
		return generate.raster 'menubg', view.center, true

	backboard: do ->
		Layers.background.activate()
		B = generate.raster 'backboard', view.center, true
		B.visible = false
		return B
		
	game:
		# array of lines. should be behind everything, aside the background
		grid: do ->
			Layers.grid.activate()
			# layers. they're important.
			out = []
			# vertical lines
			for x in [0..setting.game.width] by setting.game.gridInterval
				out.push new Path
					segments: [[x, 0], [x, setting.game.height]]
					strokeColor: setting.game.gridColor
					strokeWidth: setting.game.gridWidth
			# horizontal lines
			for y in [0..setting.game.height] by setting.game.gridInterval
				out.push new Path
					segments: [[0, y], [setting.game.width, y]]
					strokeColor: setting.game.gridColor
					strokeWidth: setting.game.gridWidth
			Layers.grid.visible = false
			return out
	# cursor selector in game portion - set at zero so moving is done by layer
	cursor: do ->
		Layers.cursor.activate()
		# pixel position, not cursor coord position
		Layers.cursor.visible = false
		cursor = [
			# translucent square
			new Path
				segments: [
					[0, 0]
					[setting.game.gridInterval, 0]
					[setting.game.gridInterval, setting.game.gridInterval]
					[0, setting.game.gridInterval]
				]
				fillColor: setting.game.cursorColor
			# crosshair in middle
			new Path
				segments: [
					[setting.game.gridInterval/2 + setting.game.crossRadius, setting.game.gridInterval/2]
					[setting.game.gridInterval/2 - setting.game.crossRadius, setting.game.gridInterval/2]
				]
				strokeColor: setting.game.crossColor
				strokeWidth: setting.game.crossWidth
			new Path
				segments: [
					[setting.game.gridInterval/2, setting.game.gridInterval/2 + setting.game.crossRadius]
					[setting.game.gridInterval/2, setting.game.gridInterval/2 - setting.game.crossRadius]
				]
				strokeColor: setting.game.crossColor
				strokeWidth: setting.game.crossWidth
		]
		Layers.cursor.position = [
			(setting.game.gridInterval * calculated.resolution[0] // 2) + (setting.game.gridInterval//2)
			(setting.game.gridInterval * calculated.resolution[1] // 2) + (setting.game.gridInterval//2)
		]
		console.log "Cursor initialized at #{Layers.cursor.position}"
		return cursor


	# SCENE LAYER
	faces: do ->
		Layers.faces.activate()
		return [
			generate.raster 'face1', calculated.facePos, false
			generate.raster 'face2', calculated.facePos, false
			generate.raster 'face3', calculated.facePos, false
			generate.raster 'face4', calculated.facePos, false
			generate.raster 'face5', calculated.facePos, false
		]
	textBox: do ->
		Layers.textBox.activate()
		anchors = [
			[setting.textBox.berth, setting.game.height - setting.textBox.berth - setting.textBox.height]
			[setting.game.width - setting.textBox.berth, setting.game.height - setting.textBox.berth - setting.textBox.height]
			[setting.game.width - setting.textBox.berth, setting.game.height - setting.textBox.berth]
			[setting.textBox.berth, setting.game.height - setting.textBox.berth]
		]
		box = new Path(anchors)
		box.anchors = anchors
		box.closed = true
		box.fillColor = setting.textBox.fillColor
		box.strokeColor = setting.textBox.strokeColor
		box.visible = false
		box.queue = ""
		box.char = 0
		box.writing = false
		box.pointText = do ->
			Layers.text.activate()
			return new PointText
				position: [anchors[0][0] + setting.textBox.textOffset[0], anchors[0][1] + setting.textBox.textOffset[1]]
				justification: 'left'
				fontSize: setting.textBox.fontSize
				textColor: 'white'
		box.reset = ->
			@char = 0
			@queue = ""
			@pointText.content = ""
		box.type = ->
			if @char < @queue.length
				@pointText.content += @queue[@char]
				@char++
				return true
			else
				@writing = false
				return false
		box.skip = ->
			@char = @queue.length
			@pointText.content = @queue
			@writing = false
			return false
		box.jitter = ->
			if Visuals.textBox.visible
				generate.timer "textBoxJitter", setting.textBox.jitterSpeed, (->
					# textbox jitters. yep.
					Visuals.textBox.segments.forEach (seg,i,a)->
						seg.point.x = Visuals.textBox.anchors[i][0] + Math.randInt(-setting.textBox.jitter, setting.textBox.jitter)
						seg.point.y = Visuals.textBox.anchors[i][1] + Math.randInt(-setting.textBox.jitter, setting.textBox.jitter)
						return
					return), true
		box.calm = ->
			Timers.remove "textBoxJitter"
		return box
# 4
# THE CURSE OF USING MENU.CURSOR
Menu =
	cursor: 1 # preset used in further creation
	err: -> console.log "Menu function not supported."
	start: ->
		contextTransition 'scene'
		# Turn off Menu functions
		Visuals.menubg.visible = false
		for option in Menu.options
			option.visible = false
		# TODO create new bg for scene?
		Scene.set(Scene.s1)
	continue: -> @err()
	load: -> @err()
	export: -> @err()
	settings: -> @err()
	sandbox: -> @err()
Menu.m_start = generate.menuText 0, "NEW"
Menu.m_continue = generate.menuText 1, "CONTINUE"
Menu.m_load = generate.menuText 2, "LOAD FROM FILE"
Menu.m_export = generate.menuText 3, "SAVE TO FILE"
Menu.m_settings = generate.menuText 4, "SETTINGS"
Menu.m_sandbox = generate.menuText 5, "SANDBOX"
Menu.options = [ # kinda hacky
	Menu.m_start
	Menu.m_continue
	Menu.m_load
	Menu.m_export
	Menu.m_settings
	Menu.m_sandbox
	]
Menu.select = (selection) ->
	switch selection
		when Menu.m_start then @start()
		when Menu.m_continue then @continue()
		when Menu.m_load then @load()
		when Menu.m_export then @export()
		when Menu.m_settings then @settings()
		when Menu.m_sandbox then @sandbox()# 5
# Game.coffee - static game object
Game =
	
	# player info
	info:
		money: 100
		# How many things you have.
		# 
		# Special numerals:
		#
		# -1: infinite
		# -2: not unlocked
		inventory:
			wall: -1
			hole: -1
			rope: -2
			sluice: -2
			wedge: -2
			wheel: -2


	activeStage: null

	activate: ->
		Layers.grid.visible = true
		Layers.cursor.visible = true
		Visuals.backboard.visible = true

	deactivate: ->
		Layers.grid.visible = false
		Layers.cursor.visible = false
		Visuals.backboard.visible = false

	# Set a stage - activate a stage
	set: (stage) ->

		@activeStage = stage


# Stages
Stage =
	testing: 0


Cursor =
	bounds: calculated.resolution
	# Grid coordinate
	coordinate:
		# PROBABLY in the middle?
		[(setting.game.width // setting.game.gridInterval) // 2, (setting.game.height // setting.game.gridInterval) // 2]
	# in grid coordinates
	# cool sliding movement (however, coming with latency) can be implemented LATER and not NOW
	move: (x, y) ->
		@coordinate[0] += x
		if @coordinate[0] >= @bounds[0] then @coordinate[0] %= @bounds[0]
		@coordinate[0] += @bounds[0] if @coordinate[0] < 0
			
		@coordinate[1] += y
		if @coordinate[1] >= @bounds[1] then @coordinate[1] %= @bounds[1]
		@coordinate[1] += @bounds[1] if @coordinate[1] < 0
		console.log "Moved cursor to position #{@coordinate}"
		Layers.cursor.position.x = setting.game.gridInterval * @coordinate[0] + (setting.game.gridInterval//2)
		Layers.cursor.position.y = setting.game.gridInterval * @coordinate[1] + (setting.game.gridInterval//2)
	up: -> @move 0, -1
	down: -> @move 0, 1
	left: -> @move -1, 0
	right: -> @move 1, 0
	select: -> 0
	enabled: false

# 6
# Cutscene handler and container

# Scene: each scene is an array of arguments that ought to be passed to Scene.write
# if char is -1, then the Scene.wait will be on and a key must be pressed to advance.

# SCENE OBJECTS STILL MUST BE DEACTIVATED!!! Context determines KEY FUNCTION.

Scene =
	# write text with character (or no character)
	write: (char, text) ->
		# clean textbox and prep writing
		Visuals.textBox.visible = true
		Visuals.textBox.queue = text
		if !Visuals.textBox.writing
			Visuals.textBox.writing = true
			generate.timer "startWriting", setting.textBox.loadPause, ( ->
				generate.timer "writing", setting.textBox.letterPause, ( ->
					if !Visuals.textBox.type() then Timers.remove "writing"
					), true
				)
		# select face
		Visuals.faces.forEach (x,i,a) ->
			if i is char then x.visible = true else x.visible = false
			return
		return
	
	set: (scene) ->
		@activeScene = scene
		position = 0
		Visuals.textBox.visible.true
		@read()

	# for advancing the scene	
	activeScene: null
	activeFace: -1 # no face
	position: 0

	s1: [
		[0, "HELLO WORLD."]
		[1, "Yep, have fun."]
		[0, "ACKNOWLEDGED."]
		->
			# Scene.end()
			# contextTransition 'game'
			Game.set Stage.testing
			Game.activate()
			Scene.advance()
		[0, "This is the canvas on which shall be created..."]
		->
			Visuals.textBox.jitter()
			Scene.advance()
		[0, "The greatest invention known to the world!"]
		->
			Cursor.enabled = true
			Visuals.textBox.calm()
			Scene.advance()
		[0, "First, use the arrow keys to move the cursor."]
	]

	end: ->
		console.log "Scene has ended."
		Visuals.textBox.visible = false
		Visuals.faces.forEach (x,i,a) ->
			x.visible = false
			return

	read: ->
		if @activeScene[@position] instanceof Array
			@write @activeScene[@position][0], @activeScene[@position][1]
			return true
		else if @activeScene[@position] instanceof Function
			@activeScene[@position]()
			return false

	# advance the scene
	advance: ->
		console.log "Textbox is #{if !Visuals.textBox.writing then 'not' else ''} writing."
		if @activeScene?
			if !Visuals.textBox.writing
				# clear the box
				Visuals.textBox.reset()
				# advance the counter
				@position++
				# check if scene is ended - if it hasn't, continue
				if @position < @activeScene.length
					@read()
				# otherwise stop - also, a fallthrough if a weird thing was in the scene array
				else
					return false
			else
				return false# 7

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
	


