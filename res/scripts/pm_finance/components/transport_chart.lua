local categories = require "pm_finance/constants/categories"

local engineChart = require "pm_finance/engine/chart"
local engineGameState = require "pm_finance/engine/game_state"

local guiChart = require "pm_finance/gui/chart"
local guiComponent = require "pm_finance/gui/component"

local constants = {}
local functions = {}

constants.TransportChart = { Id = "pm-transportChart", Name =  "TransportChart"}
constants.Categories = { categories.constants.TOTAL, categories.constants.CASHFLOW, categories.constants.INCOME, 
                         categories.constants.MAINTENANCE, categories.constants.INVESTMENTS }


function functions.CreateTransportChart(transportType)
    local financeChart = guiChart.functions.CreateChart(functions.GetChartId(transportType))

--    local metadata = functions.GetSeriesMetadata()
    --for i, key in pairs(metadata.keys) do
     --   guiChart.functions.SetupSerie(financeChart, i-1, metadata.serieTypes[i])
    --end

    --guiChart.functions.SetSerieLabels(financeChart, metadata.labels)
    return financeChart
end

function functions.UpdateChart(years, transportType)
    local financeChart = guiComponent.functions.FindById(functions.GetChartId(transportType))
    financeChart:clear()

    local yMinValue = 0
    local yMaxValue = 0

    local metadata = functions.GetSeriesMetadata()
    local labels = {}
    local serieVisibleIndex = 0
    for i, category in pairs(metadata.keys) do
        local color = engineGameState.functions.GetColor(category)
        if color == nil then
            color = metadata.defaultColors[i]
        end
        if color[1] ~= -1 then
            local serie = engineChart.functions.GenerateTransportCategorySerie(years, transportType, category)
            guiChart.functions.SetupSerie(financeChart, serieVisibleIndex, metadata.serieTypes[i])
            guiChart.functions.SetSerieColor(financeChart, serieVisibleIndex, color)
            financeChart:addSeries(serie.xValues, serie.yValues)
            yMinValue = math.min(yMinValue, serie.yMinValue)
            yMaxValue = math.max(yMaxValue, serie.yMaxValue)
            table.insert(labels, metadata.labels[i])
            serieVisibleIndex = serieVisibleIndex + 1
        end
    end

    guiChart.functions.SetSerieLabels(financeChart, labels)

    guiChart.functions.SetXAxis(financeChart, years[1] - 1, years[#years] + 1, years, tostring)
    
    if yMaxValue == 0 then
        yMaxValue = 100000
    end

    local yValues = engineChart.functions.GenerateAxisTicks(yMinValue, yMaxValue, 6)
    guiChart.functions.SetYAxis(financeChart, yValues[1], yValues[#yValues], yValues, api.util.formatMoney)
end

function functions.GetChartId(transportType)
    return constants.TransportChart.Id .. "." .. transportType
end

function functions.GetSeriesMetadata()
    local keys = {}
    local labels = {}
    local defaultColors = {}
    local serieTypes = {}
    for i, category in pairs(constants.Categories) do
        table.insert(keys, category)
        table.insert(labels, _(category))
        table.insert(defaultColors, categories.functions.GetDefaultColor(category))
        table.insert(serieTypes, functions.GetSerieType(category))
    end

    local result = {}
    result.keys = keys
    result.labels = labels
    result.defaultColors = defaultColors
    result.serieTypes = serieTypes
    return result
end

function functions.GetSerieType(category)
    if category == categories.constants.TOTAL or category == categories.constants.CASHFLOW then
        return guiChart.constants.TYPE.LINE
    end

    return guiChart.constants.TYPE.BAR
end

local result = {}
result.constants = constants
result.functions = functions

return result