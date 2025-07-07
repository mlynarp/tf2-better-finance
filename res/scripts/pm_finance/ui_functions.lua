local constants = require "pm_finance/constants"

local ui_functions = {}

function ui_functions.UpdateCellValuePercentage(amount, textViewId)
    local textView = api.gui.util.getById(textViewId)
    if not textView then
        return
    end
    textView:removeStyleClass("negative")
    textView:removeStyleClass("positive")
    if not amount then
        amount = 0
    end
    if amount > 0 then
        textView:addStyleClass("positive")
    elseif amount < 0 then
        textView:addStyleClass("negative")
    end
    textView:setText(string.format("%.2f", amount))
end



function ui_functions.UpdateCellValue(amount, textViewId)
    local textView = api.gui.util.getById(textViewId)
    if not textView then
        return
    end
    textView:removeStyleClass("negative")
    textView:removeStyleClass("positive")
    if not amount then
        amount = 0
    end
    if amount > 0 then
        textView:addStyleClass("positive")
    elseif amount < 0 then
        textView:addStyleClass("negative")
    end
    textView:setText(api.util.formatMoney(amount))
end

function ui_functions.SetRowVisibilityInTable(table, row, visible)
    if row >= table:getNumRows() then
        return
    end
    for column = 0, table:getNumCols() - 1 do
        local element = table:getItem(row, column)
        element:setVisible(visible, false)
    end
end

function ui_functions.LayoutComponentsHorizontally(components, styleList, componentName)
    local component = api.gui.comp.Component.new(componentName)
    local layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
    layout:setName(componentName..".Layout")
    component:setStyleClassList(styleList)
    for i, comp in ipairs(components) do
        layout:addItem(comp)
    end
    component:setLayout(layout)
    return component
end

function ui_functions.GetStyleForTableLineLevel(level)
    if level == 0 then
        return constants.STYLE_LEVEL_0
    elseif level == 1 then
        return constants.STYLE_LEVEL_1
    else
        return constants.STYLE_LEVEL_2
    end
end

function ui_functions.CreateExpandButton(table, level)
    local iconExpandPath = "ui/design/components/slim_arrow_right@2x.tga"
    local iconCollapsePath = "ui/design/components/slim_arrow_down@2x.tga"
    local imageView = api.gui.comp.ImageView.new(iconCollapsePath)
    local button = api.gui.comp.Button.new(imageView, false)
    button:setStyleClassList({ ui_functions.GetStyleForTableLineLevel(level), constants.STYLE_BUTTON })
    local myRowIndex = table:getNumRows()
    button:onClick(function()
        local startRowIndex = myRowIndex + 1
        local lastRowIndex = myRowIndex + 1
        local setToVisible = not table:getItem(startRowIndex, 0):isVisible()
        for row = startRowIndex, table:getNumRows() - 1 do
            if tonumber(table:getItem(row, 0):getName()) <= level then
                lastRowIndex = row - 1
                break
            end
        end
        for row = startRowIndex, lastRowIndex do
            ui_functions.SetRowVisibilityInTable(table, row, setToVisible)
            if setToVisible then
                imageView:setImage(iconCollapsePath, false)
            else
                imageView:setImage(iconExpandPath, false)
            end
        end
    end)
    return button
end

function ui_functions.CreateTextView(text, styleList, id)
    local textView = api.gui.comp.TextView.new(text)
    textView:setStyleClassList(styleList)
    textView:setId(id)
    return textView
end

function ui_functions.GetTableControlId(column, category, transportType)
    if not transportType then
        if not category then
            return "pm-" .. column
        end
        return "pm-" .. category .. "." .. column
    end
    return "pm-" .. transportType .. "." .. category .. "." .. column
end

function ui_functions.SetTooltipByCategory(component, category)
    component:setTooltip(_(constants.TOOLTIP .. category))
end

return ui_functions
