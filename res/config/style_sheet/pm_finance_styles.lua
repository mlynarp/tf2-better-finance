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

local styles = dofile(ScriptPath() .. "../../scripts/pm_finance/constants/styles.lua")

local ROW_HEIGHT = 25

local ssu = require "stylesheetutil"
function data()
	local result = { }
	local a = ssu.makeAdder(result)

    a(FormatClassNames({ styles.table.STYLE_SUMMARY_TABLE }),
	{
		padding = {0,0,3,0},
        size={-1, 5*ROW_HEIGHT + 5},
		gravity = {-1.0 ,-1.0},
        borderWidth = {2,0,0,0},
        borderColor = {1,1,1,0.5},
        backgroundColor = ssu.makeColor(255, 255, 255, 15),
	})

    return result
end
