function data()
	return {
		de = {
			["#Tooltip.Settings.Income"]=("Repräsentiert den Steuersatz, der auf Eure Einkünfte angesetzt wird.\n".."Der Steuersatz hängt von folgenden Faktoren ab:\n"..
			"- Brutto Einkünfte\n" ..
			"- Marge (Einkünfte - Unterhalt von Fahrzeugen und Infrastruktur [Depots, Stationen, Signale etc]\n"..
			"- Brutto Marge (%): Verhältnis zwischen Deinen Einkünften und der Marge\n"..
			"Je höher eure Marge, desto höher auch der Steuersatz. Der von Dir definierte Maximale Steuersatz wird bei einer Marge von 25% erreicht, bei einer Marge von über 90% erreichst Du das maximum (2.5 facher Steuersatz)\n"..
			"Zwischen -5% und + 5% Marge werden keine Steuern oder Subventionen erhoben / verteilt.\n"..
			"Macht Du Verlust, erhaltet Du ab 5% Subventionen (Minimaler Steuersatz). Bei negativen 33% Marge erhaltet Du die volle Subvention, bei -66% Marge erhaltet Du die Doppelte Subvention. Auch hier ist beim 2.5 fachen Schluss.\n"..
			"Bedingung für Subventionen und Steuern ist, dass Du in der jeweiligen Kategorie (Eisenbahn, Strasse, Tram etc) mindestens 1$ im aktuellen Jahr verdient habt."),
			["#Tooltip.Settings.Vehicles"]=("Steuersatz auf Fahrzeugkäufe und Verkäufe."),
			["#Tooltip.Settings.Infrastructure"]=("Grunderwerbsteuer auf alle Gebäude, die Du baut. Rückerstattungen werden ebenfalls besteuert."),
			["Road"]=("Straße"),
			["Tram"]=("Tram"),
			["Railway"]=("Eisenbahn"),
			["Air"]=("Luftfahrt"),
			["Water"]=("Schifffahrt"),
			["#TaxesDescription"]=("Hier findest Du eine Detailliertere Aufstellung wo Du Steuern zahlst und wo Du Subventionen erhalten hast."),
			["#Tooltip.Details.Income"] = ("Deine Einkünfte"),
			["#Tooltip.Details.Maintenance"] = ("Alle Wartungskosten inklusive Gebäudeunterhalt und Fahrzeugwartungen"),
			["#Tooltip.Details.Vehicles"] = ("Kosten für Einkäufe neuer Fahrzeuge"),
			["#Tooltip.Details.Infrastructure"] = ("Kosten für neue Gebäude, Strassen & Schienen"),
			["#Tooltip.Details.Taxes.Income"] = ("Einkommenssteuer"),
			["#Tooltip.Details.Taxes.Vehicles"] = ("Steuer auf Fahrzeugkäufe"),
			["#Tooltip.Details.Taxes.Infrastructure"]=("Steuer auf Gebäude"),
			["#Tooltip.GameYear"]=("Zeigt das aktuelle Jahr des Spielstands an.\nDieses Jahr wird aus Deiner Spielzeit abgeleitet und entspricht dem Zeitraum, der für Grafiken und Tabellen verwendet wird.\n\nBei einer Datumsgeschwindigkeit von 1x ist das Spieljahr = angezeigtes Jahr im Datumsfeld - Startjahr"),
			["Income"]=("Einkommen"),
			["Maintenance"]=("Unterhalt"),
			["Infrastructure"]=("Infrastruktur"),
			["Vehicles"]=("Fahrzeuge"),
			["GT"]=("Spieljahr "),
			["Taxes"]=("Steuern"),
			["Year"]=("Jahr"),
			["Taxes"]=("Steuern"),
			["Interest"]=("Zinsen"),
			["rail"]=("Eisenbahn"),
			["road"]=("Strasse"),
			["tram"]=("Tram"),
			["air"]=("Luftfahrt"),
			["water"]=("Schifffahrt"),
			["Show Settings"]=("Zeige Einstellungen"),
			["Hide Settings"]=("verberge Einstellungen"),
			["#SettingsYearButtonText"]=("Zeige Spieljahr"),
			["#SettingsYearButtonLabelYes"]=("Ja"),
			["#SettingsYearButtonLabelNo"]=("Nein"),
			["Payed Taxes (for previous year)"]=("gezahlte Steuern im vergangenen Jahr"),
		},	
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