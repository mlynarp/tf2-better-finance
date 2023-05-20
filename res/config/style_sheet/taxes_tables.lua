require "tableutil"
local ssu = require "stylesheetutil"
local l0_height=30
local icon_size=15
function data()
	local result = { }
	local a = ssu.makeAdder(result)
	
	a("!Header,!Header!tableElement!Total!Label", {
		color = ssu.makeColor(240,240,240,200),
		backgroundColor = ssu.makeColor(255, 255, 255,50),
		gravity = {-1.0 ,-1.0},
		textAlignment = {1.0, .5}
	})
	a("!Subheader", {
		color = ssu.makeColor(220,220,220,200),
		backgroundColor = ssu.makeColor(255, 255, 255,35),
		gravity = {-1.0 ,-1.0},
		textAlignment = {1.0, .5}
	})
	a("!tableElement!level1, !tableElement!level2", {
		gravity = { -1.0, -1.0 },
		textAlignment = { 1.0, .5 },
		backgroundColor = ssu.makeColor(255, 255, 255,50),
	})
	-- *************
	-- ** Buttons **
	-- *************
	-- Level 0
		a("!Tax!Button!tableElement!level0",
		{
			padding={(l0_height-icon_size)/2,0,(l0_height-icon_size)/2,0},
			size={icon_size,l0_height},
			margin={0,0,0,0},
		})
	-- Level 1
		a("!Tax!Button!tableElement!level1",
		{
			padding={(l0_height-icon_size)/2,0,(l0_height-icon_size)/2,0},
			size={icon_size,l0_height},
			margin={0,0,0,0},
		})
	-- ************************
	-- ** [Level 0 Elements] **
	-- ************************
			
		-- General Coloring & Sizing 
			-- Label Column 1
			a("!Tax!tableElement!level0,!Tax!table-item!level0", {
				backgroundColor = ssu.makeColor(255, 255, 255, 15),
				size={-1,l0_height},
			})	
			
			-- odd (2/3 + 6/7)
			a("!Tax!tableElement!level0!odd,!Tax!table-item!level0", {
				backgroundColor = ssu.makeColor(255, 255, 255, 25	),
				size={-1,l0_height},
			})
			
			-- even (4/5 + 8/9)
			a("!Tax!tableElement!level0!even,!Tax!table-item!level0", {
				backgroundColor = ssu.makeColor(255, 255, 255, 15),
				size={-1,l0_height},
			})
		-- Total Items
		a("!Tax!Total!tableElement!level0",		
		{
			backgroundColor = ssu.makeColor(255, 255, 255, 15),
			padding={0,0,0,10},
			textAlignment={0,0.5},
			margin={0,0,0,0},
			size={-1,l0_height},
		})		
		-- ************************
		-- ** [Level 1 Elements] **
		-- ************************
			
			-- Label Column 1
			a("!Tax!tableElement!level1", {
				backgroundColor = ssu.makeColor(255, 255, 255, 20),
				size={-1,l0_height}
			})
			-- odd (2/3 + 6/7)
			a("!Tax!tableElement!level1!odd", {
				backgroundColor = ssu.makeColor(255, 255, 255, 30),
				size={-1,l0_height}
			})
			-- even (4/5 + 8/9)
			a("!Tax!tableElement!level1!even", {
				backgroundColor = ssu.makeColor(255, 255, 255, 15),
				size={-1,l0_height}
			})
					
			-- Total TextView Elements
			a("!Tax!Label!tableElement!level1,!Tax!tableElement!Label!level1",
			{
				backgroundColor = ssu.makeColor(255, 255, 255, 20),
				padding={00,0,0,25},
				textAlignment={0,0.5},
				margin={0,0,0,-5},
				size={-1,l0_height},
				gravity = {-1,-1}
			})
			
			-- Total Container Element
			
			a("!table-item!Tax!level1",
			{
				padding={0,0,0,0},
				textAlignment={0,0.5},
				size={-1,l0_height},
				margin={0,0,0,0},
			})
			-- Label Column 1
			a("!Tax!Total!tableElement!level1",
			{
				backgroundColor = ssu.makeColor(255, 255, 255, 20),
				padding={0,0,0,25},
				textAlignment={0,0.5},
				margin={0,0,0,0},
				size={-1,l0_height},
				gravity = {-1,-1},
			})
				-- ************************
				-- ** [Level 2 Elements] **
				-- ************************
				a("!Tax!Label!tableElement!level2",
				{
					textAlignment={0,0.5},
					padding={0,0,0,60},
				})
				-- Label Column 1
				a("!tableElement!level2", {
					backgroundColor = ssu.makeColor(20, 20, 20, 40),
				})
				-- even (4/5 + 8/9)
				a("!tableElement!level2!odd", {
					backgroundColor = ssu.makeColor(20, 20, 20, 00),
				})
				-- odd (2/3 + 6/7)
				a("!tableElement!level2!even", {
					backgroundColor = ssu.makeColor(20, 20, 20, 40),
				})
				
				
				
	-- ************************
	-- ** [Total Row Elements] **
	-- ************************
		a("!Tax!tableElement!Total", {
			backgroundColor = ssu.makeColor(255, 255, 255, 65),
			gravity={-1,-1},
			textAlignment={1,0.5}
		})
		a("!Total!tableElement!Total",{
			backgroundColor = ssu.makeColor(255, 255, 255, 65),
			gravity={-1,-1},
			textAlignment={0,0.5}
		
		})
		a("!Total!tableElement!Total!odd",{
			backgroundColor = ssu.makeColor(255, 255, 255, 75),
			gravity={-1,-1},
			textAlignment={1,0.5}
		
		})
		a("!Total!tableElement!Total!even",{
			backgroundColor = ssu.makeColor(255, 255, 255,65),
			gravity={-1,-1},
			textAlignment={1,0.5}
		
		})
		
	
	-- Settings Table
	-- [Level 0]
		-- [Label]
		a("!Setting!Label!tableElement!level0",{
			backgroundColor = ssu.makeColor(255, 255, 255, 25),
			textAlignment={0.0,0.5},
			padding={0,0,0,15},
			
		})
		a("!Setting!tableElement!level0",{
			backgroundColor = ssu.makeColor(255, 255, 255, 25),
			textAlignment={0,0.5},		
			
		})
	-- [Level 1]
		-- [Label]
		a("!table-item!Setting!Label!level1",{
			backgroundColor = ssu.makeColor(255, 255, 255, 10),
			textAlignment={0.0,0.5},
			padding={0,0,0,25},
		})
		a("!table-item!Setting!Slider!level1",{
			backgroundColor = ssu.makeColor(255, 255, 255, 10),
			textAlignment={0.0,0.5},
			
		})
		a("!SliderClass",{
			size={120,-1}
			
		})
	-- SettingsButton
		a("!SettingsButton",{
			backgroundColor = ssu.makeColor(150,150,150,150)
		})
	
	return result
end
