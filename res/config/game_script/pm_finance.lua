local transport = require "pm_finance/constants/transport"
local columns = require "pm_finance/constants/columns"
local categories = require "pm_finance/constants/categories"

local styles = require "pm_finance/constants/styles"

local calendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"

local guiComponent = require "pm_finance/gui/component"

local compTransportTable = require "pm_finance/components/transport_table"
local compSummaryTable = require "pm_finance/components/summary_table"
local guiFinanceTab = require "pm_finance/components/finance_tab_widget"

local financeTabWindow = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0

function InitFinanceTableTab()
    financeTabWindow:getParent():getParent():setSize(api.gui.util.Size.new(1100, 650))
    financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
        guiUpdate = visible
    end)

    local financeTableLayout = financeTabWindow:getTab(0):getLayout()
    --remove all previous widgets
    for i = 0,  3 do
        financeTableLayout:removeItem(financeTableLayout:getItem(0))
    end

    local financeTabWidget = guiFinanceTab.functions.CreateFinanceTabWidget()
    local summaryTable = compSummaryTable.functions.CreateSummaryTable(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2)

    financeTableLayout:insertItem(financeTabWidget, 0)
    financeTableLayout:insertItem(summaryTable, 1)
end

-- ***************************
-- ** Main
-- ***************************
function data()
    return {
        save = function()
            calendar.gameState["gameTime"] = game.interface.getGameTime().time * 1000
            return calendar.gameState
        end,
        load = function(data)
            if not data then
                local gameState = {}
                local currentYear = calendar.functions.GetCurrentGameYear()
                for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                    gameState[tostring(currentYear)] = calendar.functions.GetYearStartTime(currentYear)
                    currentYear = currentYear - 1
                end
                calendar.gameState = gameState
            else
                calendar.gameState = data
            end
        end,
        update = function()
            local currentYear = calendar.functions.GetCurrentGameYear()
            if currentYear ~= lastYear then
                lastYear = currentYear
                local currentYearState = calendar.functions.GetGameStatePerYear(currentYear)
                if currentYearState == nil then
                    calendar.gameState[tostring(currentYear)] = calendar.functions.GetYearStartTime(currentYear)
                end
            end
        end,
        guiInit = function()
            financeTabWindow = guiComponent.functions.FindById("menu.finances.category")
            InitFinanceTableTab()
        end,
        guiUpdate = function()
            if (not guiUpdate) then
                return
            end

            local currentBalance = engineJournal.functions.GetCurrentBalance()
            local currentYear = calendar.functions.GetCurrentGameYear()

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
