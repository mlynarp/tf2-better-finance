local transport = require "pm_finance/constants/transport"
local categories = require "pm_finance/constants/categories"
local columns = require "pm_finance/constants/columns"
local params = require "pm_finance/constants/params"
local styles = require "pm_finance/constants/styles"

local engineCalendar = require "pm_finance/engine/calendar"
local engineJournal = require "pm_finance/engine/journal"

local guiTextView = require "pm_finance/gui/text_view"
local guiTableView = require "pm_finance/gui/table_view"
local guiLayout = require "pm_finance/gui/layout"
local guiButton = require "pm_finance/gui/button"
local guiComponent = require "pm_finance/gui/component"

local constants = {}
local functions = {}

constants.TransportTable = { Id = "pm-transportTable", Name =  "TransportTable"}

constants.TRANSPORT_CATEGORIES_LEVEL1 =
{
    categories.constants.INCOME,
    categories.constants.MAINTENANCE,
    categories.constants.INVESTMENTS,
    categories.constants.TOTAL
}

constants.TRANSPORT_CATEGORIES_LEVEL2 =
{
    [categories.constants.INCOME] = {},
    [categories.constants.MAINTENANCE] = { categories.constants.MAINTENANCE_VEHICLES, categories.constants.MAINTENANCE_INFRASTRUCTURE },
    [categories.constants.INVESTMENTS] = { categories.constants.INVESTMENTS_VEHICLES, categories.constants.INVESTMENTS_INFRASTRUCTURE,
                                               categories.constants.INVESTMENTS_TRACKS, categories.constants.INVESTMENTS_ROADS },
    [categories.constants.TOTAL] = { categories.constants.CASHFLOW, categories.constants.MARGIN }
}



function functions.CreateTransportTable(transportType)
    local numberOfColumns = params.constants.NUMBER_OF_YEARS_COLUMNS + 2
    local financeTable = guiTableView.functions.CreateTableView(numberOfColumns, functions.GetTableId(transportType), constants.TransportTable.Name)
    functions.AddTransportTableHeaders(financeTable, transportType)

    functions.AddTransportCategoriesToFinanceTable(financeTable, transportType)

    financeTable:setColWidth(0, 300)

    for j = 1, numberOfColumns - 1 do
        financeTable:setColWeight(j, 1)
    end

    return financeTable
end

function functions.AddTransportTableHeaders(financeTable, transportType)
    local row = {}

    local text = _(transportType)
    local id = functions.GetHeaderColumnId(columns.constants.LABEL, transportType)
    local styleList = { styles.table.HEADER, styles.text.LEFT_ALIGNMENT }
    table.insert(row, guiTextView.functions.CreateTextView(text, id, styleList ))
    
    for i = 1, params.constants.NUMBER_OF_YEARS_COLUMNS do
        text = tostring(engineCalendar.functions.GetYearFromYearIndex(i))
        id = functions.GetHeaderColumnId(columns.constants.YEAR .. i, transportType)
        styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
        table.insert(row, guiTextView.functions.CreateTextView(text, id, styleList ))
    end
    
    text = _(columns.constants.TOTAL)
    id = functions.GetHeaderColumnId(columns.constants.TOTAL, transportType)
    styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
    table.insert(row, guiTextView.functions.CreateTextView(text, id, styleList ))

    guiTableView.functions.SetHeader(financeTable, row)
end

function functions.AddTransportCategoriesToFinanceTable(financeTable, transportType)
    -- level 1
    for i, level1Category in ipairs(constants.TRANSPORT_CATEGORIES_LEVEL1) do
        if (#constants.TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            functions.AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, level1Category, 1)
        else
            functions.AddTransportCategoryLineToFinanceTable(financeTable, true, transportType, level1Category, 1)
            -- level 2
            for j, level2Category in ipairs(constants.TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if functions.IsCategoryAllowedForTransportType(transportType, level2Category) then
                    functions.AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, level2Category, 2)
                end
            end
        end
    end
end

function functions.AddTransportCategoryLineToFinanceTable(financeTable, isExpandable, transportType, category, level)
    local row = {}

    local comp = functions.CreateCategotryLineLabelComponent(financeTable, category, transportType, isExpandable, level)
    table.insert(row, comp)

    for i = 1, params.constants.NUMBER_OF_YEARS_COLUMNS do
        local id = functions.GetTableControlId(columns.constants.YEAR..i, category, transportType)
        comp = functions.CreateCategotryLineValueComponent(category, id)
        table.insert(row, comp)
    end
    
    local id = functions.GetTableControlId(columns.constants.TOTAL, category, transportType)
    comp = functions.CreateCategotryLineValueComponent(category, id)
    table.insert(row, comp)

    financeTable:addRow(row)
end

function functions.CreateCategotryLineLabelComponent(financeTable, category, transportType, isExpandable, level)
    local components = {}

    local text = _(category)
    local id = functions.GetTableControlId(columns.constants.LABEL, category, transportType)
    local labelView = guiTextView.functions.CreateTextView(text, id, { styles.table.CELL, styles.text.LEFT_ALIGNMENT } )

    local componentStyleList = { functions.GetStyleForLineLevel(level), styles.table.CELL }
    if (category == categories.constants.TOTAL) then
        table.insert(componentStyleList, styles.table.TOTAL)
    end

    if isExpandable then
        table.insert(componentStyleList, styles.table.EXPANDABLE)
        table.insert(components, guiButton.functions.CreateExpandButton(financeTable, financeTable:getNumRows(), level))
    end
    guiComponent.functions.SetTooltipByCategory(labelView, category)

    table.insert(components, labelView)
    
    local comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, components, tostring(level))
    comp:setStyleClassList(componentStyleList)

    return comp
end

function functions.CreateCategotryLineValueComponent(category, id)
    local styleList = { styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
    local cellView = guiTextView.functions.CreateTextView("", id, styleList )

    guiComponent.functions.SetTooltipByCategory(cellView, category)
    local comp = guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, { cellView }, tostring(level))
    comp:setStyleClassList({ styles.table.CELL })
    
    if (category == categories.constants.TOTAL) then
        comp:addStyleClass(styles.table.TOTAL)
    end

    return comp
end

function functions.GetStyleForLineLevel(level)
    if (level == 1) then
        return styles.table.LEVEL_1
    elseif (level == 2) then
        return styles.table.LEVEL_2
    end
end

function functions.UpdateTableValues(currentYearOnly, transportType)
    if currentYearOnly then
        functions.RefreshTransportCategoryValues(transportType, engineJournal.functions.GetJournal(engineCalendar.functions.GetCurrentGameYear()), columns.constants.YEAR .. params.constants.NUMBER_OF_YEARS_COLUMNS)
    else
        for j = 1, params.constants.NUMBER_OF_YEARS_COLUMNS do
            local year = engineCalendar.functions.GetYearFromYearIndex(j)
            functions.RefreshTransportCategoryValues(transportType, engineJournal.functions.GetJournal(year), columns.constants.YEAR .. j)
            local id = functions.GetHeaderColumnId(columns.constants.YEAR .. j, transportType)
            local textView = guiComponent.functions.FindById(id)
            guiTextView.functions.SetText(textView, tostring(year))
        end
    end
    functions.RefreshTransportCategoryValues(transportType, engineJournal.functions.GetJournal(0), columns.constants.TOTAL)
end

function functions.RefreshTransportCategoryValues(transportType, journal, column)
    --total
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.TOTAL, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.TOTAL),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --income
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.INCOME, transportType), 
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.INCOME),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --maintenance
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.MAINTENANCE, transportType), 
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.MAINTENANCE),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.MAINTENANCE_VEHICLES, transportType), 
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.MAINTENANCE_VEHICLES),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.MAINTENANCE_INFRASTRUCTURE, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.MAINTENANCE_INFRASTRUCTURE),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --investment
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.INVESTMENTS, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.INVESTMENTS),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.INVESTMENTS_VEHICLES, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.INVESTMENTS_VEHICLES),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    if functions.IsCategoryAllowedForTransportType(transportType, categories.constants.INVESTMENTS_TRACKS) then
        guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.INVESTMENTS_TRACKS, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.INVESTMENTS_TRACKS),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    end
    if functions.IsCategoryAllowedForTransportType(transportType, categories.constants.INVESTMENTS_ROADS) then
        guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.INVESTMENTS_ROADS, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.INVESTMENTS_ROADS),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    end
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.INVESTMENTS_INFRASTRUCTURE, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.INVESTMENTS_INFRASTRUCTURE),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
    --cashflow
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.CASHFLOW, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.CASHFLOW),
                                        guiTextView.constants.TEXT_TYPE.MONEY)
	--margin									
    guiTextView.functions.SetFormattedText(functions.GetTableControlId(column, categories.constants.MARGIN, transportType),
                                        engineJournal.functions.GetValueFromJournal(journal, transportType, categories.constants.MARGIN),
                                        guiTextView.constants.TEXT_TYPE.PERCENTAGE)
end

function functions.IsCategoryAllowedForTransportType(transportType, category)
    if transportType == transport.constants.ALL then
        return true
    end
    if category == categories.constants.INVESTMENTS_TRACKS and transportType ~= transport.constants.RAIL then
        return false
    elseif category == categories.constants.INVESTMENTS_ROADS and transportType ~= transport.constants.ROAD then
        return false
    end
    return true
end

function functions.GetTableId(transportType)
    return constants.TransportTable.Id .. "." .. transportType
end

function functions.GetHeaderColumnId(column, transportType)
    return functions.GetTableControlId(column, "Header", transportType)
end

function functions.GetTableControlId(column, category, transportType)
    return constants.TransportTable.Id .. "." .. transportType .. "." .. category .. "." .. column
end

local result = {}
result.constants = constants
result.functions = functions

return result
