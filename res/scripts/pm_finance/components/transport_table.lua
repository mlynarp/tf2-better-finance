local constants = require "pm_finance/constants"
local styles = require "pm_finance/constants/styles"
local textview = require "pm_finance/gui/textview"
local engine = require "pm_finance/functions"
local ui_functions = require "pm_finance/ui_functions"
local layout = require "pm_finance/gui/layout"

local ids = { tableId = "pm-myFinanceTable" }

local functions = {}

function functions.InitFinanceTable()
    local financeTable = api.gui.comp.Table.new(constants.NUMBER_OF_YEARS_COLUMNS + 2, "NONE")
    financeTable:setId(ids.tableId)
    financeTable:setName(ids.tableId)

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

    financeTable:setHeader(row)
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
                if engine.IsCategoryAllowedForTransportType(transportType, level2Category) then
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
