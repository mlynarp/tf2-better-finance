local constants = {}
local functions = {}

constants.ORIENTATION = { HORIZONTAL = "HORIZONTAL", VERTICAL = "VERTICAL" }


function functions.LayoutComponents(orientation, components, componentName)
    local component = api.gui.comp.Component.new(componentName)

    local layout = api.gui.layout.BoxLayout.new(orientation)
    layout:setName(componentName..".Layout")

    for i, comp in ipairs(components) do
        layout:addItem(comp)
    end
    component:setLayout(layout)
    return component
end

local layout = {}
layout.constants = constants
layout.functions = functions

return layout