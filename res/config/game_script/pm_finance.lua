require "pm_finance_constants"
require "pm_finance_functions"
require "pm_finance_ui_functions"

local financeTabWindow = nil
local financeTable = nil
local summaryTable = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0

function RefreshTransportCategoryValues(transportType, journal, column)
    --total
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_TOTAL), GetTableControlId(column, CAT_TOTAL, transportType))
    --income
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INCOME), GetTableControlId(column, CAT_INCOME, transportType))
    --maintenance
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE), GetTableControlId(column, CAT_MAINTENANCE, transportType))
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_VEHICLES), GetTableControlId(column, CAT_MAINTENANCE_VEHICLES, transportType))
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_INFRASTRUCTURE), GetTableControlId(column, CAT_MAINTENANCE_INFRASTRUCTURE, transportType))
    --investment
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS), GetTableControlId(column, CAT_INVESTMENTS, transportType))
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_VEHICLES), GetTableControlId(column, CAT_INVESTMENTS_VEHICLES, transportType))
    if IsCategoryAllowedForTransportType(transportType, CAT_INVESTMENTS_TRACKS) then
        UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_TRACKS), GetTableControlId(column, CAT_INVESTMENTS_TRACKS, transportType))
    elseif IsCategoryAllowedForTransportType(transportType, CAT_INVESTMENTS_ROADS) then
        UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_ROADS), GetTableControlId(column, CAT_INVESTMENTS_ROADS, transportType))
    end
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_INFRASTRUCTURE), GetTableControlId(column, CAT_INVESTMENTS_INFRASTRUCTURE, transportType))
    --cashflow
    UpdateCellValue(GetValueFromJournal(journal, transportType, CAT_CASHFLOW), GetTableControlId(column, CAT_CASHFLOW, transportType))
    
end

function AddTransportCategoryLineToFinanceTable(isExpandable, transportType, category, sLevel, level)
    local row = {}

    local components = {}
    local labelTranslationKey = category
    if category == CAT_TOTAL then
        labelTranslationKey = transportType
    end
    local labelView = CreateTextView(_(labelTranslationKey), { sLevel, STYLE_TABLE_CELL, STYLE_TEXT_LEFT }, GetTableControlId(COLUMN_LABEL, category, transportType))
    if isExpandable then
        table.insert(components, CreateExpandButton(financeTable, level))
    elseif level > 0 then
        labelView:addStyleClass(STYLE_LEVEL_PADDING)
    else
        labelView:removeStyleClass(STYLE_TEXT_LEFT)
        labelView:addStyleClass(STYLE_TEXT_RIGHT)
    end
    SetTooltipByCategory(labelView, category)
    table.insert(components, labelView)
    table.insert(row, LayoutComponentsHorizontally(components, { sLevel, STYLE_TABLE_CELL }, tostring(level)))

    for i = 1, NUMBER_OF_YEARS_COLUMNS do
        local yearCellView = CreateTextView("", { sLevel, STYLE_TABLE_CELL, STYLE_TEXT_RIGHT }, GetTableControlId(COLUMN_YEAR..i, category, transportType))
        SetTooltipByCategory(yearCellView, category)
        table.insert(row, LayoutComponentsHorizontally({ yearCellView }, { sLevel, STYLE_TABLE_CELL }, tostring(level)))
    end
    local totalCellView = CreateTextView("", { sLevel, STYLE_TABLE_CELL, STYLE_TEXT_RIGHT }, GetTableControlId(COLUMN_TOTAL, category, transportType))
    SetTooltipByCategory(totalCellView, category)
    table.insert(row, LayoutComponentsHorizontally({ totalCellView }, { sLevel, STYLE_TABLE_CELL }, tostring(level)))

    financeTable:addRow(row)
end

function AddSummaryLineToTable(category, styleLevel)
    local row = {}

    local labelView = CreateTextView(_(category), { styleLevel, STYLE_SUMMARY_LABEL, STYLE_TABLE_CELL, STYLE_TEXT_LEFT }, GetTableControlId(COLUMN_LABEL, category))
    SetTooltipByCategory(labelView, category)
    local valueView = CreateTextView("", { styleLevel, STYLE_TABLE_CELL, STYLE_TEXT_RIGHT }, GetTableControlId(COLUMN_TOTAL, category))
    SetTooltipByCategory(valueView, category)
    
    table.insert(row, LayoutComponentsHorizontally({ labelView }, { styleLevel, STYLE_TABLE_CELL }, "0"))
    table.insert(row, LayoutComponentsHorizontally({ valueView }, { styleLevel, STYLE_TABLE_CELL }, "0"))

    summaryTable:addRow(row)
end

function AddTransportCategoriesToFinanceTable(transportType)
    -- level 0
    AddTransportCategoryLineToFinanceTable(true, transportType, CAT_TOTAL, STYLE_LEVEL_0, 0)

    -- level 1
    for i, level1Category in ipairs(TRANSPORT_CATEGORIES_LEVEL1) do
        if (#TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            AddTransportCategoryLineToFinanceTable(false, transportType, level1Category, STYLE_LEVEL_1, 1)
        else
            AddTransportCategoryLineToFinanceTable(true, transportType, level1Category, STYLE_LEVEL_1, 1)
            -- level 2
            for j, level2Category in ipairs(TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if IsCategoryAllowedForTransportType(transportType, level2Category) then
                    AddTransportCategoryLineToFinanceTable(false, transportType, level2Category, STYLE_LEVEL_2, 2)
                end
            end
        end
    end

    AddTransportCategoryLineToFinanceTable(false, transportType, CAT_CASHFLOW, STYLE_LEVEL_1, 0)
end

function AddFinanceTableHeaders()
    local row = {}

    table.insert(row, CreateTextView("", { STYLE_TABLE_HEADER, STYLE_TEXT_RIGHT }, GetTableControlId(COLUMN_LABEL)))
    for i = 1, NUMBER_OF_YEARS_COLUMNS do
        table.insert(row, CreateTextView(tostring(GetYearFromYearIndex(i)), { STYLE_TABLE_HEADER, STYLE_TEXT_RIGHT }, GetTableControlId(COLUMN_YEAR .. i)))
    end
    table.insert(row, CreateTextView(_(COLUMN_TOTAL), { STYLE_TABLE_HEADER, STYLE_TEXT_RIGHT }, GetTableControlId(COLUMN_TOTAL)))

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
    summaryTable:setStyleClassList({ STYLE_SUMMARY_TABLE })

    AddSummaryLineToTable(CAT_PROFIT, STYLE_LEVEL_1)
    AddSummaryLineToTable(CAT_LOAN, STYLE_LEVEL_1)
    AddSummaryLineToTable(CAT_INTEREST, STYLE_LEVEL_1)
    AddSummaryLineToTable(CAT_OTHER, STYLE_LEVEL_1)
    AddSummaryLineToTable(CAT_BALANCE, STYLE_LEVEL_0)
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
            RefreshTransportCategoryValues(transportType, GetJournal(GetCurrentGameYear()), COLUMN_YEAR .. NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, NUMBER_OF_YEARS_COLUMNS do
                local year = GetYearFromYearIndex(j)
                RefreshTransportCategoryValues(transportType, GetJournal(year), COLUMN_YEAR .. j)
                api.gui.util.getById(GetTableControlId(COLUMN_YEAR .. j)):setText(tostring(year))
            end
        end
        RefreshTransportCategoryValues(transportType, GetJournal(0), COLUMN_TOTAL)
    end
end

function UpdateSummaryTable()
    local overallJournal = GetJournal(0)
    local profit = GetValueFromJournal(overallJournal, TRANSPORT_TYPE_ALL, CAT_TOTAL)
    local balance = GetCurrentBalance()
    UpdateCellValue(profit, GetTableControlId(COLUMN_TOTAL, CAT_PROFIT))
    UpdateCellValue(overallJournal.loan, GetTableControlId(COLUMN_TOTAL, CAT_LOAN))
    UpdateCellValue(overallJournal.interest, GetTableControlId(COLUMN_TOTAL, CAT_INTEREST))
    UpdateCellValue(balance - (profit + overallJournal.loan + overallJournal.interest), GetTableControlId(COLUMN_TOTAL, CAT_OTHER))
    UpdateCellValue(balance, GetTableControlId(COLUMN_TOTAL, CAT_BALANCE))
end

-- ***************************
-- ** Main
-- ***************************
function data()
    return {
        save = function()
            return GameState
        end,
        load = function(data)
            if not data then
                local currentYear = GetCurrentGameYear()
                for j = 1, NUMBER_OF_YEARS_COLUMNS do
                    GameState[tostring(currentYear)] = GetYearStartTime(currentYear)
                    currentYear = currentYear - 1
                end
            else
                GameState = data
            end
        end,
        update = function()
            local currentYear = GetCurrentGameYear()
            if currentYear ~= lastYear then
                lastYear = currentYear
                if GameState[tostring(currentYear)] == nil then
                    GameState[tostring(currentYear)] = GetYearStartTime(currentYear)
                end
            end
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
