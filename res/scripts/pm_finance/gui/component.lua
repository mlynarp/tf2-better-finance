local constants = {}
local functions = {}

function functions.FindById(id)
    return api.gui.util.getById(id)
end

local component = {}
component.constants = constants
component.functions = functions

return component