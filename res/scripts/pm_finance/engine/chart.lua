local engineJournal = require "pm_finance/engine/journal"
local categories = require "pm_finance/constants/categories"

local constants = {}
local functions = {}

function functions.GenerateTransportCategorySerie(years, transportType, category)
    local result = {}
    result.xValues = {}
    result.yValues = {}

    for _, year in ipairs(years) do
        local journal = engineJournal.functions.GetJournal(year)
        local journalValue = engineJournal.functions.GetValueFromJournal(journal, transportType, category)
        table.insert(result.xValues, year)
        table.insert(result.yValues, functions.GetChartValue(journalValue, category))
    end

    result.xMinValue = math.min(table.unpack(result.xValues))
    result.xMaxValue = math.max(table.unpack(result.xValues))
    result.yMinValue = math.min(table.unpack(result.yValues))
    result.yMaxValue = math.max(table.unpack(result.yValues))

    return result
end

function functions.GetChartValue(value, category)
    if category == categories.constants.TOTAL or category == categories.constants.CASHFLOW then
        return value
    end
    return math.abs(value)
end


local chart = {}
chart.constants = constants
chart.functions = functions

return chart