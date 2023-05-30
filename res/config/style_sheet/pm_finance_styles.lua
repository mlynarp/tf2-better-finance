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

local ROW_HEIGHT = 25
local LEVEL_PADDING = 30
local ICON_SIZE = 15
local TEXT_PADDING = 10

local ssu = require "stylesheetutil"
function data()
	local result = { }
	local a = ssu.makeAdder(result)

    a(FormatClassNames({ STYLE_TABLE_HEADER }),
	{
		gravity = {-1.0 ,-1.0},
        fontSize = 15,
	})

    a(FormatClassNames({ STYLE_TABLE_CELL }),
	{
		gravity = {-1.0 ,-1.0},
        size = { -1, ROW_HEIGHT },
        textAlignment = { 0.5, 0.5 }
	})

    a(FormatClassNames({ STYLE_LEVEL_0 }),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 25),
		size={-1, ROW_HEIGHT + 5},
	})

    a(FormatClassNames({STYLE_LEVEL_1}),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
	})

    a(FormatClassNames({ STYLE_LEVEL_1, STYLE_BUTTON }),
	{
		padding={0,0,0,LEVEL_PADDING},
	})

	a(FormatClassNames({ STYLE_LEVEL_1, STYLE_LEVEL_PADDING }),
	{
		padding={0,0,0,LEVEL_PADDING + ICON_SIZE + TEXT_PADDING},
	})

	a(FormatClassNames({STYLE_LEVEL_2}),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 0),
		size={-1, ROW_HEIGHT},
		gravity = {-1.0 ,-1.0},
	})

    a(FormatClassNames({ STYLE_LEVEL_2, STYLE_BUTTON }),
	{
		padding={0,0,0,LEVEL_PADDING * 2},
	})

	a(FormatClassNames({ STYLE_LEVEL_2, STYLE_LEVEL_PADDING }),
	{
		padding={0,0,0,LEVEL_PADDING * 2 + ICON_SIZE + TEXT_PADDING},
	})

    a(FormatClassNames({"mySummaryTable"}),
	{
		padding = {0,0,3,0},
        size={-1, 5*ROW_HEIGHT + 5},
		gravity = {-1.0 ,-1.0},
	})

    a(FormatClassNames({ STYLE_SUMMARY_LABEL }),
    {
        padding = { 0, 0, 0, ICON_SIZE + TEXT_PADDING},
    })

	a(FormatClassNames({STYLE_TEXT_LEFT}),
	{
		textAlignment = {0, 0.5}
	})

	a(FormatClassNames({STYLE_TEXT_RIGHT}),
	{
		textAlignment = {1.0, 0.5}
	})

    a(FormatClassNames({ STYLE_BUTTON }),
	{
		padding={(ROW_HEIGHT-ICON_SIZE)/2,0,(ROW_HEIGHT-ICON_SIZE)/2,0},
		size={ICON_SIZE,ROW_HEIGHT},
		margin={0,0,0,0},
	})

	return result
end
