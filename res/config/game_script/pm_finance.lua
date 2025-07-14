local constants = require "pm_finance/constants"
local transport = require "pm_finance/constants/transport"
local columns = require "pm_finance/constants/columns"
local categories = require "pm_finance/constants/categories"
local functions = require "pm_finance/functions"
local ui_functions = require "pm_finance/ui_functions"
local layout = require "pm_finance/gui/layout"
local tableView = require "pm_finance/gui/table_view"
local styles = require "pm_finance/constants/styles"
local transport_table = require "pm_finance/components/transport_table"
local financeTab = require "pm_finance/components/finance_tab_widget"
local tabWidget = require "pm_finance/gui/tab_widget"
local textView = require "pm_finance/gui/text_view"
local imageView = require "pm_finance/gui/image_view"

local financeTabWindow = nil
local financeTable = nil
local summaryTable = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0

function AddSummaryLineToTable(category, styleLevel)
    local row = {}

    local labelView = ui_functions.CreateTextView(_(category), 
                                                { styleLevel, constants.STYLE_SUMMARY_LABEL, styles.table.CELL, styles.text.LEFT_ALIGNMENT }, 
                                                ui_functions.GetTableControlId(columns.constants.COLUMN_LABEL, category))
    ui_functions.SetTooltipByCategory(labelView, category)
    
    local comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, { labelView }, "0")
    comp:setStyleClassList({ styleLevel, styles.table.CELL })
    table.insert(row, comp)

    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        local valueView = ui_functions.CreateTextView("", { styleLevel, styles.table.CELL, styles.text.RIGHT_ALIGNMENT }, 
                                                ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, category))
        ui_functions.SetTooltipByCategory(valueView, category)
        
        comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, { valueView }, "0")
        comp:setStyleClassList({ styleLevel, styles.table.CELL })
        table.insert(row, comp)
    end
    
    local totalView = ui_functions.CreateTextView("", { styleLevel, styles.table.CELL, styles.text.RIGHT_ALIGNMENT }, 
                                                ui_functions.GetTableControlId(transport.constants.COLUMN_TOTAL, category))
    ui_functions.SetTooltipByCategory(totalView, category)
    
    comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, { totalView }, "0")
    comp:setStyleClassList({ styleLevel, styles.table.CELL })
    table.insert(row, comp)

    summaryTable:addRow(row)
end

function InitSummaryTable()
    summaryTable = tableView.functions.CreateTableView(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2, "pm-mySummaryTable", "pm-mySummaryTable")
    summaryTable:setStyleClassList({ constants.STYLE_SUMMARY_TABLE })

    AddSummaryLineToTable(constants.CAT_PROFIT, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_LOAN, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_INTEREST, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_OTHER, styles.table.LEVEL_1)
    AddSummaryLineToTable(constants.CAT_BALANCE, styles.table.TOTAL)
end

function InitFinanceTab()
    financeTabWindow:getParent():getParent():setSize(api.gui.util.Size.new(1100, 800))
    financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
        guiUpdate = visible
    end)

    financeTable = transport_table.functions.InitFinanceTable()
    InitSummaryTable()

    local financeTableLayout = financeTabWindow:getTab(0):getLayout()
    --replace current finance table
    financeTableLayout:removeItem(financeTableLayout:getItem(0))
    financeTableLayout:insertItem(financeTable, 0)

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


function UpdateFinanceTable(currentYearOnly)
    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        if currentYearOnly then
            RefreshTransportCategoryValues(transportType, functions.GetJournal(functions.GetCurrentGameYear()), columns.constants.COLUMN_YEAR .. constants.NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                local year = functions.GetYearFromYearIndex(j)
                RefreshTransportCategoryValues(transportType, functions.GetJournal(year), columns.constants.COLUMN_YEAR .. j)
                api.gui.util.getById(ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR .. j)):setText(tostring(year))
            end
        end
        RefreshTransportCategoryValues(transportType, functions.GetJournal(0), transport.constants.COLUMN_TOTAL)
    end
end

function UpdateSummaryTable(currentYearOnly)
    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        local year = functions.GetYearFromYearIndex(i)
        local journal = functions.GetJournal(year)
        local profit = functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_TOTAL)
        local balance = functions.GetEndOfYearBalance(year)

        ui_functions.UpdateCellValue(profit, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_PROFIT))
        ui_functions.UpdateCellValue(journal.loan, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_LOAN))
        ui_functions.UpdateCellValue(journal.interest, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_INTEREST))
        ui_functions.UpdateCellValue(journal.construction.other._sum, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_OTHER))
        ui_functions.UpdateCellValue(balance, ui_functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_BALANCE))
    end

    local overallJournal = functions.GetJournal(0)
    local profit = functions.GetValueFromJournal(overallJournal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_TOTAL)
    local balance = functions.GetCurrentBalance()
    
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
            functions.gameState["gameTime"] = game.interface.getGameTime().time * 1000
            return functions.gameState
        end,
        load = function(data)
            if not data then
                local gameState = {}
                local currentYear = functions.GetCurrentGameYear()
                for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                    gameState[tostring(currentYear)] = functions.GetYearStartTime(currentYear)
                    currentYear = currentYear - 1
                end
                functions.gameState = gameState
            else
                functions.gameState = data
            end
        end,
        update = function()
            local currentYear = functions.GetCurrentGameYear()
            if currentYear ~= lastYear then
                lastYear = currentYear
                local currentYearState = functions.GetGameStatePerYear(currentYear)
                if currentYearState == nil then
                    functions.gameState[tostring(currentYear)] = functions.GetYearStartTime(currentYear)
                end
            end
        end,
        guiInit = function()
            financeTabWindow = api.gui.util.getById("menu.finances.category")
            InitFinanceTab()
        end,
        guiUpdate = function()
            local currentBalance = functions.GetCurrentBalance()
            local currentYear = functions.GetCurrentGameYear()
            if guiUpdate and financeTabWindow:getCurrentTab() == 0 and (currentBalance ~= lastBalance or currentYear ~= lastYear) then
                transport_table.functions.UpdateTableValues(currentYear == lastYear)
                UpdateSummaryTable(currentYear == lastYear)
                lastYear = currentYear
                lastBalance = currentBalance
            end
        end,
    }
end
