# 1
# Remove~
Array::remove = (o) ->
	if this.indexOf(o) >= 0 then this.splice this.indexOf(o), 1
	else console.error "Element not in array!"

# SET CONTEXT
window.GameContext = 'menu'
window.time = 0

# Constants
setting =
	game:
		height: 480
		width: 640
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
		jitter: 2
		height: 120
		fillColor: new Color 0.1, 0.05, 0.8, 0.5
		strokeColor: new Color 0.1, 0.05, 1, 1
		faceXOffset: 20
		faceHeight: 176
		textOffset: [20, 20]
		fontSize: 20

calculated =
	facePos: do -> [
		78 + setting.textBox.berth + setting.textBox.faceXOffset
		88 + setting.game.height - setting.textBox.berth - setting.textBox.height - setting.textBox.faceHeight
	]

Backlight = do -> 
	light = new Path([
		[0, 0]
		[setting.game.width, 0]
		[setting.game.width, setting.game.height]
		[0, setting.game.height]
	])
	light.fillColor = 'white'

Timers =
	list: []
	add: (timer) ->
		console.log "Added timer '#{timer.name}'"
		@list.push timer
	remove: (name) ->
		@list.forEach (x,i,a)->
			if x.name is name
				a.splice i, 1