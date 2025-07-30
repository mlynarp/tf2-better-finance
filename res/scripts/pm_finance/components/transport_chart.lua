local transport = require "pm_finance/constants/transport"
local categories = require "pm_finance/constants/categories"
local columns = require "pm_finance/constants/columns"
local styles = require "pm_finance/constants/styles"

local engineCalendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"

local guiTextView = require "pm_finance/gui/text_view"
local guiChart = require "pm_finance/gui/chart"
local guiLayout = require "pm_finance/gui/layout"
local guiButton = require "pm_finance/gui/button"
local guiComponent = require "pm_finance/gui/component"

local constants = {}
local functions = {}

constants.TransportChart = { Id = "pm-transportChart", Name =  "TransportChart"}


function functions.CreateTransportChart(transportType)
    local financeChart = guiChart.functions.CreateChart(functions.GetChartId(transportType))
    guiChart.functions.SetXAxis(financeChart, 1850, 1855, {1851, 1852, 1853, 1854, 1855}, functions.FormatAxisValue)
    guiChart.functions.SetYAxis(financeChart, -5000000, 15000000, {-2000000, 0, 2000000, 4000000, 6000000, 8000000, 10000000, 12000000, 14000000}, functions.FormatMoneyValue)

    financeChart:setType(0, "LINE")
    financeChart:setLineWidth(0, 50)
    financeChart:setType(1, "LINE")
    financeChart:setType(2, "BAR")
    financeChart:setType(3, "BAR")
    financeChart:setLineWidth(3, 10)
    financeChart:setType(4, "BAR")
    financeChart:setSeriesLabels({"Income", "Maintenance", "Investments", "Profit", "Cashflow"})
    financeChart:setColor(0, api.type.Vec4f.new(0,0,255,25))
    financeChart:setColor(1, api.type.Vec4f.new(255,0,0,25))
    financeChart:setColor(2, api.type.Vec4f.new(0,255,0,25))
    financeChart:setColor(3, api.type.Vec4f.new(0,0,255,5))
    financeChart:setColor(4, api.type.Vec4f.new(255,0,255,128))

    return financeChart
end

function functions.FormatAxisValue(value)
    return tostring(value)
end

function functions.FormatMoneyValue(value)
    return api.util.formatMoney(value)
end

function functions.UpdateChart(years, transportType)
    local financeChart = guiComponent.functions.FindById(functions.GetChartId(transportType))
    financeChart:clear()
    financeChart:addSeries({ 1851, 1852, 1853, 1854 }, { 300000, 1500000, 5000000, 12000000})
    financeChart:addSeries({ 1851, 1852, 1853, 1854 }, { 250000, 1200000, 7000000, 10000000})
    financeChart:addSeries({ 1851, 1852, 1853, 1854 }, { 5000000, 2500000, 1000000, 5000000})
    financeChart:addSeries({ 1851, 1852, 1853, 1854 }, { -4500000, -2200000, -3000000, 1500000})
    financeChart:addSeries({ 1851, 1852, 1853, 1854 }, { 50000, 300000, -2000000, 2000000})
end

function functions.GetChartId(transportType)
    return constants.TransportChart.Id .. "." .. transportType
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

            --api.gui.util.getById("menu.finances.category"):getTab(1):getLayout():getItem(1):setColor(1, api.type.Vec4f.new(0,255,0,255))
--api.gui.util.getById("menu.finances.category"):getTab(1):getLayout():getItem(1):setSeriesLabels({"rail", "airff"})
--api.gui.util.getById("menu.finances.category"):getTab(1):getLayout():getItem(2):setVisible(false, false)
--game.interface.getLog(16579, "", { year = 1850, day = 1, month = 1})


local result = {}
result.constants = constants
result.functions = functions

return result