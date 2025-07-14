local tooltips = require "pm_finance/constants/tooltips"

local ui_functions = {}

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
    component:setTooltip(_(tooltips.constants.TOOLTIP .. category))
end

return ui_functions
