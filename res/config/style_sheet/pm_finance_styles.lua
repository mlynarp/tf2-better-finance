require "tableutil"

local ssu = require "stylesheetutil"
local rowHeight=25
local levelPadding = 30
local icon_size=15
local textPadding = 10

function data()
	local result = { }
	local a = ssu.makeAdder(result)

	-- *************
	-- ** Header **
	-- *************
	a("!sHeader",
	{
		gravity = {-1.0 ,-1.0},
        fontSize = 15,
	})

	-- *************
	-- ** Level 0 **
	-- *************
	a("!sLevel0",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 25),
		size={-1, rowHeight + 5},
		gravity = {-1.0 ,-1.0},
	})

	-- *************
	-- ** Level 1 **
	-- *************
	a("!sLevel1",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLevel1!sButton",
	{
		padding={0,0,0,levelPadding},
	})

	a("!sLevel1!sLevelPadding",
	{
		padding={0,0,0,levelPadding + icon_size + textPadding},
	})

	-- *************
	-- ** Level 2 **
	-- *************
	a("!sLevel2",
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

	a("!sLevel2!sButton",
	{
		padding={0,0,0,levelPadding * 2},
	})

	a("!sLevel2!sLevelPadding",
	{
		padding={0,0,0,levelPadding * 2 + icon_size + textPadding},
	})

    a("!mySummaryTable",
	{
		padding = {0,0,3,0},
        size={-1, 4*rowHeight},
		gravity = {-1.0 ,-1.0},
	})

    a("!mySummaryTableLine",
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 5),
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })
    a("!mySummaryTableLineLabel",
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 5),
        padding = { 0, 0, 0, icon_size + textPadding},
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })

    a("!mySummaryTableLineTotal",
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 30),
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })

    a("!mySummaryTableLineTotalLabel",
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 30),
        padding = { 0, 0, 0, icon_size + textPadding},
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })

	-- *************
	-- ** Other **
	-- *************
	a("!sLeft",
	{
		textAlignment = {0, 0.5}
	})

	a("!sRight",
	{
		textAlignment = {1.0, 0.5}
	})

	a("!sButton",
	{
		padding={(rowHeight-icon_size)/2,0,(rowHeight-icon_size)/2,0},
		size={icon_size,rowHeight},
		margin={0,0,0,0},
	})

	return result
end
