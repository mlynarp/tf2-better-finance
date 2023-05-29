require "pm_finance_constants"
require "pm_finance_functions"
require "pm_finance_ui_functions"

local financeTabWindow = nil
local financeTable = nil
local summaryTable = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0


local tooltips = {
    settings = {
        Income = _("#Tooltip.Settings.Income"),
        Vehicles = _("#Tooltip.Settings.Vehicles"),
        Infrastructure = _("#Tooltip.Settings.Infrastructure"),
    },
    Details = {
        Income = _("#Tooltip.Details.Income"),
        Maintenance = _("#Tooltip.Details.Maintenance"),
        Vehicles = _("#Tooltip.Details.Vehicles"),
        Infrastructure = _("#Tooltip.Details.Infrastructure")
    },
    Menu =
    {
        Button = _("#Tooltip.Menu.Button"),
        gameInfo = _("#Tooltip.GameYear"),
    }
}

local state = {
    currentYear = 0,
}

function RefreshTransportCategoryValues(transportType, journal, column)
    --total
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_TOTAL), transportType .. CAT_TOTAL .. column)
    --income
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INCOME), transportType .. CAT_INCOME .. column)
    --maintenance
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE), transportType .. CAT_MAINTENANCE .. column)
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_VEHICLES), transportType .. CAT_MAINTENANCE_VEHICLES .. column)
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_INFRASTRUCTURE), transportType .. CAT_MAINTENANCE_INFRASTRUCTURE .. column)
    --investment
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS), transportType .. CAT_INVESTMENTS .. column)
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_VEHICLES), transportType .. CAT_INVESTMENTS_VEHICLES .. column)
    if IsCategoryAllowedForTransportType(transportType, CAT_INVESTMENTS_TRACKS) then
        UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_TRACKS), transportType .. CAT_INVESTMENTS_TRACKS .. column)
    elseif IsCategoryAllowedForTransportType(transportType, CAT_INVESTMENTS_ROADS) then
        UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_ROADS), transportType .. CAT_INVESTMENTS_ROADS .. column)
    end
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_INFRASTRUCTURE), transportType .. CAT_INVESTMENTS_INFRASTRUCTURE .. column)
    --cashflow
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_CASHFLOW), transportType .. CAT_CASHFLOW .. column)
    
end

function CreateTextView(text, styleList, id)
    local textView = api.gui.comp.TextView.new(text)
    textView:setStyleClassList(styleList)
    textView:setId(id)
    return textView
end

function AddTransportCategoryLineToFinanceTable(labelComponents, rowId, sLevel, level)
    local row = {}

    table.insert(row, LayoutComponentsHorizontally(labelComponents, { sLevel }, tostring(level)))
    for i = 1, NUMBER_OF_YEARS_COLUMNS do
        local yearCellView = CreateTextView(api.util.formatMoney(0), { sLevel, "sRight" }, rowId .. i)
        table.insert(row, LayoutComponentsHorizontally({ yearCellView }, { sLevel }, tostring(level)))
    end
    local totalCellView = CreateTextView(api.util.formatMoney(0), { sLevel, "sRight" }, rowId .. COLUMN_TOTAL)
    table.insert(row, LayoutComponentsHorizontally({ totalCellView }, { sLevel }, tostring(level)))

    financeTable:addRow(row)
end

function AddSummaryLineToTable(labelComponents, id, sLevel)
    local row = {}

    table.insert(row, LayoutComponentsHorizontally(labelComponents, { sLevel }, "0"))
    
    local cellView = CreateTextView(api.util.formatMoney(0), { sLevel, "sRight" }, id)
    table.insert(row, LayoutComponentsHorizontally({ cellView }, { sLevel }, "0"))

    summaryTable:addRow(row)
end

function AddTransportCategoriesToFinanceTable(transportType)
    -- level 0
    local labelView = CreateTextView(_(transportType), { "sLevel0", "sLeft" }, "")
    AddTransportCategoryLineToFinanceTable({ CreateExpandButton(financeTable, 0), labelView }, transportType .. CAT_TOTAL, "sLevel0", 0)

    -- level 1
    for i, level1Category in ipairs(TRANSPORT_CATEGORIES_LEVEL1) do
        if (#TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            labelView = CreateTextView(_(level1Category), { "sLevel1", "sLeft", "sLevelPadding" }, "")
            AddTransportCategoryLineToFinanceTable({ labelView }, transportType .. level1Category, "sLevel1", 1)
        else
            labelView = CreateTextView(_(level1Category), { "sLevel1", "sLeft" }, "")
            AddTransportCategoryLineToFinanceTable({ CreateExpandButton(financeTable, 1), labelView }, transportType .. level1Category, "sLevel1", 1)

            -- level 2
            for j, level2Category in ipairs(TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if IsCategoryAllowedForTransportType(transportType, level2Category) then
                    labelView = CreateTextView(_(level2Category), { "sLevel2", "sLeft", "sLevelPadding" }, "")
                    AddTransportCategoryLineToFinanceTable({ labelView }, transportType .. level2Category, "sLevel2", 2)
                end
            end
        end
    end

    labelView = CreateTextView(_(CAT_CASHFLOW), { "sLevel1", "sRight" }, "")
    AddTransportCategoryLineToFinanceTable({ labelView }, transportType .. CAT_CASHFLOW, "sLevel1", 0)
end

function AddFinanceTableHeaders()
    local row = {}

    table.insert(row, CreateTextView("", { "sHeader", "sRight" }, ""))
    for i = 1, NUMBER_OF_YEARS_COLUMNS do
        table.insert(row, CreateTextView(tostring(GetYearFromYearIndex(i)), { "sHeader", "sRight" }, COLUMN_YEAR .. i))
    end
    table.insert(row, CreateTextView(_(COLUMN_TOTAL), { "sHeader", "sRight" }, COLUMN_TOTAL))

    financeTable:addRow(row)
end

function InitFinanceTable()
    financeTable = api.gui.comp.Table.new(NUMBER_OF_YEARS_COLUMNS + 2, "NONE")
    financeTable:setId("myFinanceTable")
    financeTable:setName("myFinanceTable")

    AddFinanceTableHeaders()

    for j = 1, #TRANSPORT_TYPES do
        AddTransportCategoriesToFinanceTable(TRANSPORT_TYPES[j])
    end
end

function InitSummaryTable()
    summaryTable = api.gui.comp.Table.new(2, "NONE")
    summaryTable:setId("mySummaryTable")
    summaryTable:setName("mySummaryTable")
    summaryTable:setStyleClassList({"mySummaryTable"})

    local profitView = CreateTextView(_(CAT_PROFIT), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ profitView }, "profitCell", "mySummaryTableLine")
    local loanView = CreateTextView(_(CAT_LOAN), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ loanView }, "loanCell", "mySummaryTableLine")
    local interestView = CreateTextView(_(CAT_INTERESTS), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ interestView }, "interestCell", "mySummaryTableLine")
    local othersView = CreateTextView(_(CAT_OTHERS), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ othersView }, "othersCell", "mySummaryTableLine")
    local totalView = CreateTextView(_(CAT_BALANCE), { "mySummaryTableLineTotalLabel", "sLeft" }, "")
    AddSummaryLineToTable({ totalView }, "totalCell", "mySummaryTableLineTotal")
end

function InitFinanceTab()
    financeTabWindow = api.gui.util.getById("menu.finances.category")
    financeTabWindow:getParent():getParent():setSize(api.gui.util.Size.new(1100, 800))
    financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
        guiUpdate = visible
    end)

    InitFinanceTable()
    InitSummaryTable()

    local financeTableLayout = financeTabWindow:getTab(0):getLayout()
    --replace current finance table
    financeTableLayout:removeItem(financeTableLayout:getItem(0))
    financeTableLayout:insertItem(financeTable, 0)

    --replace current summary table
    financeTableLayout:removeItem(financeTableLayout:getItem(3))
    financeTableLayout:insertItem(summaryTable, 3)
end

function UpdateFinanceTable(currentYearOnly)
    for i, transportType in ipairs(TRANSPORT_TYPES) do
        if currentYearOnly then
            RefreshTransportCategoryValues(transportType, GetJournal(GetCurrentGameYear()), NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, NUMBER_OF_YEARS_COLUMNS do
                local year = GetYearFromYearIndex(j)
                RefreshTransportCategoryValues(transportType, GetJournal(year), j)
                api.gui.util.getById(COLUMN_YEAR .. j):setText(tostring(year))
            end
        end
        RefreshTransportCategoryValues(transportType, GetJournal(0), COLUMN_TOTAL)
    end
end

function UpdateSummaryTable()
    local overallJournal = GetJournal(0)
    local profit = GetValueFromJournal(overallJournal, TRANSPORT_TYPE_ALL, CAT_TOTAL)
    local balance = GetCurrentBalance()
    UpdateCellValue(profit, "profitCell")
    UpdateCellValue(overallJournal.loan, "loanCell")
    UpdateCellValue(overallJournal.interest, "interestCell")
    UpdateCellValue(balance - (profit + overallJournal.loan + overallJournal.interest), "othersCell")
    UpdateCellValue(balance, "totalCell")
end

-- ***************************
-- ** Main
-- ***************************
function data()
    return {
        save = function()
        end,
        load = function()
        end,
        guiInit = function()
            InitFinanceTab()
        end,
        guiUpdate = function()
            local currentBalance = GetCurrentBalance()
            local currentYear = GetCurrentGameYear()
            if guiUpdate and financeTabWindow:getCurrentTab() == 0 and (currentBalance ~= lastBalance or currentYear ~= lastYear) then
                UpdateFinanceTable(currentYear == lastYear)
                UpdateSummaryTable()
                lastYear = currentYear
                lastBalance = currentBalance
            end
        end,
    }
end
