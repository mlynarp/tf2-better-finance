local transport = require "pm_finance/constants/transport"
local categories = require "pm_finance/constants/categories"
local columns = require "pm_finance/constants/columns"
local styles = require "pm_finance/constants/styles"

local calendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"

local guiTextView = require "pm_finance/gui/text_view"
local guiTableView = require "pm_finance/gui/table_view"
local guiLayout = require "pm_finance/gui/layout"
local guiComponent = require "pm_finance/gui/component"


local constants = {}
local functions = {}

constants.SummaryTable = { Id = "pm-summaryTable", Name =  "SummaryTable"}

function functions.CreateSummaryTable(numberOfColumns)
    
    local summaryTable = guiTableView.functions.CreateTableView(numberOfColumns, constants.SummaryTable.Id, constants.SummaryTable.Name)
    summaryTable:setStyleClassList({ styles.table.STYLE_SUMMARY_TABLE })

    functions.AddSummaryLineToTable(summaryTable, categories.constants.CAT_PROFIT, styles.table.LEVEL_1)
    functions.AddSummaryLineToTable(summaryTable, categories.constants.CAT_LOAN, styles.table.LEVEL_1)
    functions.AddSummaryLineToTable(summaryTable, categories.constants.CAT_INTEREST, styles.table.LEVEL_1)
    functions.AddSummaryLineToTable(summaryTable, categories.constants.CAT_OTHER, styles.table.LEVEL_1)
    functions.AddSummaryLineToTable(summaryTable, categories.constants.CAT_BALANCE, styles.table.TOTAL)

    summaryTable:setColWidth(0, 300)

    for j = 1, numberOfColumns - 1 do
        summaryTable:setColWeight(j, 1)
    end

    return summaryTable
end

function functions.AddSummaryLineToTable(summaryTable, category, styleLevel)
    local row = {}

    local id = functions.GetTableControlId(columns.constants.COLUMN_LABEL, category)
    local styleList = { constants.STYLE_SUMMARY_LABEL, styles.table.CELL, styles.text.LEFT_ALIGNMENT }
    local labelView = guiTextView.functions.CreateTextView(_(category), id, styleList)
    guiComponent.functions.SetTooltipByCategory(labelView, category)
    
    local comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { labelView }, "1")
    comp:setStyleClassList({ styles.table.CELL })
    table.insert(row, comp)

    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        id = functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, category)
        styleList = { styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
        labelView = guiTextView.functions.CreateTextView("", id, styleList)
        guiComponent.functions.SetTooltipByCategory(labelView, category)
        
        comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { labelView }, "0")
        comp:setStyleClassList({ styles.table.CELL })
        table.insert(row, comp)
    end
    
    id = functions.GetTableControlId(columns.constants.COLUMN_TOTAL, category)
    styleList = { styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
    labelView = guiTextView.functions.CreateTextView("", id, styleList)
    guiComponent.functions.SetTooltipByCategory(labelView, category)
    
    comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { labelView }, "0")
    comp:setStyleClassList({ styles.table.CELL })
    table.insert(row, comp)

    summaryTable:addRow(row)
end

function functions.UpdateSummaryTable(currentYearOnly)
    local index = 1
    if (currentYearOnly) then
        index = columns.constants.NUMBER_OF_YEARS_COLUMNS
    end
    
    for i = index, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        local year = calendar.functions.GetYearFromYearIndex(i)
        local journal = engineJournal.functions.GetJournal(year)
        local profit = engineJournal.functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_TOTAL)
        local balance = engineJournal.functions.GetEndOfYearBalance(year)

        local id = functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_PROFIT)
        guiTextView.functions.SetFormattedText(id, profit, guiTextView.constants.TEXT_TYPE.MONEY)
        
        id = functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_LOAN)
        guiTextView.functions.SetFormattedText(id, journal.loan, guiTextView.constants.TEXT_TYPE.MONEY)
        
        id = functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_INTEREST)
        guiTextView.functions.SetFormattedText(id, journal.interest, guiTextView.constants.TEXT_TYPE.MONEY)
        
        id = functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_OTHER)
        guiTextView.functions.SetFormattedText(id, journal.construction.other._sum, guiTextView.constants.TEXT_TYPE.MONEY)
        
        id = functions.GetTableControlId(columns.constants.COLUMN_YEAR..i, categories.constants.CAT_BALANCE)
        guiTextView.functions.SetFormattedText(id, balance, guiTextView.constants.TEXT_TYPE.MONEY)
    end

    local overallJournal = engineJournal.functions.GetJournal(0)
    local profit = engineJournal.functions.GetValueFromJournal(overallJournal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_TOTAL)
    local balance = engineJournal.functions.GetCurrentBalance()

    local id = functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_PROFIT)
    guiTextView.functions.SetFormattedText(id, profit, guiTextView.constants.TEXT_TYPE.MONEY)

    id = functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_LOAN)
    guiTextView.functions.SetFormattedText(id, overallJournal.loan, guiTextView.constants.TEXT_TYPE.MONEY)

    id = functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_INTEREST)
    guiTextView.functions.SetFormattedText(id, overallJournal.interest, guiTextView.constants.TEXT_TYPE.MONEY)

    id = functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_OTHER)
    guiTextView.functions.SetFormattedText(id, balance - (profit + overallJournal.loan + overallJournal.interest), guiTextView.constants.TEXT_TYPE.MONEY)
        
    id = functions.GetTableControlId(columns.constants.COLUMN_TOTAL, categories.constants.CAT_BALANCE)
    guiTextView.functions.SetFormattedText(id, balance, guiTextView.constants.TEXT_TYPE.MONEY)
end

function functions.GetTableControlId(column, category)
    local id = constants.SummaryTable.Id .. "." .. category .. "." .. column
    print(id)
    return id
end

local result = {}
result.constants = constants
result.functions = functions

return result
