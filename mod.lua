local vMajor = 1
local vMinor = 0

function data()
	return {
		info = {
			majorVersion = vMajor,
			minorVersion = vMinor,
			severityAdd = "NONE",
			severityRemove = "NONE",
			name = "Better financial overview",
			description = ("This mod extends the game with the option to add some extra challenge by substracting taxes from your income or with some support in case you are having a hard time to get started.\n"..
			"A new Tab 'Taxes' has been added to the financial menu showing the journal in a slightly reshaped format: Income, Maintenance and Investments are grouped by the vehicle category. Taxes / Subsidies are separately listed here and show the taxes by category as well.\n"..
			"To change the rates you can access the settings menu from here. All changes are saved to your savegame.\n"..
			"Incometaxes\n"..
			"Tax rates depend on your:\n"..
			"- GrossSales\n"..
			"- GrossProfit (here GrossSales - Maintenance related to the vehicle's category[Depots, Stations, Signals, Vehicles etc])\n"..
			"- GrossProfitMargin (GPM) [ratio between GrossSales and GrossProfit]\n"..
			"The higher the GPM, the higher your taxes. 25% GPM = Max Taxe rate is applied. 50% GPM = 1.5x, >90% = 2.5x \n"..
			"Between 5% and -5% GPM there are no taxes.\n"..
			"If your GPM is negative your Min Tax [or subsidies] Rate is applied. -33% GPM = 100% Subsidies, -66% GPM = 200% Subsidies. Capped at 200%"..
			"All other taxes are fixed to your setting.\n\n"..
			"The calculation is based in the gameyear not the indicated date period. Meaning it starts with Year one when you start the game and counts onwards from there, regardless of the defined game speed or datespeed. The periods itself follow the default period.\n"..
			"Next to the date field, the game year is displayed."..
			"[h1]Installation[/h1]/nPlease only add this mod in existing savegames, otherwise you'll get an error message."..
			"\n[h1]Release Notes[/h1]\n - v1.4: Update of calculation timing and data refresh: Taxforecast / Journal is updated every 2nd month. Taxes are payed only once per year on January 1st of the following year. Taxes Tab has been improved to display results and taxes payed seperately side by side."..
			"\n v1.5: Minor Bugfix, Visual adjustments to the table for easier reading. Smothening the Tax calculation.\n"..
			"v1.6: Bugfix for first Start"),
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











