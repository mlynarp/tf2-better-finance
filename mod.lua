local params = require "pm_finance/constants/params"

local vMajor = 2
local vMinor = 0

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
				  name = _("pm-Parameter.NumberOfColumn.Label"),
				  uiType = "SLIDER",
				  values = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
				  tooltip = _("pm-Parameter.NumberOfColumn.Tooltip"),
				  defaultIndex = 4,
				},
                {
				  key = "ChartsEnabled",
				  name = _("pm-Parameter.ChartsEnabled.Label"),
				  uiType = "CHECKBOX",
				  values = { "0", "1" },
				  tooltip = _("pm-Parameter.ChartsEnabled.Tooltip"),
				  defaultIndex = 1,
				}
			},
			tags = { "Misc", "Script Mod" },
		},
        runFn = function(settings, modParams)
            local parameters = modParams[getCurrentModId()]
            params.constants.NUMBER_OF_YEARS_COLUMNS = parameters.NumberOfColumns
            params.constants.CHARTS_ENABLED = parameters.ChartsEnabled == 1
        end,
	}
end











