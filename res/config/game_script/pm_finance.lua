local columns = require "pm_finance/constants/columns"
local transport = require "pm_finance/constants/transport"

local engineCalendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"

local guiComponent = require "pm_finance/gui/component"

local compSummaryTable = require "pm_finance/components/summary_table"
local compTransportTabWidget = require "pm_finance/components/transport_tab_widget"
local compTransportTable = require "pm_finance/components/transport_table"
local compTransportChart = require "pm_finance/components/transport_chart"
local compLegendWidget = require "pm_finance/components/legend_widget"

local financeTabWindow = nil
local yearsSlider = nil

local guiUpdate = false
local lastBalance = 0
local lastYear = 0
local sliderChanged = true

local function InitFinanceTableTab()
    local financeTableLayout = financeTabWindow:getTab(0):getLayout()

    for i = 0, 3 do
        financeTableLayout:removeItem(financeTableLayout:getItem(0))
    end

    local tableTabWidget = compTransportTabWidget.functions.CreateTabWidget("Table", compTransportTable.functions.CreateTransportTable)
    local summaryTable = compSummaryTable.functions.CreateSummaryTable()

    financeTableLayout:insertItem(tableTabWidget, 0)
    financeTableLayout:insertItem(summaryTable, 1)
end

local function UpdateFinanceTable(dataChanged, currentYear, currentBalance)
    if  (financeTabWindow:getCurrentTab() == 0 and dataChanged)  then
        for _, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
            compTransportTable.functions.UpdateTableValues(currentYear == lastYear, transportType)
        end

        compSummaryTable.functions.UpdateSummaryTable(currentYear == lastYear)
        lastYear = currentYear
        lastBalance = currentBalance
    end
end

local function InitFinanceChartTab()
    local financeChartLayout = financeTabWindow:getTab(1):getLayout()
    yearsSlider = financeChartLayout:getItem(0):getLayout():getItem(1)
    yearsSlider:onValueChanged(function(value) 
        sliderChanged = true
	end)
    financeChartLayout:removeItem(financeChartLayout:getItem(1))
    financeChartLayout:removeItem(financeChartLayout:getItem(1))

    local chartLegendWidget = compLegendWidget.functions.CreateLegendWidget(compTransportChart.functions.GetSeriesLabels(), compTransportChart.functions.GetSeriesColor())
    financeChartLayout:getItem(0):getLayout():insertItem(chartLegendWidget, 0)

    local chartTabWidget = compTransportTabWidget.functions.CreateTabWidget("Chart", compTransportChart.functions.CreateTransportChart)
    financeChartLayout:insertItem(chartTabWidget, 0)
end

local function UpdateFinanceChart(dataChanged)
    if  (financeTabWindow:getCurrentTab() == 1 and (dataChanged or sliderChanged))  then
        for _, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
            compTransportChart.functions.UpdateChart(engineCalendar.functions.GetYearsFromCount(yearsSlider:getValue()), transportType)
        end
        sliderChanged = false
    end
end

-- ***************************
-- ** Main
-- ***************************
function data()
    return {
        save = function()
            engineCalendar.gameState["gameTime"] = game.interface.getGameTime().time * 1000
            return engineCalendar.gameState
        end,
        load = function(data)
            if not data then
                local gameState = {}
                local currentYear = engineCalendar.functions.GetCurrentGameYear()
                for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                    gameState[tostring(currentYear)] = engineCalendar.functions.GetYearStartTime(currentYear)
                    currentYear = currentYear - 1
                end
                engineCalendar.gameState = gameState
            else
                engineCalendar.gameState = data
            end
        end,
        update = function()
            local currentYear = engineCalendar.functions.GetCurrentGameYear()
            if currentYear ~= lastYear then
                lastYear = currentYear
                local currentYearState = engineCalendar.functions.GetGameStatePerYear(currentYear)
                if currentYearState == nil then
                    engineCalendar.gameState[tostring(currentYear)] = engineCalendar.functions.GetYearStartTime(currentYear)
                end
            end
        end,
        guiInit = function()
            financeTabWindow = guiComponent.functions.FindById("menu.finances.category")
            financeTabWindow:getParent():getParent():setSize(api.gui.util.Size.new(1100, 650))
            financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
                guiUpdate = visible
            end)
            InitFinanceTableTab()
            InitFinanceChartTab()
        end,
        guiUpdate = function()
            if (not guiUpdate) then
                return
            end

            local currentBalance = engineJournal.functions.GetCurrentBalance()
            local currentYear = engineCalendar.functions.GetCurrentGameYear()
            local dataChanged = currentBalance ~= lastBalance or currentYear ~= lastYear

            UpdateFinanceTable(dataChanged, currentYear, currentBalance)
            UpdateFinanceChart(dataChanged)
        end,
    }
end