require "tableutil"
local ssu = require "stylesheetutil"
local rowHeight=30
local icon_size=15
function data()
	local result = { }
	local a = ssu.makeAdder(result)
	
	a("!sHeader",
	{
		color = ssu.makeColor(220,220,220,200),
		backgroundColor = ssu.makeColor(255, 255, 255, 150),
		gravity = {-1.0 ,-1.0},
	})
	
	a("!sLevel0",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 50),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLevel1",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 20),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLeft",
	{
		textAlignment = {0, 1.0}
	})

	a("!sRight",
	{
		textAlignment = {1.0, .5}
	})

	a("!sButton",
	{
		padding={(rowHeight-icon_size)/2,0,(rowHeight-icon_size)/2,0},
		size={icon_size,rowHeight},
		margin={0,0,0,0},
	})

	return result
end
