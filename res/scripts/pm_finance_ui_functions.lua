function UpdateCellValue(amount, textViewId)
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

function SetRowVisibilityInTable(table, row, visible)
    if row >= table:getNumRows() then
        return
    end
    for column = 0, table:getNumCols() - 1 do
        local element = table:getItem(row, column)
        element:setVisible(visible, false)
    end
end

function LayoutComponentsHorizontally(components, styleList, componentName)
    local component = api.gui.comp.Component.new(componentName)
    local layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
    layout:setName(componentName..".Layout")
    component:setStyleClassList(styleList)
    for i, component in ipairs(components) do
        layout:addItem(component)
    end
    component:setLayout(layout)
    return component
end
