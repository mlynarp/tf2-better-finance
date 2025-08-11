local params = require "pm_finance/constants/params"
local transport = require "pm_finance/constants/transport"
local callbacks = require "pm_finance/constants/callbacks"

local engineCalendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"
local engineGameState = require "pm_finance/engine/game_state"

local guiComponent = require "pm_finance/gui/component"
local guiLayout = require "pm_finance/gui/layout"

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
    if params.constants.CHARTS_ENABLED == false then
        return
    end

    local financeChartLayout = financeTabWindow:getTab(1):getLayout()
    local sliderComponent = financeChartLayout:getItem(0)

    for i = 0, financeChartLayout:getNumItems() - 1 do
        financeChartLayout:removeItem(financeChartLayout:getItem(0))
    end

    local chartTabWidget = compTransportTabWidget.functions.CreateTabWidget("Chart", compTransportChart.functions.CreateTransportChart)
    financeChartLayout:addItem(chartTabWidget)
    
    local metadata = compTransportChart.functions.GetSeriesMetadata()
    local chartLegendWidget = compLegendWidget.functions.CreateLegendWidget(metadata.keys, metadata.labels, metadata.defaultColors)
    local spacer = guiComponent.functions.CreateSpacer()
    local legendBar = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, {chartLegendWidget, spacer, sliderComponent}, "LegendSliderBar")
    financeChartLayout:addItem(legendBar)

    yearsSlider = sliderComponent:getLayout():getItem(1)
    yearsSlider:onValueChanged(function(value) 
        sliderChanged = true
	end)
    
end

local function UpdateFinanceChart(dataChanged)
    if params.constants.CHARTS_ENABLED == false then
        return
    end

    if  (financeTabWindow:getCurrentTab() == 1 and (dataChanged or sliderChanged or engineGameState.gameData[engineGameState.constants.GUI_UPDATE] == true))  then
        for _, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
            compTransportChart.functions.UpdateChart(engineCalendar.functions.GetYearsFromCount(yearsSlider:getValue()), transportType)
        end
        sliderChanged = false
        if engineGameState.gameData[engineGameState.constants.GUI_UPDATE] == true then
            callbacks.functions.SendCallbackEvent(callbacks.constants.CLEAR_GUI_UPDATE, "", nil)
        end
    end
end

-- ***************************
-- ** Main
-- ***************************
function data()
    return {
        save = function()
            engineGameState.gameData["gameTime"] = game.interface.getGameTime().time * 1000
            return engineGameState.gameData
        end,
        load = function(data)
            if not data then
                local currentYear = engineCalendar.functions.GetCurrentGameYear()
                for j = 1, params.constants.NUMBER_OF_YEARS_COLUMNS do
                    engineGameState.gameData[tostring(currentYear)] = engineCalendar.functions.GetYearStartTime(currentYear)
                    currentYear = currentYear - 1
                end
            else
                engineGameState.gameData = data
            end
        end,
        update = function()
            local currentYear = engineCalendar.functions.GetCurrentGameYear()
            if currentYear ~= lastYear then
                lastYear = currentYear
                local currentYearState = engineGameState.functions.GetYearState(currentYear)
                if currentYearState == nil then
                    engineGameState.gameData[tostring(currentYear)] = engineCalendar.functions.GetYearStartTime(currentYear)
                end
            end
        end,
        handleEvent = function(src, id, name, param)
            if id == callbacks.constants.COLOR_CHANGED then
                engineGameState.functions.StoreColor(name, api.type.Vec3f.new(param.R, param.G, param.B))
                engineGameState.functions.ForceGuiUpdate()
			end
            if id == callbacks.constants.CLEAR_GUI_UPDATE then
                engineGameState.functions.ClearGuiUpdate()
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