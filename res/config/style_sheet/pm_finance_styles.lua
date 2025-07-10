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

local constants = dofile(ScriptPath() .. "../../scripts/pm_finance/constants.lua")

local ROW_HEIGHT = 25
local ICON_SIZE = 15
local TEXT_PADDING = 10

local ssu = require "stylesheetutil"
function data()
	local result = { }
	local a = ssu.makeAdder(result)

    a(FormatClassNames({ constants.STYLE_SUMMARY_TABLE }),
	{
		padding = {0,0,3,0},
        size={-1, 5*ROW_HEIGHT + 5},
		gravity = {-1.0 ,-1.0},
	})

    a(FormatClassNames({ constants.STYLE_SUMMARY_LABEL }),
    {
        padding = { 0, 0, 0, ICON_SIZE + TEXT_PADDING},
    })

	return result
end
