local constants = require "pm_finance/constants"
local transport = require "pm_finance/constants/transport"
local categories = require "pm_finance/constants/categories"
local columns = require "pm_finance/constants/columns"
local styles = require "pm_finance/constants/styles"

local textView = require "pm_finance/gui/text_view"
local tableView = require "pm_finance/gui/table_view"
local layout = require "pm_finance/gui/layout"
local guiButton = require "pm_finance/gui/button"

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
    local financeTable = tableView.functions.CreateTableView(numberOfColumns, GetTableId(transportType), constantsT.TransportTable.Name)
    AddTransportTableHeaders(financeTable, transportType)

    AddTransportCategoriesToFinanceTable(financeTable, transportType)

    return financeTable
end

function AddTransportTableHeaders(financeTable, transportType)
    local row = {}

    local text = _(transportType)
    local id = GetHeaderColumnId(columns.constants.COLUMN_LABEL, transportType)
    local styleList = { styles.table.HEADER, styles.text.LEFT_ALIGNMENT }
    table.insert(row, textView.functions.CreateTextView(text, id, styleList ))
    
    for i = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
        text = tostring(engine.GetYearFromYearIndex(i))
        id = GetHeaderColumnId(columns.constants.COLUMN_YEAR .. i, transportType)
        styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
        table.insert(row, textView.functions.CreateTextView(text, "", styleList ))
    end
    
    text = _(columns.constants.COLUMN_TOTAL)
    id = GetHeaderColumnId(columns.constants.COLUMN_TOTAL, transportType)
    styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
    table.insert(row, textView.functions.CreateTextView(text, id, styleList ))

    tableView.functions.SetHeader(financeTable, row)
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
                if functions.IsCategoryAllowedForTransportType(transportType, level2Category) then
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
    local labelView = textView.functions.CreateTextView(text, id, { styles.table.CELL, styles.text.LEFT_ALIGNMENT } )

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
    
    local comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, components, tostring(level))
    comp:setStyleClassList(componentStyleList)

    return comp
end

function CreateCategotryLineValueComponent(category, id)
    local styleList = { styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
    local cellView = textView.functions.CreateTextView("", id, styleList )

    ui_functions.SetTooltipByCategory(cellView, category)
    local comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, { cellView }, tostring(level))
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
            functions.RefreshTransportCategoryValues(transportType, engine.GetJournal(functions.GetCurrentGameYear()), columns.constants.COLUMN_YEAR .. columns.constants.NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                local year = engine.GetYearFromYearIndex(j)
                functions.RefreshTransportCategoryValues(transportType, engine.GetJournal(year), columns.constants.COLUMN_YEAR .. j)
                api.gui.util.getById(GetTableControlId(columns.constants.COLUMN_YEAR .. j)):setText(tostring(year))
            end
        end
        functions.RefreshTransportCategoryValues(transportType, engine.GetJournal(0), transport.constants.COLUMN_TOTAL)
    end
end

function functions.RefreshTransportCategoryValues(transportType, journal, column)
    --total
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_TOTAL), 
                                 GetTableControlId(column, constants.CAT_TOTAL, transportType))
    --income
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INCOME), 
                                 GetTableControlId(column, constants.CAT_INCOME, transportType))
    --maintenance
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE), 
                                 GetTableControlId(column, constants.CAT_MAINTENANCE, transportType))
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_VEHICLES), 
                                 GetTableControlId(column, constants.CAT_MAINTENANCE_VEHICLES, transportType))
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_INFRASTRUCTURE), 
                                 GetTableControlId(column, constants.CAT_MAINTENANCE_INFRASTRUCTURE, transportType))
    --investment
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS), 
                                 GetTableControlId(column, constants.CAT_INVESTMENTS, transportType))
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_VEHICLES), 
                                 GetTableControlId(column, constants.CAT_INVESTMENTS_VEHICLES, transportType))
    if functions.IsCategoryAllowedForTransportType(transportType, constants.CAT_INVESTMENTS_TRACKS) then
        ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_TRACKS), 
                                     GetTableControlId(column, constants.CAT_INVESTMENTS_TRACKS, transportType))
    end
    if functions.IsCategoryAllowedForTransportType(transportType, constants.CAT_INVESTMENTS_ROADS) then
        ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_ROADS), 
                                     GetTableControlId(column, constants.CAT_INVESTMENTS_ROADS, transportType))
    end
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_INFRASTRUCTURE), 
                                 GetTableControlId(column, constants.CAT_INVESTMENTS_INFRASTRUCTURE, transportType))
    --cashflow
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_CASHFLOW), 
                                 GetTableControlId(column, constants.CAT_CASHFLOW, transportType))
							
	--margin									
    ui_functions.UpdateCellValuePercentage(engine.GetValueFromJournal(journal, transportType, constants.CAT_MARGIN),
                                 GetTableControlId(column, constants.CAT_MARGIN, transportType))
    
end

function functions.IsCategoryAllowedForTransportType(transportType, category)
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
