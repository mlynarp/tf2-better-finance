local vMajor = 1
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
			name = "Better Financial Overview",
			description = ("This mod adds a new tab to the financial menu that displays the journal in different format.\n"..
							"It focuses on cashflow and totals for the transport categories.\n"..
							"The journal is annual regardless of the speed of the game calendar. It also shows more years history."),
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
				  key = "numberOfColumns",
				  name = _("Parameter.Label"),
				  uiType = "SLIDER",
				  values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" },
				  tooltip = _("Parameter.Tooltip"),
				  defaultIndex = 5,
				}
			},
			tags = { "Script Mod" },
		},
	}
end











