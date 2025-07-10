local constants = {}
local functions = {}

constants.ORIENTATION = { HORIZONTAL = "HORIZONTAL", VERTICAL = "VERTICAL" }


function functions.CreateTextView(text, id, style)
    local textView = api.gui.comp.TextView.new(text or "")
    textView:setStyleClassList(style)

    if (id) then
        textView:setId(id)
    end

    return textView
end

local textview = {}
textview.constants = constants
textview.functions = functions

return textview