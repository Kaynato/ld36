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
		return stage