local columns = require "pm_finance/constants/columns"

local engineCalendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"

local guiComponent = require "pm_finance/gui/component"

local compSummaryTable = require "pm_finance/components/summary_table"
local compTableTabWidget = require "pm_finance/components/transport_table_tab_widget"

local financeTabWindow = nil
local tableTabWidget = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0

function InitFinanceTableTab()
    local financeTableLayout = financeTabWindow:getTab(0):getLayout()
    --remove all previous widgets
    for i = 0, 3 do
        financeTableLayout:removeItem(financeTableLayout:getItem(0))
    end

    tableTabWidget = compTableTabWidget.functions.CreateTransportTableTabWidget()
    local summaryTable = compSummaryTable.functions.CreateSummaryTable(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2)

    financeTableLayout:insertItem(tableTabWidget, 0)
    financeTableLayout:insertItem(summaryTable, 1)
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
        end,
        guiUpdate = function()
            if (not guiUpdate) then
                return
            end

            local currentBalance = engineJournal.functions.GetCurrentBalance()
            local currentYear = engineCalendar.functions.GetCurrentGameYear()

            if (currentBalance == lastBalance and currentYear == lastYear) then
                return
            end

            if  (financeTabWindow:getCurrentTab() == 0)  then
                compTransportTable.functions.UpdateTableValues(currentYear == lastYear)
                compSummaryTable.functions.UpdateSummaryTable(currentYear == lastYear)
                lastYear = currentYear
                lastBalance = currentBalance
            end
        end,
    }
end
