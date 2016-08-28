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
		backWallColor: new Color 0, 0, 0, 0.2
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

Layers.background.activate()