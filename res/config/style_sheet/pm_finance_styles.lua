function ScriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

function FormatClassNames(classes)
    local result = ""
    for i, className in ipairs(classes) do
        result = result .. "!" .. className
    end
    return result
end

dofile(ScriptPath() .. "../../scripts/pm_finance_constants.lua")

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
    a(FormatClassNames({ "sHeader" }),
	{
		gravity = {-1.0 ,-1.0},
        fontSize = 15,
	})

	-- *************
	-- ** Level 0 **
	-- *************
	a(FormatClassNames({ "sLevel0" }),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 25),
		size={-1, rowHeight + 5},
		gravity = {-1.0 ,-1.0},
	})

	-- *************
	-- ** Level 1 **
	-- *************
    a(FormatClassNames({"sLevel1"}),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

    a(FormatClassNames({ "sLevel1", STYLE_BUTTON }),
	{
		padding={0,0,0,levelPadding},
	})

	a(FormatClassNames({ "sLevel1", "sLevelPadding" }),
	{
		padding={0,0,0,levelPadding + icon_size + textPadding},
	})

	-- *************
	-- ** Level 2 **
	-- *************
	a(FormatClassNames({"sLevel2"}),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
		size={-1, rowHeight},
		gravity = {-1.0 ,-1.0},
	})

    a(FormatClassNames({ "sLevel2", STYLE_BUTTON }),
	{
		padding={0,0,0,levelPadding * 2},
	})

	a(FormatClassNames({ "sLevel2", "sLevelPadding" }),
	{
		padding={0,0,0,levelPadding * 2 + icon_size + textPadding},
	})

    a(FormatClassNames({"mySummaryTable"}),
	{
		padding = {0,0,3,0},
        size={-1, 5*rowHeight},
		gravity = {-1.0 ,-1.0},
	})

    a(FormatClassNames({"mySummaryTableLine"}),
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 5),
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })
    
    a(FormatClassNames({"mySummaryTableLineLabel"}),
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 5),
        padding = { 0, 0, 0, icon_size + textPadding},
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })

    a(FormatClassNames({"mySummaryTableLineTotal"}),
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 30),
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })

    a(FormatClassNames({"mySummaryTableLineTotalLabel"}),
    {
        backgroundColor = ssu.makeColor(255, 255, 255, 30),
        padding = { 0, 0, 0, icon_size + textPadding},
		size={-1, rowHeight},
		gravity = {-1.0 ,0.5},
    })

	-- *************
	-- ** Other **
	-- *************
	a(FormatClassNames({"sLeft"}),
	{
		textAlignment = {0, 0.5}
	})

	a(FormatClassNames({"sRight"}),
	{
		textAlignment = {1.0, 0.5}
	})

    a(FormatClassNames({ STYLE_BUTTON }),
	{
		padding={(rowHeight-icon_size)/2,0,(rowHeight-icon_size)/2,0},
		size={icon_size,rowHeight},
		margin={0,0,0,0},
	})

	return result
end
