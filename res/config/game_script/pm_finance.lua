local constants = require "pm_finance/constants"
local functions = require "pm_finance/functions"
local ui_functions = require "pm_finance/ui_functions"

local financeTabWindow = nil
local financeTable = nil
local summaryTable = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0

function RefreshTransportCategoryValues(transportType, journal, column)
    --total
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_TOTAL), 
                                ui_functions.GetTableControlId(column, constants.CAT_TOTAL, transportType))
    --income
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_INCOME), 
                                ui_functions.GetTableControlId(column, constants.CAT_INCOME, transportType))
    --maintenance
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE), 
                                ui_functions.GetTableControlId(column, constants.CAT_MAINTENANCE, transportType))
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_VEHICLES), 
                                ui_functions.GetTableControlId(column, constants.CAT_MAINTENANCE_VEHICLES, transportType))
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_INFRASTRUCTURE), 
                                ui_functions.GetTableControlId(column, constants.CAT_MAINTENANCE_INFRASTRUCTURE, transportType))
    --investment
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS), 
                                ui_functions.GetTableControlId(column, constants.CAT_INVESTMENTS, transportType))
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_VEHICLES), 
                                ui_functions.GetTableControlId(column, constants.CAT_INVESTMENTS_VEHICLES, transportType))
    if functions.IsCategoryAllowedForTransportType(transportType, constants.CAT_INVESTMENTS_TRACKS) then
        ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_TRACKS), 
                                    ui_functions.GetTableControlId(column, constants.CAT_INVESTMENTS_TRACKS, transportType))
    end
    if functions.IsCategoryAllowedForTransportType(transportType, constants.CAT_INVESTMENTS_ROADS) then
        ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_ROADS), 
                                    ui_functions.GetTableControlId(column, constants.CAT_INVESTMENTS_ROADS, transportType))
    end
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_INFRASTRUCTURE), 
                                ui_functions.GetTableControlId(column, constants.CAT_INVESTMENTS_INFRASTRUCTURE, transportType))
    --cashflow
    ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transportType, constants.CAT_CASHFLOW), 
                                ui_functions.GetTableControlId(column, constants.CAT_CASHFLOW, transportType))
    
end

function AddTransportCategoryLineToFinanceTable(isExpandable, transportType, category, sLevel, level)
    local row = {}

    local components = {}
    local labelTranslationKey = category
    if category == constants.CAT_TOTAL then
        labelTranslationKey = transportType
    end
    local labelView = ui_functions.CreateTextView(_(labelTranslationKey), 
                                                { sLevel, constants.STYLE_TABLE_CELL, constants.STYLE_TEXT_LEFT }, 
                                                ui_functions.GetTableControlId(constants.COLUMN_LABEL, category, transportType))
    if isExpandable then
        table.insert(components, ui_functions.CreateExpandButton(financeTable, level))
    elseif level > 0 then
        labelView:addStyleClass(constants.STYLE_LEVEL_PADDING)
    else
        labelView:removeStyleClass(constants.STYLE_TEXT_LEFT)
        labelView:addStyleClass(constants.STYLE_TEXT_RIGHT)
    end
    ui_functions.SetTooltipByCategory(labelView, category)
    table.insert(components, labelView)
    table.insert(row, ui_functions.LayoutComponentsHorizontally(components, { sLevel, constants.STYLE_TABLE_CELL }, tostring(level)))

    for i = 1, constants.NUMBER_OF_YEARS_COLUMNS do
        local yearCellView = ui_functions.CreateTextView("", { sLevel, constants.STYLE_TABLE_CELL, constants.STYLE_TEXT_RIGHT }, 
                                                        ui_functions.GetTableControlId(constants.COLUMN_YEAR..i, category, transportType))
        ui_functions.SetTooltipByCategory(yearCellView, category)
        table.insert(row, ui_functions.LayoutComponentsHorizontally({ yearCellView }, { sLevel, constants.STYLE_TABLE_CELL }, tostring(level)))
    end
    local totalCellView = ui_functions.CreateTextView("", { sLevel, constants.STYLE_TABLE_CELL, constants.STYLE_TEXT_RIGHT }, 
                                                    ui_functions.GetTableControlId(constants.COLUMN_TOTAL, category, transportType))
    ui_functions.SetTooltipByCategory(totalCellView, category)
    table.insert(row, ui_functions.LayoutComponentsHorizontally({ totalCellView }, { sLevel, constants.STYLE_TABLE_CELL }, tostring(level)))

    financeTable:addRow(row)
end

function AddSummaryLineToTable(category, styleLevel)
    local row = {}

    local labelView = ui_functions.CreateTextView(_(category), 
                                                { styleLevel, constants.STYLE_SUMMARY_LABEL, constants.STYLE_TABLE_CELL, constants.STYLE_TEXT_LEFT }, 
                                                ui_functions.GetTableControlId(constants.COLUMN_LABEL, category))
    ui_functions.SetTooltipByCategory(labelView, category)
    local valueView = ui_functions.CreateTextView("", { styleLevel, constants.STYLE_TABLE_CELL, constants.STYLE_TEXT_RIGHT }, 
                                                ui_functions.GetTableControlId(constants.COLUMN_TOTAL, category))
    ui_functions.SetTooltipByCategory(valueView, category)
    
    table.insert(row, ui_functions.LayoutComponentsHorizontally({ labelView }, { styleLevel, constants.STYLE_TABLE_CELL }, "0"))
    table.insert(row, ui_functions.LayoutComponentsHorizontally({ valueView }, { styleLevel, constants.STYLE_TABLE_CELL }, "0"))

    summaryTable:addRow(row)
end

function AddTransportCategoriesToFinanceTable(transportType)
    -- level 0
    AddTransportCategoryLineToFinanceTable(true, transportType, constants.CAT_TOTAL, constants.STYLE_LEVEL_0, 0)

    -- level 1
    for i, level1Category in ipairs(constants.TRANSPORT_CATEGORIES_LEVEL1) do
        if (#constants.TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            AddTransportCategoryLineToFinanceTable(false, transportType, level1Category, constants.STYLE_LEVEL_1, 1)
        else
            AddTransportCategoryLineToFinanceTable(true, transportType, level1Category, constants.STYLE_LEVEL_1, 1)
            -- level 2
            for j, level2Category in ipairs(constants.TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if functions.IsCategoryAllowedForTransportType(transportType, level2Category) then
                    AddTransportCategoryLineToFinanceTable(false, transportType, level2Category, constants.STYLE_LEVEL_2, 2)
                end
            end
        end
    end

    AddTransportCategoryLineToFinanceTable(false, transportType, constants.CAT_CASHFLOW, constants.STYLE_LEVEL_1, 0)
end

function AddFinanceTableHeaders()
    local row = {}

    table.insert(row, ui_functions.CreateTextView("", { constants.STYLE_TABLE_HEADER, constants.STYLE_TEXT_RIGHT }, 
                                                ui_functions.GetTableControlId(constants.COLUMN_LABEL)))
    for i = 1, constants.NUMBER_OF_YEARS_COLUMNS do
        table.insert(row, ui_functions.CreateTextView(tostring(functions.GetYearFromYearIndex(i)), 
                                                    { constants.STYLE_TABLE_HEADER, constants.STYLE_TEXT_RIGHT }, 
                                                    ui_functions.GetTableControlId(constants.COLUMN_YEAR .. i)))
    end
    table.insert(row, ui_functions.CreateTextView(_(constants.COLUMN_TOTAL), 
                                                { constants.STYLE_TABLE_HEADER, constants.STYLE_TEXT_RIGHT }, 
                                                ui_functions.GetTableControlId(constants.COLUMN_TOTAL)))

    financeTable:setHeader(row)
end

function InitFinanceTable()
    financeTable = api.gui.comp.Table.new(constants.NUMBER_OF_YEARS_COLUMNS + 2, "NONE")
    financeTable:setId("pm-myFinanceTable")
    financeTable:setName("pm-myFinanceTable")

    AddFinanceTableHeaders()

    for j = 1, #constants.TRANSPORT_TYPES do
        AddTransportCategoriesToFinanceTable(constants.TRANSPORT_TYPES[j])
    end
end

function InitSummaryTable()
    summaryTable = api.gui.comp.Table.new(2, "NONE")
    summaryTable:setId("pm-mySummaryTable")
    summaryTable:setName("pm-mySummaryTable")
    summaryTable:setStyleClassList({ constants.STYLE_SUMMARY_TABLE })

    AddSummaryLineToTable(constants.CAT_PROFIT, constants.STYLE_LEVEL_1)
    AddSummaryLineToTable(constants.CAT_LOAN, constants.STYLE_LEVEL_1)
    AddSummaryLineToTable(constants.CAT_INTEREST, constants.STYLE_LEVEL_1)
    AddSummaryLineToTable(constants.CAT_OTHER, constants.STYLE_LEVEL_1)
    AddSummaryLineToTable(constants.CAT_BALANCE, constants.STYLE_LEVEL_0)
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
    for i, transportType in ipairs(constants.TRANSPORT_TYPES) do
        if currentYearOnly then
            RefreshTransportCategoryValues(transportType, functions.GetJournal(functions.GetCurrentGameYear()), constants.COLUMN_YEAR .. constants.NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, constants.NUMBER_OF_YEARS_COLUMNS do
                local year = functions.GetYearFromYearIndex(j)
                RefreshTransportCategoryValues(transportType, functions.GetJournal(year), constants.COLUMN_YEAR .. j)
                api.gui.util.getById(ui_functions.GetTableControlId(constants.COLUMN_YEAR .. j)):setText(tostring(year))
            end
        end
        RefreshTransportCategoryValues(transportType, functions.GetJournal(0), constants.COLUMN_TOTAL)
    end
end

function UpdateSummaryTable()
    local overallJournal = functions.GetJournal(0)
    local profit = functions.GetValueFromJournal(overallJournal, constants.TRANSPORT_TYPE_ALL, constants.CAT_TOTAL)
    local balance = functions.GetCurrentBalance()
    ui_functions.UpdateCellValue(profit, ui_functions.GetTableControlId(constants.COLUMN_TOTAL, constants.CAT_PROFIT))
    ui_functions.UpdateCellValue(overallJournal.loan, ui_functions.GetTableControlId(constants.COLUMN_TOTAL, constants.CAT_LOAN))
    ui_functions.UpdateCellValue(overallJournal.interest, ui_functions.GetTableControlId(constants.COLUMN_TOTAL, constants.CAT_INTEREST))
    ui_functions.UpdateCellValue(balance - (profit + overallJournal.loan + overallJournal.interest), ui_functions.GetTableControlId(constants.COLUMN_TOTAL, constants.CAT_OTHER))
    ui_functions.UpdateCellValue(balance, ui_functions.GetTableControlId(constants.COLUMN_TOTAL, constants.CAT_BALANCE))
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
                for j = 1, constants.NUMBER_OF_YEARS_COLUMNS do
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
            InitFinanceTab()
        end,
        guiUpdate = function()
            local currentBalance = functions.GetCurrentBalance()
            local currentYear = functions.GetCurrentGameYear()
            if guiUpdate and financeTabWindow:getCurrentTab() == 0 and (currentBalance ~= lastBalance or currentYear ~= lastYear) then
                UpdateFinanceTable(currentYear == lastYear)
                UpdateSummaryTable()
                lastYear = currentYear
                lastBalance = currentBalance
            end
        end,
    }
end
