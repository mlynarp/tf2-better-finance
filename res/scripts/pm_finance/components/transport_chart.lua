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
    guiChart.functions.SetXAxis(financeChart, 1850, 1855, {1851, 1852, 1853, 1854, 1855}, tostring)
    guiChart.functions.SetYAxis(financeChart, -5000000, 15000000, {-2000000, 0, 2000000, 4000000, 6000000, 8000000, 10000000, 12000000, 14000000}, api.util.formatMoney)

    local seriesLabels = {}
    for i, category in pairs(constants.Categories) do
        guiChart.functions.SetupSerie(financeChart, i-1, functions.GetSerieType(category), functions.GetColorForCategory(category))
        table.insert(seriesLabels, _(category))
    end

    financeChart:setSeriesLabels(seriesLabels)

    return financeChart
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
        return api.type.Vec4f.new(0,0,255,25)
    end

    if category == categories.constants.MAINTENANCE then
        return api.type.Vec4f.new(255,0,0,25)
    end

    if category == categories.constants.INVESTMENTS then
        return api.type.Vec4f.new(0,255,0,25)
    end

    if category == categories.constants.TOTAL then
        return api.type.Vec4f.new(0,0,0,5)
    end

    if category == categories.constants.CASHFLOW then
        return api.type.Vec4f.new(255,0,255,128)
    end
end

function functions.GetSerieType(category)
    if category == categories.constants.TOTAL or category == categories.constants.CASHFLOW then
        return guiChart.constants.TYPE.LINE
    end

    return guiChart.constants.TYPE.BAR
end


            --financeChart:onStep( function(totaltime, steptime)  -- Highlight deac 
            --    financeChart:clear()
            --    financeChart:addSeries({ 0}, { 0})
            --    financeChart:addSeries({ 0}, { 0})
            --    financeChart:addSeries({ 0, 1, 2, 3 }, { 150000, 1800000, -500000, 250000})
            --    financeChart:setAxis(0, -1, 6, { 0.2, 1.2, 2.2, 2.8, 3.6, 4.3, 5.0 })
            --    financeChart:setAxis(1, -1000000, 3000000, { -1000000, 0, 1000000, 2000000, 3000000 })
            --end)

            --financeChart:invokeLater( function(totaltime, steptime)  -- Highlight deac 
            --    financeChart:clear()
            --    financeChart:addSeries({ 0}, { 0})
            --    financeChart:addSeries({ 0}, { 0})
            --    financeChart:addSeries({ 0, 1, 2, 3 }, { 150000, 1800000, -500000, 250000})
            --    financeChart:setAxis(0, -1, 6, { 0.2, 1.2, 2.2, 2.8, 3.6, 4.3, 5.0 })
            --    financeChart:setAxis(1, -1000000, 3000000, { -1000000, 0, 1000000, 2000000, 3000000 })
            --end)

--api.gui.util.getById("menu.finances.category"):getTab(1):getLayout():getItem(2):setVisible(false, false)
--game.interface.getLog(16579, "", { year = 1850, day = 1, month = 1})


local result = {}
result.constants = constants
result.functions = functions

return result