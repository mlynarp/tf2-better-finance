local constants = require "pm_finance/constants"
local transport = require "pm_finance/constants/transport"
local columns = require "pm_finance/constants/columns"
local categories = require "pm_finance/constants/categories"

local styles = require "pm_finance/constants/styles"

local calendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"
local ui_functions = require "pm_finance/ui_functions"

local guiChart = require "pm_finance//gui/chart"
local guiLayout = require "pm_finance/gui/layout"
local guiTableView = require "pm_finance/gui/table_view"
local guiComponent = require "pm_finance/gui/component"

local compTransportTable = require "pm_finance/components/transport_table"
local guiFinanceTab = require "pm_finance/components/finance_tab_widget"

local financeTabWindow = nil
local summaryTable = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0

function AddSummaryLineToTable(category, styleLevel)
    local row = {}

    local labelView = ui_functions.CreateTextView(_(category), 
                                                { styleLevel, constants.STYLE_SUMMARY_LABEL, styles.table.CELL, styles.text.LEFT_ALIGNMENT }, 
                                                ui_functions.GetTableControlId(columns.constants.COLUMN_LABEL, category))
    guiComponent.functions.SetTooltipByCategory(labelView, category)
    
    local comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { labelView }, "0")
    comp:setStyleClassList({ styleLevel, styles.table.CELL })
    table.insert(row, comp)

    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        local valueView = ui_functions.CreateTextView("", { styleLevel, styles.table.CELL, styles.text.RIGHT_ALIGNMENT }, 
                                                ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, category))
        guiComponent.functions.SetTooltipByCategory(valueView, category)
        
        comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { valueView }, "0")
        comp:setStyleClassList({ styleLevel, styles.table.CELL })
        table.insert(row, comp)
    end
    
    local totalView = ui_functions.CreateTextView("", { styleLevel, styles.table.CELL, styles.text.RIGHT_ALIGNMENT }, 
                                                ui_functions.GetTableControlId(transport.constants.COLUMN_TOTAL, category))
    guiComponent.functions.SetTooltipByCategory(totalView, category)
    
    comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { totalView }, "0")
    comp:setStyleClassList({ styleLevel, styles.table.CELL })
    table.insert(row, comp)

    summaryTable:addRow(row)
end

function InitSummaryTable()
    summaryTable = guiTableView.functions.CreateTableView(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2, "pm-mySummaryTable", "pm-mySummaryTable")
    summaryTable:setStyleClassList({ constants.STYLE_SUMMARY_TABLE })

    AddSummaryLineToTable(constants.CAT_PROFIT, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_LOAN, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_INTEREST, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_OTHER, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_BALANCE, styles.table.TOTAL)
end

function InitFinanceTableTab()
    financeTabWindow:getParent():getParent():setSize(api.gui.util.Size.new(1100, 800))
    financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
        guiUpdate = visible
    end)

    InitSummaryTable()
    local financeTabWidget = guiFinanceTab.functions.CreateFinanceTabWidget()

    local financeTableLayout = financeTabWindow:getTab(0):getLayout()
    financeTableLayout:removeItem(financeTableLayout:getItem(0))
    financeTableLayout:insertItem(financeTabWidget, 0)

    --replace current summary table
    financeTableLayout:removeItem(financeTableLayout:getItem(3))
    financeTableLayout:insertItem(summaryTable, 3)

    financeTable:setColWidth(0, 300)
    summaryTable:setColWidth(0, 300)

    for j = 1, constants.NUMBER_OF_YEARS_COLUMNS + 1 do
        financeTable:setColWeight(j, 1)
        summaryTable:setColWeight(j, 1)
    end
end


end

function UpdateSummaryTable(currentYearOnly)
    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        local year = calendar.functions.GetYearFromYearIndex(i)
        local journal = engineJournal.functions.GetJournal(year)
        local profit = engineJournal.functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_TOTAL)
        local balance = engineJournal.functions.GetEndOfYearBalance(year)

        ui_functions.UpdateCellValue(profit, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_PROFIT))
        ui_functions.UpdateCellValue(journal.loan, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_LOAN))
        ui_functions.UpdateCellValue(journal.interest, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_INTEREST))
        ui_functions.UpdateCellValue(journal.construction.other._sum, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_OTHER))
        ui_functions.UpdateCellValue(balance, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_BALANCE))
    end

    local overallJournal = engineJournal.functions.GetJournal(0)
    local profit = engineJournal.functions.GetValueFromJournal(overallJournal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_TOTAL)
    local balance = engineJournal.functions.GetCurrentBalance()
    
    ui_functions.UpdateCellValue(profit, ui_functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_PROFIT))
    ui_functions.UpdateCellValue(overallJournal.loan, ui_functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_LOAN))
    ui_functions.UpdateCellValue(overallJournal.interest, ui_functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_INTEREST))
    ui_functions.UpdateCellValue(balance - (profit + overallJournal.loan + overallJournal.interest), ui_functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_OTHER))
    ui_functions.UpdateCellValue(balance, ui_functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_BALANCE))
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
            financeTabWindow = api.gui.util.getById("menu.finances.category")
            InitFinanceTableTab()
        end,
        guiUpdate = function()
            local currentBalance = engineJournal.functions.GetCurrentBalance()
            local currentYear = calendar.functions.GetCurrentGameYear()
            if guiUpdate and financeTabWindow:getCurrentTab() == 0 and (currentBalance ~= lastBalance or currentYear ~= lastYear) then
                UpdateSummaryTable(currentYear == lastYear)
                compTransportTable.functions.UpdateTableValues(currentYear == lastYear)
                lastYear = currentYear
                lastBalance = currentBalance
            end
        end,
    }
end
