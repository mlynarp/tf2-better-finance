local constants = {}
local functions = {}

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

local textView = {}
textView.constants = constants
textView.functions = functions

return textView