local guiComponent = require "pm_finance/gui/component"

local constants = {}
local functions = {}

constants.TEXT_TYPE = { MONEY = "MONEY", PERCENTAGE = "PERCENTAGE" }


function functions.CreateTextView(text, id, style)
    local textView = api.gui.comp.TextView.new(text or "")

    if (id) then
        textView:setId(id)
    end

    if (style) then
        textView:setStyleClassList(style)
    end

    return textView
end

function functions.SetText(textView, text)
     textView:setText(text)
end

function functions.SetFormattedText(textViewId, amount, type)
    local textView = guiComponent.functions.FindById(textViewId)
    
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

    if (type == constants.TEXT_TYPE.MONEY) then
        functions.SetText(textView, api.util.formatMoney(amount))
    end
    if (type == constants.TEXT_TYPE.PERCENTAGE) then
        functions.SetText(textView, string.format("%.2f %%", amount))
    end
end

local textView = {}
textView.constants = constants
textView.functions = functions

return textView