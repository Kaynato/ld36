# 6
# Cutscene handler and container

# Scene: each scene is an array of arguments that ought to be passed to Scene.write
# if char is -1, then the Scene.wait will be on and a key must be pressed to advance.

# SCENE OBJECTS STILL MUST BE DEACTIVATED!!! Context determines KEY FUNCTION.

Scene =
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
		[0, "This is the canvas on which shall be created..."]
		->
			Visuals.textBox.jitter()
			Scene.advance()
		[0, "The greatest invention known to the world!"]
		->
			Cursor.enabled = true
			Visuals.textBox.calm()
			Scene.advance()
		[0, "First, use the arrow keys to move the cursor."]
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
				return false