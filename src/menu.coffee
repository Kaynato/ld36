# 4
# THE CURSE OF USING MENU.CURSOR
menu =
	cursor: 1 # preset used in further creation
	err: -> console.log "Menu function not supported."
	start: ->
		contextTransition 'scene'
		# Turn off menu functions
		Visuals.menubg.visible = false
		for option in menu.options
			option.visible = false
		# TODO create new bg for scene?
		Scene.s1()
	continue: -> @err()
	load: -> @err()
	export: -> @err()
	settings: -> @err()
	sandbox: -> @err()
menu.m_start = generate.menuText 0, "NEW"
menu.m_continue = generate.menuText 1, "CONTINUE"
menu.m_load = generate.menuText 2, "LOAD FROM FILE"
menu.m_export = generate.menuText 3, "SAVE TO FILE"
menu.m_settings = generate.menuText 4, "SETTINGS"
menu.m_sandbox = generate.menuText 5, "SANDBOX"
menu.options = [ # kinda hacky
	menu.m_start
	menu.m_continue
	menu.m_load
	menu.m_export
	menu.m_settings
	menu.m_sandbox
	]
menu.select = (selection) ->
	switch selection
		when menu.m_start then @start()
		when menu.m_continue then @continue()
		when menu.m_load then @load()
		when menu.m_export then @export()
		when menu.m_settings then @settings()
		when menu.m_sandbox then @sandbox()