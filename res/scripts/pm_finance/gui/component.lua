local tooltips = require "pm_finance/constants/tooltips"

local constants = {}
local functions = {}

function functions.FindById(id)
    return api.gui.util.getById(id)
end

function functions.CreateSpacer()
    return api.gui.comp.Component.new("Spacer")
end

function functions.SetTooltipByCategory(comp, category)
    comp:setTooltip(_(tooltips.constants.TOOLTIP .. category))
end

local component = {}
component.constants = constants
component.functions = functions

return component