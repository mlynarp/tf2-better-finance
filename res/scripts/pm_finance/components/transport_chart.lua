local transport = require "pm_finance/constants/transport"
local categories = require "pm_finance/constants/categories"
local columns = require "pm_finance/constants/columns"
local styles = require "pm_finance/constants/styles"

local engineCalendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"
local engineChart = require "pm_finance/engine/chart"

local guiTextView = require "pm_finance/gui/text_view"
local guiChart = require "pm_finance/gui/chart"
local guiLayout = require "pm_finance/gui/layout"
local guiButton = require "pm_finance/gui/button"
local guiComponent = require "pm_finance/gui/component"

local constants = {}
local functions = {}

constants.TransportChart = { Id = "pm-transportChart", Name =  "TransportChart"}
constants.Categories = { categories.constants.TOTAL, categories.constants.CASHFLOW, categories.constants.INCOME, 
                         categories.constants.MAINTENANCE, categories.constants.INVESTMENTS }


function functions.CreateTransportChart(transportType)
    local financeChart = guiChart.functions.CreateChart(functions.GetChartId(transportType))
    guiChart.functions.SetXAxis(financeChart, 1850, 1882, {1851}, tostring)
    guiChart.functions.SetYAxis(financeChart, 0, 100000, {50000}, api.util.formatMoney)

    for i, category in pairs(constants.Categories) do
        guiChart.functions.SetupSerie(financeChart, i-1, functions.GetSerieType(category), functions.GetColorForCategory(category))
    end

    financeChart:setSeriesLabels(functions.GetSeriesLabels())

    return financeChart
end

function functions.GetSeriesLabels()
    local seriesLabels = {}
    for i, category in pairs(constants.Categories) do
        table.insert(seriesLabels, _(category))
    end

    return seriesLabels
end

function functions.GetSeriesColor()
    local colors = {}
    for i, category in pairs(constants.Categories) do
        local color = functions.GetColorForCategory(category)
        table.insert(colors, api.type.Vec3f.new(color[1], color[2], color[3]))
    end

    return colors
end

function functions.UpdateChart(years, transportType)
    local financeChart = guiComponent.functions.FindById(functions.GetChartId(transportType))
    financeChart:clear()

    local yMinValue = 0
    local yMaxValue = 0

    for i, category in pairs(constants.Categories) do
        local serie = engineChart.functions.GenerateTransportCategorySerie(years, transportType, category)
        financeChart:addSeries(serie.xValues, serie.yValues)
        yMinValue = math.min(yMinValue, serie.yMinValue)
        yMaxValue = math.max(yMaxValue, serie.yMaxValue)
    end

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

function functions.GetColorForCategory(category)
    if category == categories.constants.INCOME then
        return guiChart.functions.MakeColor({153,204,255,255})
    end

    if category == categories.constants.MAINTENANCE then
        return guiChart.functions.MakeColor({255,153,153,255})
    end

    if category == categories.constants.INVESTMENTS then
        return guiChart.functions.MakeColor({98,237,52,255})
    end

    if category == categories.constants.TOTAL then
        return guiChart.functions.MakeColor({255,255,255,255})
    end

    if category == categories.constants.CASHFLOW then
        return guiChart.functions.MakeColor({8,0,255,255})
    end
end

function functions.GetSerieType(category)
    if category == categories.constants.TOTAL or category == categories.constants.CASHFLOW then
        return guiChart.constants.TYPE.LINE
    end

    return guiChart.constants.TYPE.BAR
end

--game.interface.getLog(16579, "", { year = 1850, day = 1, month = 1})

local result = {}
result.constants = constants
result.functions = functions

return result