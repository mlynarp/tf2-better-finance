local constants = require "pm_finance/constants"
local styles = require "pm_finance/constants/styles"
local textview = require "pm_finance/gui/textview"
local tableView = require "pm_finance/gui/tableview"
local engine = require "pm_finance/functions"
local ui_functions = require "pm_finance/ui_functions"
local layout = require "pm_finance/gui/layout"

local ids = { tableId = "pm-myFinanceTable" }

local functions = {}

function functions.InitFinanceTable()
    local financeTable = tableView.functions.CreateTableView(constants.NUMBER_OF_YEARS_COLUMNS + 2, ids.tableId, ids.tableId)

    functions.AddFinanceTableHeaders(financeTable)

    for j = 1, #constants.TRANSPORT_TYPES do
        functions.AddTransportCategoriesToFinanceTable(financeTable, constants.TRANSPORT_TYPES[j])
    end

    return financeTable
end

function functions.AddFinanceTableHeaders(financeTable)
    local row = {}

    local text = ""
    local id = functions.GetTableControlId(constants.COLUMN_LABEL)
    local styleList = { styles.table.HEADER, styles.text.RIGHT_ALIGNMENT }
    table.insert(row, textview.functions.CreateTextView(text, id, styleList ))
    
    for i = 1, constants.NUMBER_OF_YEARS_COLUMNS do
        text = tostring(engine.GetYearFromYearIndex(i))
        id = functions.GetTableControlId(constants.COLUMN_YEAR .. i)
        table.insert(row, textview.functions.CreateTextView(text, id, styleList ))
    end
    
    text = _(constants.COLUMN_TOTAL)
    id = functions.GetTableControlId(constants.COLUMN_TOTAL)
    table.insert(row, textview.functions.CreateTextView(text, id, styleList ))

    tableView.functions.SetHeader(financeTable, row)
end

function functions.AddTransportCategoriesToFinanceTable(financeTable, transportType)
    -- level 0
    functions.AddTransportCategoryLineToFinanceTable(financeTable, true, transportType, constants.CAT_TOTAL, styles.table.LEVEL_0 , 0)

    -- level 1
    for i, level1Category in ipairs(constants.TRANSPORT_CATEGORIES_LEVEL1) do
        if (#constants.TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            functions.AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, level1Category, styles.table.LEVEL_1, 1)
        else
            functions.AddTransportCategoryLineToFinanceTable(financeTable, true, transportType, level1Category, styles.table.LEVEL_1, 1)
            -- level 2
            for j, level2Category in ipairs(constants.TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if functions.IsCategoryAllowedForTransportType(transportType, level2Category) then
                    functions.AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, level2Category, styles.table.LEVEL_2, 2)
                end
            end
        end
    end

    functions.AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, constants.CAT_CASHFLOW, styles.table.LEVEL_1, 0)
    functions.AddTransportCategoryLineToFinanceTable(financeTable, false, transportType, constants.CAT_MARGIN, styles.table.LEVEL_1, 0)
end

function functions.AddTransportCategoryLineToFinanceTable(financeTable, isExpandable, transportType, category, sLevel, level)
    local row = {}

    local components = {}
    local labelTranslationKey = category
    if category == constants.CAT_TOTAL then
        labelTranslationKey = transportType
    end
    
    local text = _(labelTranslationKey)
    local id = functions.GetTableControlId(constants.COLUMN_LABEL, category, transportType)
    local styleList = { sLevel, styles.table.CELL, styles.text.LEFT_ALIGNMENT }
    local labelView = textview.functions.CreateTextView(text, id, styleList )

    if isExpandable then
        table.insert(components, ui_functions.CreateExpandButton(financeTable, level))
    elseif level > 0 then
        labelView:addStyleClass(styles.table.LEVEL_PADDING)
    else
        labelView:removeStyleClass(styles.text.LEFT_ALIGNMENT)
        labelView:addStyleClass(styles.text.RIGHT_ALIGNMENT)
    end
    ui_functions.SetTooltipByCategory(labelView, category)
    table.insert(components, labelView)
    local comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, components, tostring(level))
    comp:setStyleClassList({ sLevel, styles.table.CELL })
    table.insert(row, comp)

    for i = 1, constants.NUMBER_OF_YEARS_COLUMNS do
        text = ""
        id = functions.GetTableControlId(constants.COLUMN_YEAR..i, category, transportType)
        styleList = { sLevel, styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
        local yearCellView = textview.functions.CreateTextView(text, id, styleList )

        ui_functions.SetTooltipByCategory(yearCellView, category)
       
        local comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, { yearCellView }, tostring(level))
        comp:setStyleClassList({ sLevel, styles.table.CELL })
        table.insert(row, comp)
    end
    
    text = ""
    id = functions.GetTableControlId(constants.COLUMN_TOTAL, category, transportType)
    styleList = { sLevel, styles.table.CELL, styles.text.RIGHT_ALIGNMENT }
    local totalCellView = textview.functions.CreateTextView(text, id, styleList )
    ui_functions.SetTooltipByCategory(totalCellView, category)
    
    local comp = layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, { totalCellView }, tostring(level))
    comp:setStyleClassList({ sLevel, styles.table.CELL })
    table.insert(row, comp)

    financeTable:addRow(row)
end

function functions.UpdateTableValues(currentYearOnly)
    for i, transportType in ipairs(constants.TRANSPORT_TYPES) do
        if currentYearOnly then
            functions.RefreshTransportCategoryValues(transportType, engine.GetJournal(functions.GetCurrentGameYear()), constants.COLUMN_YEAR .. constants.NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, constants.NUMBER_OF_YEARS_COLUMNS do
                local year = engine.GetYearFromYearIndex(j)
                functions.RefreshTransportCategoryValues(transportType, engine.GetJournal(year), constants.COLUMN_YEAR .. j)
                api.gui.util.getById(ui_functions.GetTableControlId(constants.COLUMN_YEAR .. j)):setText(tostring(year))
            end
        end
        functions.RefreshTransportCategoryValues(transportType, engine.GetJournal(0), constants.COLUMN_TOTAL)
    end
end

function functions.RefreshTransportCategoryValues(transportType, journal, column)
    --total
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_TOTAL), 
                                functions.GetTableControlId(column, constants.CAT_TOTAL, transportType))
    --income
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INCOME), 
                                functions.GetTableControlId(column, constants.CAT_INCOME, transportType))
    --maintenance
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE), 
                                functions.GetTableControlId(column, constants.CAT_MAINTENANCE, transportType))
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_VEHICLES), 
                                functions.GetTableControlId(column, constants.CAT_MAINTENANCE_VEHICLES, transportType))
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_INFRASTRUCTURE), 
                                functions.GetTableControlId(column, constants.CAT_MAINTENANCE_INFRASTRUCTURE, transportType))
    --investment
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS), 
                                functions.GetTableControlId(column, constants.CAT_INVESTMENTS, transportType))
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_VEHICLES), 
                                functions.GetTableControlId(column, constants.CAT_INVESTMENTS_VEHICLES, transportType))
    if functions.IsCategoryAllowedForTransportType(transportType, constants.CAT_INVESTMENTS_TRACKS) then
        ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_TRACKS), 
                                    functions.GetTableControlId(column, constants.CAT_INVESTMENTS_TRACKS, transportType))
    end
    if functions.IsCategoryAllowedForTransportType(transportType, constants.CAT_INVESTMENTS_ROADS) then
        ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_ROADS), 
                                    functions.GetTableControlId(column, constants.CAT_INVESTMENTS_ROADS, transportType))
    end
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_INFRASTRUCTURE), 
                                functions.GetTableControlId(column, constants.CAT_INVESTMENTS_INFRASTRUCTURE, transportType))
    --cashflow
    ui_functions.UpdateCellValue(engine.GetValueFromJournal(journal, transportType, constants.CAT_CASHFLOW), 
                                functions.GetTableControlId(column, constants.CAT_CASHFLOW, transportType))
							
	--margin									
    ui_functions.UpdateCellValuePercentage(engine.GetValueFromJournal(journal, transportType, constants.CAT_MARGIN),
                                functions.GetTableControlId(column, constants.CAT_MARGIN, transportType))
    
end

function functions.IsCategoryAllowedForTransportType(transportType, category)
    if transportType == constants.TRANSPORT_TYPE_ALL then
        return true
    end
    if category == constants.CAT_INVESTMENTS_TRACKS and transportType ~= constants.TRANSPORT_TYPE_RAIL then
        return false
    elseif category == constants.CAT_INVESTMENTS_ROADS and transportType ~= constants.TRANSPORT_TYPE_ROAD then
        return false
    end
    return true
end


function functions.GetTableControlId(column, category, transportType)
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
