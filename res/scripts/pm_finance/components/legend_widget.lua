local engineGameState = require "pm_finance/engine/game_state"

local guiTextView = require "pm_finance/gui/text_view"
local guiLayout = require "pm_finance/gui/layout"

local constants = {}
local functions = {}

function functions.CreateLegendWidget(items, legends, defaultColors)
	local components = {}
    for i, item in pairs(items) do
        local label = guiTextView.functions.CreateTextView(legends[i], "", nil)
        local color = engineGameState.functions.GetColor(item)
        if color == nil then
            color = defaultColors[i]
        end
        local button = api.gui.comp.ColorChooserButton.new(defaultColors, color, 20, false, true)
        table.insert(components, button)
        table.insert(components, label)
    end
    return guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, components, "LegendWidget")
end

local legendWidget = {}
legendWidget.constants = constants
legendWidget.functions = functions

return legendWidget