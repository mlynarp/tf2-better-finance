local vMajor = 1
local vMinor = 0

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
			authors = {
				{
					name = "Petr Mlynar",
					role = "CREATOR",
				}
			},
			tags = { "Script Mod" },
		},
	}
end











