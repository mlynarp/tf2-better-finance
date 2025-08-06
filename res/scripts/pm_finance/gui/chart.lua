local guiColor = require "pm_finance/gui/color"

local constants = {}
local functions = {}

constants.TYPE = { LINE = "LINE", LINE_STEP = "LINE_STEP", BAR = "BAR" }
constants.AXIS = { X = 0, Y = 1 }

function functions.CreateChart(chartId)
    local chart = api.gui.comp.Chart.new()
    chart:setId(chartId)

    return chart
end

function functions.SetXAxis(chart, minValue, maxValue, values, formatFn)
    chart:setAxis(constants.AXIS.X, minValue, maxValue, values)
    chart:setLabelFormatter(constants.AXIS.X, formatFn)
end

function functions.SetYAxis(chart, minValue, maxValue, values, formatFn)
    chart:setAxis(constants.AXIS.Y, minValue, maxValue, values)
    chart:setLabelFormatter(constants.AXIS.Y, formatFn)
end

function functions.SetupSerie(chart, index, type)
    chart:setType(index, type)
end

function functions.SetSerieLabels(chart, serieLabels)
    chart:setSeriesLabels(serieLabels)
end

function functions.SetSerieColor(chart, index, color)
    chart:setColor(index, guiColor.functions.ConvertColorToAlphaColor(color))
end

local chart = {}
chart.constants = constants
chart.functions = functions

return chart
