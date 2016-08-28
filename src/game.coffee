# 5
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


	currStage: null

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

		@currStage = stage
		stage.activate()


# Stages
Stage =
	testing: generate.stage 5, 5


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

	currentItem: undefined

	select: -> 0
	enabled: false

