function data()
	return {
		en ={
			["#Tooltip.Settings.Income"]=("Taxrate applied on your income from tickets.\n".."Tax rates depend on your:\n"..
			"- GrossSales\n"..
			"- GrossProfit (here GrossSales - Maintenance related to the vehicle's category[Depots, Stations, Signals, Vehicles etc])\n"..
			"- GrossProfitMargin (GPM) [ratio between GrossSales and GrossProfit]\n"..
			"The higher the GPM, the higher your taxes. 25% GPM = Max Taxe rate is applied. 50% GPM = 1.5x, >90% = 2.5x \n"..
			"Between 5% and -5% GPM there are no taxes.\n"..
			"If your GPM is negative your Min Tax [or subsidies] Rate is applied. -33% GPM = 100% Subsidies, -66% GPM = 200% Subsidies. Capped at 200%"),
			["#Tooltip.Settings.Vehicles"]=("Taxrate applied when you buy or sell a vehicle. You will be taxed on selling & buying. No refunds!"),
			["#Tooltip.Settings.Infrastructure"]=("Taxrate applied when you build stations / harbours/airports. No refunds on destruction, you will be taxed again!"),
			["#TaxesDescription"]=("This Tab displays an alternate Journal displaying figures per vehicle category and grouped by Investment related and Income related numbers.\nFirst Column displays the actual result, second column displays the taxes that will be charged.\nTaxes will be payed on the first day of the next year.\nClick on Settings to adjust the parameters of this mod."),
			["#Tooltip.Details.Income"] = ("Your Income"),
			["#Tooltip.Details.Maintenance"] = ("Total Maintenance incl. buildings and vehicles"),
			["#Tooltip.Details.Vehicles"] = ("Acquisition of new vehicles"),
			["#Tooltip.Details.Infrastructure"] = ("Construction of new buildings"),
			["#Tooltip.Details.Taxes.Income"] = ("Taxes or Subsidies on Income"),
			["#Tooltip.Details.Taxes.Vehicles"] = ("Taxes on Vehicle acquisitions"),
			["#Tooltip.Details.Taxes.Infrastructure"]=("Taxes on new constructions"),
			["#Tooltip.GameYear"]=("This is the game year starting from 1 and counting the elapsed time. Only affected by the gamespeed. The Ingame date & datespeed is not influencing this."),
			["#GameYear"]=("Gameyear"),
			["GT"]=("Ingame Year "),
			["M"]=("M: "),
			["#GameYearToolTip"]=("Displays the current game year calculated from the elapsed time in your savegame.\nThis represents also the period used (but not labelled as such) in the default graphs and tables.\nIf you play only on 1x Datespeed the gameyear equals the Year in the datefield - the startyear of your game."),
			["Income"]=("Income"),
			["Maintenance"]=("Maintenance"),
			["Infrastructure"]=("Infrastructure"),
			["Vehicles"]=("Vehicles"),		
			["rail"]=("Railway"),
			["road"]=("Road"),
			["tram"]=("Tram"),
			["air"]=("Aviation"),
			["water"]=("Ship"),
			["#SettingsYearButtonText"]=("Show ingame Year"),
			["#SettingsYearButtonLabelYes"]=("Yes"),
			["#SettingsYearButtonLabelNo"]=("No"),
		}
	}
end