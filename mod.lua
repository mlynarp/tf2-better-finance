local columns = require "pm_finance/constants/columns"

local vMajor = 1
local vMinor = 4

-- old API
-- http://transportfever.com/wiki/script-doc/index.html

-- new API
-- https://transportfever2.com/wiki/api/index.html

function data()
	return {
		info = {
			majorVersion = vMajor,
			minorVersion = vMinor,
			severityAdd = "NONE",
			severityRemove = "NONE",
			name = "Better Finance Overview",
			description = "This mod shows finances organized per transport type or all transport categories together.\n\n"..
                          "It always shows accounting on yearly base.\n\n"..
                          "Current version: "..vMajor.."."..vMinor,
			authors =
			{
				{
					name = "Petr Mlynar",
					role = "CREATOR",
				}
			},
			params =
			{
				{
				  key = "NumberOfColumns",
				  name = _("pm-Parameter.Label"),
				  uiType = "SLIDER",
				  values = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
				  tooltip = _("pm-Parameter.Tooltip"),
				  defaultIndex = 4,
				}
			},
			tags = { "Misc", "Script Mod" },
		},
        runFn = function(settings, modParams)
            columns.constants.NUMBER_OF_YEARS_COLUMNS = modParams[getCurrentModId()].NumberOfColumns
        end,
	}
end











