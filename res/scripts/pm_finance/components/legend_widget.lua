local guiTextView = require "pm_finance/gui/text_view"
local guiLayout = require "pm_finance/gui/layout"

local constants = {}
local functions = {}

function functions.CreateLegendWidget(legends, colors)
	local components = {}
    
    for i, legend in pairs(legends) do
        local label = guiTextView.functions.CreateTextView(legend, "", nil)
        local button = api.gui.comp.ColorChooserButton.new(colors, colors[i], 20, false, true)
        table.insert(components, button)
        table.insert(components, label)
    end
    return guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, components, "LegendWidget")
end

local legendWidget = {}
legendWidget.constants = constants
legendWidget.functions = functions

return legendWidget