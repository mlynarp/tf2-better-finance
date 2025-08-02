local LEGEND_BAR_HEIGHT = 35

local ssu = require "stylesheetutil"

function data()
	local result = { }
	local a = ssu.makeAdder(result)

    a("LegendWidget",
	{
		gravity = { 0, 0.5 }
	})

    a("LegendSliderBar",
	{
		size = { -1, LEGEND_BAR_HEIGHT },
        margin = { 10, 10, 10, 10},
	})

    a("Spacer",
	{
		gravity = { -1, -1 }
	})

    return result
end
