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

function functions.GenerateAxisTicks(minVal, maxVal, desiredCount)
    local range = maxVal - minVal

    -- Step 1: Calculate raw step size
    local roughStep = range / (desiredCount - 1)

    -- Step 2: Find a "nice" rounded step size
    local magnitude = 10 ^ math.floor(math.log(roughStep, 10))
    local fractions = {1, 2, 2.5, 5, 10}
    local niceStep = fractions[1] * magnitude
    for _, f in ipairs(fractions) do
        niceStep = f * magnitude
        if niceStep > roughStep then
            break
        end
    end

    -- Step 3: Expand range outward to align with niceStep
    local startVal = math.floor(minVal / niceStep) * niceStep
    local endVal = math.ceil(maxVal / niceStep) * niceStep

    -- Step 4: Generate ticks
    local ticks = {}
    for val = startVal, endVal, niceStep do
        table.insert(ticks, math.floor(val + 0.5)) -- round to nearest int
    end

    return ticks
end


local chart = {}
chart.constants = constants
chart.functions = functions

return chart