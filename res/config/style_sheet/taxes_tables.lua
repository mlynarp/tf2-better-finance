require "tableutil"

local ssu = require "stylesheetutil"
local rowHeight=30
local levelPadding = 30
local icon_size=15

function data()
	local result = { }
	local a = ssu.makeAdder(result)

	-- *************
	-- ** Header **
	-- *************
	a("!sHeader",
	{
		color = ssu.makeColor(220,220,220,200),
		backgroundColor = ssu.makeColor(255, 255, 255, 150),
		gravity = {-1.0 ,-1.0},
	})

	-- *************
	-- ** Level 0 **
	-- *************
	a("!sLevel0",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 50),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	-- *************
	-- ** Level 1 **
	-- *************
	a("!sLevel1",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 20),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLevel1!sButton",
	{
		padding={0,0,0,levelPadding},
	})

	a("!sLevel1!sLevelPadding",
	{
		padding={0,0,0,levelPadding + icon_size + 10},
	})

	-- *************
	-- ** Level 2 **
	-- *************
	a("!sLevel2",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 10),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLevel2!sButton",
	{
		padding={0,0,0,levelPadding * 2},
	})

	a("!sLevel2!sLevelPadding",
	{
		padding={0,0,0,levelPadding * 2 + icon_size + 10},
	})
	
	-- *************
	-- ** Level 3 **
	-- *************
	a("!sLevel3",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLevel3!sLevelPadding",
	{
		padding={0,0,0,levelPadding * 3 + icon_size + 10},
	})

	-- *************
	-- ** Other **
	-- *************
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
