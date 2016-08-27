# 3
# Setup rasters
Visuals =
	menubg: generate.raster 'menubg', view.center, true
	faces: [
		generate.raster 'face1', calculated.facePos, false
		generate.raster 'face2', calculated.facePos, false
		generate.raster 'face3', calculated.facePos, false
		generate.raster 'face4', calculated.facePos, false
		generate.raster 'face5', calculated.facePos, false
	]
	textBox: do ->
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
		box.text = ""
		box.char = 0
		box.write = false
		box.pointText = new PointText
			position: [anchors[0][0] + setting.textBox.textOffset[0], anchors[0][1] + setting.textBox.textOffset[1]]
			justification: 'left'
			fontSize: setting.textBox.fontSize
			textColor: 'white'
		box.reset = ->
			@char = 0
			@text = ""
			@pointText.content = ""
		box.type = ->
			if @char < @text.length
				@pointText.content += @text[@char]
				@char++
				return true
			else
				return false
		return box

contextTransition = (newContext) ->
	# Do whatever is necessary to transition to new context here
	# And then finally set context
	window.GameContent = newContext