# 1
# Remove~
Array::remove = (o) ->
	if this.indexOf(o) >= 0 then this.splice this.indexOf(o), 1
	else console.error "Element not in array!"

Math.randInt = (min, max) ->
	min + Math.floor(Math.random()*(max-min+1))

# SET CONTEXT
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
		backWallColor: new Color 0, 0, 0, 0.2
		inletColor: new Color 0, 0, 1, 0.5
		outletColor: new Color 1, 0, 0, 0.5
		wallWidth: 2
		wallPermaColor: new Color 0.5, 0, 0
		liquidColor: new Color 0, 0.3, 0.9, 0.5
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

# takes in coordinate array [x y]
coordToPix = (coord) ->
	if !Number.isNaN coord[0]
		return [
			coord[0] * setting.game.gridInterval
			coord[1] * setting.game.gridInterval
		]
	else if !Number.isNaN coord.x
		return [
			coord.x * setting.game.gridInterval
			coord.y * setting.game.gridInterval
		]
	else
		console.err "Attempted to transform #{coord} from grid coordinates into pixels, but failed!"

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

Layers.background.activate()# 1B

# Hard mechanics and gameplay

# utils
GridUtil = 
	onStage: (x,y) ->
		x >= 0 and x < Game.currStage.grid.length and y >= 0 and y < Game.currStage.grid[0].length
	hasElem: (x, y, elem, xoff = 0, yoff = 0) ->
		Game.currStage.grid[x+xoff][y+yoff][elem]?
	exhaustIfPossible: (tile) ->
		if tile.hole? and tile.hole.type is -1
			tile.hole.ticker.push Game.currStage.tick

	# i'll fix this someday, maybe set pararms and call paramless functions
	## TODO liq tail
	## TODO DRAW
	## TODO WEDGE 
	## TODO WATER INTERACTION
	flowD: (liq, tile, grid, x, y) ->
		@trail tile
		if !@onStage x, y+1 then return console.err "tile out of bounds!"
		grid[x][y + 1].liq = liq
		liq.segm.curr[2].point.y += game.setting.gridInterval
		liq.segm.curr[3].point.y += game.setting.gridInterval
		liq.dir = 0
	flowL: (liq, tile, grid, x, y) ->
		@trail tile
		if !@onStage x-1, y then return console.err "tile out of bounds!"
		grid[x-1][y].liq = liq
		liq.dir = 1
		liq.segm.curr[0].point.x -= game.setting.gridInterval
		liq.segm.curr[3].point.x -= game.setting.gridInterval
	flowR: (liq, tile, grid, x, y) ->
		@trail tile
		if !@onStage x+1, y then return console.err "tile out of bounds!"
		grid[x+1][y].liq = liq
		liq.dir = 2
		liq.segm.curr[1].point.x += game.setting.gridInterval
		liq.segm.curr[2].point.x += game.setting.gridInterval
	flowLD: (liq, tile, grid, x, y) ->
		@trail tile
		if !@onStage x-1, y then return console.err "tile out of bounds!"
		if !@onStage x-1, y+1 then return console.err "tile out of bounds!"
		grid[x-1][y+1].liq = liq
		liq.dir = 1
	flowLR: (liq, tile, grid, x, y) ->
		@trail tile
		if !@onStage x+1, y then return console.err "tile out of bounds!"
		if !@onStage x+1, y+1 then return console.err "tile out of bounds!"
		grid[x+1][y+1].liq = liq
		liq.dir = 2

	##
	# leave a trail and move water away
	stopFlow: (liq, tile, array, index) ->
		# remove 'n such'
		@trail tile
		array.splice index, 1
	trail: (tile) ->
		tile.trail = true
		tile.liq = null


	
# Mechanical objects
Mech =
	enable: false
	# side walls
	# wall: (@dir) ->
	# // redundant
	#
	##
	# type -
	#   1: inlet
	#  -1: outlet
	hole: (type, label, x, y) ->
		Layers.holes.activate()
		hole = new Path.Circle
			center: do ->
				R = coordToPix [x, y]
				R[0] += setting.game.gridInterval //2
				R[1] += setting.game.gridInterval //2
				return R
			radius: (setting.game.gridInterval * 2) // 5
			fillColor: if type is 1 then setting.game.inletColor else setting.game.outletColor
			visible: false
		hole.type = type
		hole.label = label
		hole.x = x
		hole.y = y
		hole.ticker = []
		console.log "generated #{if hole.type is 1 then 'inlet' else 'outlet'} \'#{label}\' at #{hole.x}, #{hole.y}"
		return hole
	cover: ->
	wedge: (@dir) ->
	splitter: ->
	rope: (@dir) ->
	gate: (@dir) ->
	wheel: ->
	# calculate all liquid flows.
	# exhaust/move, spawn
	tick: ->
		Game.currStage.tick++
		# for every active liquid head tile and tail tile consider the square which it is on
		Game.currStage.liq.forEach (liq,i,a) ->
			tile = Game.currStage.grid[liq.x][liq.y]

			# slants?
			if tile.Z then liq.dir = 1
			if tile.Y then liq.dir = 2

			# straight down
			if liq.dir is 0
				# tile beneath
				if tile.D
					# both left
					if !tile.L and !tile.Z
						GridUtil.flowL liq, tile, Game.currStage.grid, x, y
					# right
					if !tile.R and !tile.Y
						GridUtil.flowR liq, tile, Game.currStage.grid, x, y
					# grotto and hole
					if tile.L and tile.R and !tile.Z and !tile.Y
						GridUtil.exhaustIfPossible tile
					# then eliminate on this tile
					Grid.Util.stopFlow liq, tile, a, i
				# no tile beneath
				else 
					GridUtil.flowD liq, tile, Game.currStage.grid, x, y

			# LD - can affect motion
			else if liq.dir is 1
				# left open
				if !tile.L and !tile.Y
					if !Game.currStage.grid[liq.x - 1][liq.y].D
						GridUtil.flowLD liq, tile, Game.currStage.grid, x, y
					else
						GridUtil.flowL liq, tile, Game.currStage.grid, x, y
				# left closed but bottom open
				else if !tile.D and !tile.Z and !tile.Y
					GridUtil.flowD liq, tile, Game.currStage.grid, x, y
				# left closed bottom closed right open
				else if !tile.R and !tile.Z
					GridUtil.flowR liq, tile, Game.currStage.grid, x, y
				# grotto
				else 
					GridUtil.exhaustIfPossible tile
				# leave a trail and move water away
				GridUtil.stopFlow liq, tile, a, i

			# RD - can affect motion
			else if liq.dir is 2
				# right open
				if !tile.R and !tile.Z
					if !Game.currStage.grid[liq.x + 1][liq.y].D
						GridUtil.flowRD liq, tile, Game.currStage.grid, x, y
					else
						GridUtil.flowR liq, tile, Game.currStage.grid, x, y
				# right closed but bottom open
				else if !tile.D and !tile.Z and !tile.Y
					GridUtil.flowD liq, tile, Game.currStage.grid, x, y
				# right closed bottom closed right open
				else if !tile.L and !tile.Y
					GridUtil.flowL liq, tile, Game.currStage.grid, x, y
				# grotto
				else 
					GridUtil.exhaustIfPossible tile
				# leave a trail and move water away
				GridUtil.stopFlow liq, tile, a, i

		# for every hole in the stage check the tile to spawn
		Game.currStage.holes.forEach (hole,i,a) ->
			tile = Game.currStage.grid[hole.x][hole.y]
			# spawn if no liquid and no trail
			if !tile.liq? and !tile.trail and hole.type is 1
				tile.liq = new Liq 1, hole.x, hole.y

		console.log "advanced hydraulics simulation"
		return

# tile can include:
#
# UDLR YZ - walls. Y and Z are respectively \ and /
# 	values:
# 		0 none
# 		1 placed
# 		2 permanent
# 
# TODO : walls are by BITWISE
# 
# 
# holes. important
# 
# cover
# 
# liquid head (liq)
# trail (lir)
# liquid tail (lit)
# 
# rope
# gates or wheels


# create new magical liquid
# magical liquid - head and trail are different
# directions:
# 5 7 6
# 3 8 4
# 1 0 2
#
# types:
#	1: head - moves normally and also interacts, leaves trail
#  -1: tail - moves normally but doesn't interact, clears trail
#
# TODO liq and trails should be different
#
Liq = (type, x, y) ->
	liq =
		dir: 0
		type: type
	# array order: top left, top right, bottom right, bottom left
	liq.segm =
		origin: [
			new Segment coordToPix [x, y]
			new Segment coordToPix [x+1, y]
			new Segment coordToPix [x+1, y+1]
			new Segment coordToPix [x, y+1]
		]
	# new liquid current is same as original, but should have same references
	liq.segm.curr = [
		liq.segm.origin[0]
		liq.segm.origin[1]
		liq.segm.origin[2]
		liq.segm.origin[3]
	]
	liq.path = do ->
		Layers.liquid.activate()
		p = new Path
			segments: liq.segm.origin
			fillColor: setting.game.liquidColor

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
		Timers.add timer
		return
	tile: -> {}
	# generate a stage that ought to have the grid 'n all that, etc
	#
	# height - tiles of height
	# width - tiles of width
	# holes - array of
	#   [HOLETYPE, ID, X, Y]
	#
	#

	stage: (name, height, width, holes) ->
		console.log "generating stage #{name}"
		# independent inits
		stage =
			tick: 0
			name: name
			height: height
			width: width
			grid: do ->
				# grid[X][Y]
				grid = []
				for x in [0..width-1]
					column = []
					for y in [0..height-1]
						# push elements of column
						column.push new generate.tile()
					grid.push column
				return grid
			# grid coords of top left square
			origin: do ->
				o = [
					(calculated.resolution[0] // 2)-(width // 2)
					(calculated.resolution[1] // 2)-(height// 2)
				]
				console.log "origin is #{o}"
				return o
			# liquid tile heads
			liq: []
			active: false
		# dep' inits
		stage.holes = do ->
			o = []
			for hole in holes
				# assign hole for each hole
				stage.grid[hole.x][hole.y].hole = hole
				# add to array
				o.push hole
			return o

		# place surrounding walls
		leftTile.L = 2 for leftTile in stage.grid[0]
		leftTile.R = 2 for leftTile in stage.grid[width - 1]
		column[0].U = 2 for column in stage.grid
		column[height - 1].D = 2 for column in stage.grid

		stage.activate = ->
				if @active
					console.log "stage #{name} already active!"
					return false
				@active = true
				console.log "prepping stage #{name}"
				hU = -(height // 2)
				hD = height + hU
				wL = -(width // 2)
				wR = width + wL
				center = coordToPix [
					calculated.resolution[0]//2
					calculated.resolution[1]//2
				]
				console.log "stage center is #{center}"
				# courtesy of sublimetext. brute force...? unfortunately, I don't trust paperscript enough to do weird things...
				# without incurring more debug time
				Visuals.game.backWall.segments[0].point.x = center[0] + (coordToPix [wL, hU])[0]
				Visuals.game.backWall.segments[1].point.x = center[0] + (coordToPix [wR, hU])[0]
				Visuals.game.backWall.segments[2].point.x = center[0] + (coordToPix [wR, hD])[0]
				Visuals.game.backWall.segments[3].point.x = center[0] + (coordToPix [wL, hD])[0]
				Visuals.game.backWall.segments[1].point.y = center[1] + (coordToPix [wR, hU])[1]
				Visuals.game.backWall.segments[0].point.y = center[1] + (coordToPix [wL, hU])[1]
				Visuals.game.backWall.segments[2].point.y = center[1] + (coordToPix [wR, hD])[1]
				Visuals.game.backWall.segments[3].point.y = center[1] + (coordToPix [wL, hD])[1]
				Layers.backWall.visible = true
				# move holes layer accordingly
				Layers.holes.position = coordToPix @origin
				Layers.liquid.position = coordToPix @origin
				for hole in @holes
					hole.visible = true
					console.log "#{if hole.type is 1 then 'inlet' else if hole.type is -1 then 'outlet' else 'ERROR'} at #{hole.x}, #{hole.y} activated"
				# move cursor to origin
				Cursor.moveTo @origin[0], @origin[1]
				Cursor.lowerBounds = @origin
				Cursor.upperBounds = [@origin[0] + width, @origin[1] + height]
				return true
		return stage# 3
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
		backWall: do ->
			Layers.backWall.activate()
			Layers.backWall.visible = false
			return new Path
				segments: [
					[0, 0]
					[1, 0]
					[1, 1]
					[0, 1]
				]
				fillColor: setting.game.backWallColor
				strokeColor: setting.game.wallPermaColor
				strokeWidth: setting.game.wallWidth
				closed: true
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
				console.log "finished writing"
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


###

visuals for mechanics objects are in mechanics and not here

#### 4
# THE CURSE OF USING MENU.CURSOR
Menu =
	enabled: true
	cursor: 1 # preset used in further creation, unfortunately???
	err: -> console.log "Menu function not supported."
	start: ->
		Menu.enabled = false
		Scene.enabled = true
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
	# honestly I don't think I'll finish this part in time for the compo's end
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


	currStage: null

	activate: ->
		Layers.grid.visible = true
		Layers.cursor.visible = true
		Visuals.backboard.visible = true
		@currStage.activate()

	deactivate: ->
		Layers.grid.visible = false
		Layers.cursor.visible = false
		Visuals.backboard.visible = false

	# Set a stage - activate a stage
	set: (stage) ->
		@currStage = stage


# Stages
Stage =
	testing: generate.stage "testing", 5, 5, [
			new Mech.hole  1, 'input', 2, 0
			new Mech.hole -1, 'output', 2, 4
		]


Cursor =
	lowerBounds: [0, 0]
	upperBounds: calculated.resolution
	# Grid coordinate
	coordinate:
		# PROBABLY in the middle?
		[calculated.resolution[0] // 2, calculated.resolution[1] // 2]
	# in grid coordinates
	# cool sliding movement (however, coming with latency) can be implemented LATER and not NOW
	move: (x, y) ->
		for i in [0, 1]
			@coordinate[i] += (if i is 0 then x else y)
			@coordinate[i] -= (@upperBounds[i] - @lowerBounds[i]) if @coordinate[i] >= @upperBounds[i]
			@coordinate[i] += (@upperBounds[i] - @lowerBounds[i]) if @coordinate[i] < @lowerBounds[i]

		console.log "Moved cursor to position #{@coordinate}"
		Layers.cursor.position.x = setting.game.gridInterval * @coordinate[0] + (setting.game.gridInterval//2)
		Layers.cursor.position.y = setting.game.gridInterval * @coordinate[1] + (setting.game.gridInterval//2)
	# also in grid coords
	moveTo: (x, y) ->
		@move(x - @coordinate[0], y - @coordinate[1])
	up: -> @move 0, -1
	down: -> @move 0, 1
	left: -> @move -1, 0
	right: -> @move 1, 0

	currentItem: Mech.wall

	select: -> 0
	enabled: false

# 6
# Cutscene handler and container

# Scene: each scene is an array of arguments that ought to be passed to Scene.write
# if char is -1, then the Scene.wait will be on and a key must be pressed to advance.

# SCENE OBJECTS STILL MUST BE DEACTIVATED!!! Context determines KEY FUNCTION.

Scene =
	enabled: false

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
			return
		[0, "This is the canvas on which shall be created..."]
		->
			Visuals.textBox.jitter()
			Scene.advance()
			return
		[0, "The greatest invention known to the world!"]
		->
			Visuals.textBox.calm()
			Scene.advance()
			return
		[0, "Managing the waterworks of this city is too much work, so\nwhy not craft an automaton of flowing water?"]
		-> 
			Cursor.enabled = true
			Scene.advance()
			return
		[0, "First, use the arrow keys to move the cursor."]
		[2, "Not saying that the spacebar advances mechanics?"]
		[2, "The player's not even here yet, remember..."]
		[0, "..."]
		[0, "ACKNOWLEDGED."]
		->
			Mech.enabled = true
			Scene.end()
			return
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
actionKey = ['enter', 'z']
returnKey = ['escape', 'x']
proceedKey = ['space']

# KEY DOWN
onKeyDown = (event) ->
	if Menu.enabled
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
	if Scene.enabled
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
	if Mech.enabled
		if event.key in proceedKey
			Mech.tick()

# Frame event
onFrame = (event) ->
	window.time = event.time
	# Handle timers
	if Timers.list.length isnt 0
		Timers.list.forEach (x, i, a) ->
			while x.target <= event.time and x.target isnt -1
				console.log "fired timer #{x.name}"
				x.event()
				if x.repeat
					x.target += x.interval
				else
					# equivalent of setting deleted memory to null
					x.target = -1
					a.splice i, 1
			return



