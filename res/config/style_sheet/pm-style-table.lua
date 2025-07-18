local function ScriptPath()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

local function FormatClassNames(classes)
    local result = ""
    for i, className in ipairs(classes) do
        result = result .. "!" .. className
    end
    return result
end

local styles = dofile(ScriptPath() .. "../../scripts/pm_finance/constants/styles.lua")

local ROW_HEIGHT = 25
local LEVEL_PADDING = 30
local ICON_SIZE = 15
local TEXT_PADDING = 5

local ssu = require "stylesheetutil"
function data()
	local result = { }
	local a = ssu.makeAdder(result)

    a(FormatClassNames({ styles.table.HEADER }),
	{
        backgroundColor = ssu.makeColor(255, 255, 255, 50),
        fontSize = 15,
	})

    a(FormatClassNames({ styles.table.CELL }),
	{
		gravity = {-1.0 ,-1.0},
        size = { -1, ROW_HEIGHT },
        textAlignment = { 0.5, 0.5 },
	})

    a(FormatClassNames({ styles.table.TOTAL }),
	{
		backgroundColor = ssu.makeColor(255, 255, 255, 50),
		size={-1, ROW_HEIGHT + 5},
	})

    a(FormatClassNames({styles.table.LEVEL_1}),
	{
        padding={0,0,0,TEXT_PADDING + ICON_SIZE},
	})

    a(FormatClassNames({styles.table.LEVEL_1, styles.table.EXPANDABLE}),
	{
        padding={0,0,0,TEXT_PADDING},
	})

    a(FormatClassNames({styles.table.LEVEL_2}),
	{
        padding={0,0,0,LEVEL_PADDING + TEXT_PADDING + ICON_SIZE},
	})

    a(FormatClassNames({styles.table.LEVEL_2, styles.table.EXPANDABLE}),
	{
        padding={0,0,0,LEVEL_PADDING + TEXT_PADDING},
	})

    a(FormatClassNames({ styles.table.STYLE_SUMMARY_TABLE }),
	{
		padding = {0,0,3,0},
        size={-1, 5*ROW_HEIGHT + 5},
		gravity = {-1.0 ,-1.0},
        borderWidth = {2,0,0,0},
        borderColor = {1,1,1,0.5},
        backgroundColor = ssu.makeColor(255, 255, 255, 15),
	})

    a(FormatClassNames({ styles.button.BUTTON }),
	{
		padding={(ROW_HEIGHT-ICON_SIZE)/2,0,(ROW_HEIGHT-ICON_SIZE)/2,0},
		size={ICON_SIZE,ROW_HEIGHT},
		margin={0,0,0,0},
	})

	return result
end
