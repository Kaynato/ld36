# 3
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

###