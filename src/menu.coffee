# 4
# THE CURSE OF USING MENU.CURSOR
Menu =
	cursor: 1 # preset used in further creation
	err: -> console.log "Menu function not supported."
	start: ->
		contextTransition 'scene'
		# Turn off Menu functions
		Visuals.menubg.visible = false
		for option in Menu.options
			option.visible = false
		# TODO create new bg for scene?
		Scene.set(Scene.s1)
	continue: -> @err()
	load: -> @err()
	export: -> @err()
	settings: -> @err()
	sandbox: -> @err()
Menu.m_start = generate.menuText 0, "NEW"
Menu.m_continue = generate.menuText 1, "CONTINUE"
Menu.m_load = generate.menuText 2, "LOAD FROM FILE"
Menu.m_export = generate.menuText 3, "SAVE TO FILE"
Menu.m_settings = generate.menuText 4, "SETTINGS"
Menu.m_sandbox = generate.menuText 5, "SANDBOX"
Menu.options = [ # kinda hacky
	Menu.m_start
	Menu.m_continue
	Menu.m_load
	Menu.m_export
	Menu.m_settings
	Menu.m_sandbox
	]
Menu.select = (selection) ->
	switch selection
		when Menu.m_start then @start()
		when Menu.m_continue then @continue()
		when Menu.m_load then @load()
		when Menu.m_export then @export()
		when Menu.m_settings then @settings()
		when Menu.m_sandbox then @sandbox()