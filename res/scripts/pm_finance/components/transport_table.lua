local constants = require "pm_finance/constants"
local transport = require "pm_finance/constants/transport"
local categories = require "pm_finance/constants/categories"
local columns = require "pm_finance/constants/columns"
local styles = require "pm_finance/constants/styles"

local guiTextView = require "pm_finance/gui/text_view"
local guiTableView = require "pm_finance/gui/table_view"
local guiLayout = require "pm_finance/gui/layout"
local guiButton = require "pm_finance/gui/button"
local guiComponent = require "pm_finance/gui/component"

local engine = require "pm_finance/functions"
local ui_functions = require "pm_finance/ui_functions"

local ids = { tableId = "pm-myFinanceTable" }
local constantsT = {}
constantsT.TransportTable = { Id = "pm-transportTable", Name =  "TransportTable"}

constantsT.TRANSPORT_CATEGORIES_LEVEL1 =
{
    categories.constants.CAT_INCOME,
    categories.constants.CAT_MAINTENANCE,
    categories.constants.CAT_INVESTMENTS,
    categories.constants.CAT_TOTAL
}

constantsT.TRANSPORT_CATEGORIES_LEVEL2 =
{
    [categories.constants.CAT_INCOME] = {},
    [categories.constants.CAT_MAINTENANCE] = { categories.constants.CAT_MAINTENANCE_VEHICLES, categories.constants.CAT_MAINTENANCE_INFRASTRUCTURE },
    [categories.constants.CAT_INVESTMENTS] = { categories.constants.CAT_INVESTMENTS_VEHICLES, categories.constants.CAT_INVESTMENTS_INFRASTRUCTURE,
                                               categories.constants.CAT_INVESTMENTS_TRACKS, categories.constants.CAT_INVESTMENTS_ROADS },
    [categories.constants.CAT_TOTAL] = { categories.constants.CAT_CASHFLOW, categories.constants.CAT_MARGIN }
}

local functions = {}

function functions.CreateTransportTable(numberOfColumns, transportType)
    local financeTable = guiTableView.functions.CreateTableView(numberOfColumns, GetTableId(transportType), constantsT.TransportTable.Name)
    AddTransportTableHeaders(financeTable, transportType)

    AddTransportCategoriesToFinanceTable(financeTable, transportType)

    return financeTable
end

function AddTransportTableHeaders(financeTable, transportType)
    local row = {}

    local text = _(transportType)
    local id = GetHeaderColumnId(columns.constants.COLUMN_LABEL, transportType)
    local styleList = { styles.table.HEADER, styles.text.LEFT_ALIGNMENT }
    table.insert(row, guiTextView.functions.CreateTextView(text, id, styleList ))
    
    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        text = tostring(engine.GetYearFromYearIndex(i))
        id = GetHeaderColumnId(columns.constants.COLUMN_YEAR .. i, transportType)
        styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
        table.insert(row, guiTextView.functions.CreateTextView(text, id, styleList ))
    end
    
    text = _(columns.constants.COLUMN_TOTAL)
    id = GetHeaderColumnId(columns.constants.COLUMN_TOTAL, transportType)
    styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
    table.insert(row, guiTextView.functions.CreateTextView(text, id, styleList ))

    guiTableView.functions.SetHeader(financeTable, row)
end

function AddTransportCategoriesToFinanceTable(financeTable, transportType)
    -- level 1
    for i, level1Category in ipairs(constantsT.TRANSPORT_CATEGORIES_LEVEL1) do
        if (#constantsT.TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, level1Category, 1)
        else
            AddTransportCategoryLineToFinanceTable(financeTable, true, transportType, level1Category, 1)
            -- level 2
            for j, level2Category in ipairs(constantsT.TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if IsCategoryAllowedForTransportType(transportType, level2Category) then
                    AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, level2Category, 2)
                end
            end
        end
    end
end

function AddTransportCategoryLineToFinanceTable(financeTable, isExpandable, transportType, category, level)
    local row = {}

    local comp = CreateCategotryLineLabelComponent(financeTable, category, transportType, isExpandable, level)
    table.insert(row, comp)

    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        local id = GetTableControlId(columns.constants.COLUMN_YEAR..i, category, transportType)
        comp = CreateCategotryLineValueComponent(category, id)
        table.insert(row, comp)
    end
    
    local id = GetTableControlId(columns.constants.COLUMN_TOTAL, category, transportType)
    comp = CreateCategotryLineValueComponent(category, id)
    table.insert(row, comp)

    financeTable:addRow(row)
end

function CreateCategotryLineLabelComponent(financeTable, category, transportType, isExpandable, level)
    local components = {}

    local text = _(category)
    local id = GetTableControlId(columns.constants.COLUMN_LABEL, category, transportType)
    local labelView = guiTextView.functions.CreateTextView(text, id, { styles.table.CELL, styles.text.LEFT_ALIGNMENT } )

    local componentStyleList = { GetStyleForLineLevel(level), styles.table.CELL }
    if (category == categories.constants.CAT_TOTAL) then
        table.insert(componentStyleList, styles.table.TOTAL)
    end

    if isExpandable then
        table.insert(componentStyleList, styles.table.EXPANDABLE)
        table.insert(components, guiButton.functions.CreateExpandButton(financeTable, financeTable:getNumRows(), level))
    end
    ui_functions.SetTooltipByCategory(labelView, category)

    table.insert(components, labelView)
    
    local comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, components, tostring(level))
    comp:setStyleClassList(componentStyleList)

    return comp
end

function CreateCategotryLineValueComponent(category, id)
    local styleList = { styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
    local cellView = guiTextView.functions.CreateTextView("", id, styleList )

    ui_functions.SetTooltipByCategory(cellView, category)
    local comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { cellView }, tostring(level))
    comp:setStyleClassList({ styles.table.CELL })
    
    if (category == categories.constants.CAT_TOTAL) then
        comp:addStyleClass(styles.table.TOTAL)
    end

    return comp
end

function GetStyleForLineLevel(level)
    if (level == 1) then
        return styles.table.LEVEL_1
    elseif (level == 2) then
        return styles.table.LEVEL_2
    end
end

function functions.UpdateTableValues(currentYearOnly)
    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        if currentYearOnly then
            RefreshTransportCategoryValues(transportType, engine.GetJournal(functions.GetCurrentGameYear()), columns.constants.COLUMN_YEAR .. columns.constants.NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                local year = engine.GetYearFromYearIndex(j)
                RefreshTransportCategoryValues(transportType, engine.GetJournal(year), columns.constants.COLUMN_YEAR .. j)
                local id = GetHeaderColumnId(columns.constants.COLUMN_YEAR .. j, transportType)
                local textView = guiComponent.functions.FindById(id)
                guiTextView.functions.SetText(textView, tostring(year))
            end
        end
        RefreshTransportCategoryValues(transportType, engine.GetJournal(0), columns.constants.COLUMN_TOTAL)
    end
end

function RefreshTransportCategoryValues(transportType, journal, column)
    --total
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_TOTAL, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_TOTAL),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --income
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_INCOME, transportType), 
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_INCOME),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --maintenance
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_MAINTENANCE, transportType), 
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_MAINTENANCE_VEHICLES, transportType), 
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE_VEHICLES),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_MAINTENANCE_INFRASTRUCTURE, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE_INFRASTRUCTURE),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --investment
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_INVESTMENTS, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_INVESTMENTS_VEHICLES, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_VEHICLES),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    if IsCategoryAllowedForTransportType(transportType, categories.constants.CAT_INVESTMENTS_TRACKS) then
        guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_INVESTMENTS_TRACKS, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_TRACKS),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    end
    if IsCategoryAllowedForTransportType(transportType, categories.constants.CAT_INVESTMENTS_ROADS) then
        guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_INVESTMENTS_ROADS, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_ROADS),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    end
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_INVESTMENTS_INFRASTRUCTURE, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_INFRASTRUCTURE),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --cashflow
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_CASHFLOW, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_CASHFLOW),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
	--margin									
    guiTextView.functions.SetFormattedText(GetTableControlId(column, categories.constants.CAT_MARGIN, transportType),
                                        engine.GetValueFromJournal(journal, transportType, categories.constants.CAT_MARGIN),
                                        guiTextView.constants.TEXT_TYPE.PERCENTAGE)
end

function IsCategoryAllowedForTransportType(transportType, category)
    if transportType == transport.constants.TRANSPORT_TYPE_ALL then
        return true
    end
    if category == constants.CAT_INVESTMENTS_TRACKS and transportType ~= transport.constants.TRANSPORT_TYPE_RAIL then
        return false
    elseif category == constants.CAT_INVESTMENTS_ROADS and transportType ~= transport.constants.TRANSPORT_TYPE_ROAD then
        return false
    end
    return true
end

function GetTableId(transportType)
    return constantsT.TransportTable.Id .. "." .. transportType
end

function GetHeaderColumnId(column, transportType)
    return "pm-" .. transportType .. "." .. column .. ".Header"
end

function GetTableControlId(column, category, transportType)
    if not transportType then
        if not category then
            return "pm-" .. column
        end
        return "pm-" .. category .. "." .. column
    end
    return "pm-" .. transportType .. "." .. category .. "." .. column
end

local result = {}
result.ids = ids
result.functions = functions

return result
