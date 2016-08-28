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

