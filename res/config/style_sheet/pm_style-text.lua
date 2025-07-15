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

local ssu = require "stylesheetutil"
function data()
	local result = { }
	local a = ssu.makeAdder(result)

    a(FormatClassNames({styles.text.LEFT_ALIGNMENT}),
	{
		textAlignment = {0, 0.5}
	})

	a(FormatClassNames({styles.text.RIGHT_ALIGNMENT}),
	{
		textAlignment = {1.0, 0.5}
	})

    return result
end
