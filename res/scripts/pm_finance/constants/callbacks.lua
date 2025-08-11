local constants = {}
local functions = {}

constants.COLOR_CHANGED = "pm-CB-ColorChanged"
constants.CLEAR_GUI_UPDATE = "pm-CB-ClearGuiUpdate"

function functions.SendCallbackEvent(callbackName, item, param)
    api.cmd.sendCommand(api.cmd.make.sendScriptEvent("callbacks.lua", callbackName, item, param))
end

local callbacks = {}
callbacks.constants = constants
callbacks.functions = functions

return callbacks
