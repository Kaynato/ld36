# 8

# Hard mechanics and gameplay

# Mechanical objects
Mech =
	# side walls
	wall: (@dir) ->
	hole: (@id) ->
	cover: ->
	wedge: (@dir) ->
	rope: (@dir) ->
	gate: (@dir) ->
	wheel: ->

Ports = []

##
# type -
#   1: inlet
#  -1: outlet
Port = (type, id)->
	port = 
		type: type
		id: id

Cursor.currentItem = Mech.wall

# create new magical liquid
# magical liquid - head and trail are different
# directions:
# 5 7 6
# 3 8 4
# 1 0 2
Liq = ->
	liq =
		dir: 8

# calculate all liquid flows
flow = ->
	# exhaust
	# flow all existing liquids
	# intake