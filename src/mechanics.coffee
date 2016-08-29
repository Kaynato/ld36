# 1B

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

