local constants = require "pm_finance/constants"

function data()
	return {
		en = {
            [constants.TRANSPORT_TYPE_ROAD] = ("Road transport"),
            [constants.TRANSPORT_TYPE_TRAM] = ("Tram transport"),
            [constants.TRANSPORT_TYPE_RAIL] = ("Railroad transport"),
            [constants.TRANSPORT_TYPE_WATER] = ("Water transport"),
            [constants.TRANSPORT_TYPE_AIR] = ("Air transport"),
            [constants.TRANSPORT_TYPE_ALL] = ("All transport"),
            [constants.CAT_TOTAL] = ("Total"),
            [constants.CAT_INCOME] = ("Income"),
            [constants.CAT_MAINTENANCE] = ("Maintenance"),
            [constants.CAT_MAINTENANCE_VEHICLES] = ("Vehicles"),
            [constants.CAT_MAINTENANCE_INFRASTRUCTURE] = ("Infrastructure"),
            [constants.CAT_INVESTMENTS] = ("Investments"),
            [constants.CAT_INVESTMENTS_VEHICLES] = ("Vehicles"),
            [constants.CAT_INVESTMENTS_TRACKS] = ("Railways"),
            [constants.CAT_INVESTMENTS_ROADS] = ("Roads"),
            [constants.CAT_INVESTMENTS_INFRASTRUCTURE] = ("Infrastructure"),
            [constants.CAT_CASHFLOW] = ("Cashflow"),
            [constants.CAT_MARGIN] = ("Margin"),
            [constants.CAT_PROFIT] = ("Profit"),
            [constants.CAT_LOAN] = ("Loan"),
            [constants.CAT_INTEREST] = ("Interest"),
            [constants.CAT_OTHER] = ("Others"),
            [constants.CAT_BALANCE] = ("Balance"),
            [constants.COLUMN_TOTAL] = ("Total"),
            ["pm-Parameter.Label"] = ("Number of years in overview"),
            ["pm-Parameter.Tooltip"] = ("Choose the number of years to be displayed in the financial overview table."),
            [constants.TOOLTIP .. constants.CAT_TOTAL] = ("Overall profit as sum of income deducted by maintenance and investments"),
            [constants.TOOLTIP .. constants.CAT_INCOME] = ("Revenue from tickets."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE] = ("Total maintenance incl. vehicles and infrastructure."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE_VEHICLES] = ("Maintenance from the operation of vehicles."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE_INFRASTRUCTURE] = ("Maintenance from the operation of stations, depots and tracks or roads if relevant."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS] = ("Total investments incl. vehicles, infrastructure and tracks or roads if relevant."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_VEHICLES] = ("Acquisition of new vehicles."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_INFRASTRUCTURE] = ("Construction of new buildings."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_ROADS] = ("Construction of new roads."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_TRACKS] = ("Construction of new tracks."),
            [constants.TOOLTIP .. constants.CAT_CASHFLOW] = ("Operating profit as sum of income deducted by maintenance."),
            [constants.TOOLTIP .. constants.CAT_MARGIN] = ("Operating profit as a percentage of income, indicating how efficiently a company turns income into operating profit."),
            [constants.TOOLTIP .. constants.CAT_PROFIT] = ("Overall profit as sum of income deducted by maintenance and investments from all transports."),
            [constants.TOOLTIP .. constants.CAT_LOAN] = ("Amount of money borrowed from the bank."),
            [constants.TOOLTIP .. constants.CAT_INTEREST] = ("Interest paid on borrowed money."),
            [constants.TOOLTIP .. constants.CAT_OTHER] = ("Other expenditure without a specific category, e.g. landscaping."),
            [constants.TOOLTIP .. constants.CAT_BALANCE] = ("Current bank balance."),
            [constants.TOOLTIP_GAMEINFO] = ("Operating profit as sum of income deducted by maintenance since the beginning of the year."),
            ["pm-DESCRIPTION"] = ( "Do you want to see finance better organized?\n"..
                                "Do you want to see totals for each transport category or just operating profit?\n"..
                                "Do you want to have yearly based accounting independent of game calendar speed?\n"..
                                "Do you want to see current year cashflow instead of earnings in buttom status bar?\n\n"..
                            
                                "This mod shows finances organized per transport type or all transport category. It always shows accounting on yearly base.\n\n"..

                                "Version 1.3 release notes:\n"..
                                "    - fixed random crash\n"..
                                
                                "Version 1.2 release notes:\n"..
                                "    - avoid using ui IDs that might be in collision with other mods\n"..
                                "    - always show table header when scrolling down\n\n"..
                                
                                "Version 1.1 release notes:\n"..
                                "    - avoid using the global variables to avoid conflict with other mods\n"..
                                "    - add tracks and roads to all transport overview\n\n"..
                                
                                "Version 1.0 release notes:\n"..
                                "    - each transport has its own category in finance overview including trams (original table is replaced)\n"..
                                "    - every transport category show data per configurable number of years backwar and totals\n"..
                                "    - summary table with the overall profit, loan, interest, other and bank account\n"..
                                "    - every cell in table has a proper tooltip\n"..
                                "    - earnings field in status bar was replaced by cashflow field to show current year progress\n"..
                                "    - english, czech translation\n"..
                                
                                "Any feedback is highly appreciated.")
		},
        de = {
            [constants.TRANSPORT_TYPE_ROAD] = ("Straße"),
            [constants.TRANSPORT_TYPE_TRAM] = ("Tram"),
            [constants.TRANSPORT_TYPE_RAIL] = ("Eisenbahn"),
            [constants.TRANSPORT_TYPE_WATER] = ("Wasser"),
            [constants.TRANSPORT_TYPE_AIR] = ("Luft"),
            [constants.TRANSPORT_TYPE_ALL] = ("Alle"),
            [constants.CAT_TOTAL] = ("Gesamt"),
            [constants.CAT_INCOME] = ("Einnahmen"),
            [constants.CAT_MAINTENANCE] = ("Wartung"),
            [constants.CAT_MAINTENANCE_VEHICLES] = ("Fahrzeuge"),
            [constants.CAT_MAINTENANCE_INFRASTRUCTURE] = ("Infrastruktur"),
            [constants.CAT_INVESTMENTS] = ("Investitionen"),
            [constants.CAT_INVESTMENTS_VEHICLES] = ("Fahrzeuge"),
            [constants.CAT_INVESTMENTS_TRACKS] = ("Eisenbahnstrecken"),
            [constants.CAT_INVESTMENTS_ROADS] = ("Straßen"),
            [constants.CAT_INVESTMENTS_INFRASTRUCTURE] = ("Infrastruktur"),
            [constants.CAT_CASHFLOW] = ("Operativer Gewinn"),
            [constants.CAT_MARGIN] = ("Marge"),
            [constants.CAT_PROFIT] = ("Gewinn"),
            [constants.CAT_LOAN] = ("Darlehen"),
            [constants.CAT_INTEREST] = ("Zinsen"),
            [constants.CAT_OTHER] = ("Sonstiges"),
            [constants.CAT_BALANCE] = ("Kontostand"),
            [constants.COLUMN_TOTAL] = ("Gesamt"),
            ["pm-Parameter.Label"] = ("Anzahl der Jahre in der Übersicht"),
            ["pm-Parameter.Tooltip"] = ("Wählen Sie die Anzahl der Jahre, die in der finanziellen Übersichtstabelle angezeigt werden sollen."),
            [constants.TOOLTIP .. constants.CAT_TOTAL] = ("Gesamtgewinn als Summe der Einnahmen abzüglich Wartung und Investitionen"),
            [constants.TOOLTIP .. constants.CAT_INCOME] = ("Einnahmen aus Ticketverkäufen."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE] = ("Gesamte Wartung inkl. Fahrzeuge und Infrastruktur."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE_VEHICLES] = ("Wartung aus dem Betrieb von Fahrzeugen."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE_INFRASTRUCTURE] = ("Wartung aus dem Betrieb von Stationen, Depots und Gleisen oder Straßen, sofern relevant."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS] = ("Gesamte Investitionen inkl. Fahrzeuge, Infrastruktur und Gleisen oder Straßen, sofern relevant."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_VEHICLES] = ("Anschaffung neuer Fahrzeuge."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_INFRASTRUCTURE] = ("Bau neuer Gebäude."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_ROADS] = ("Bau neuer Straßen."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_TRACKS] = ("Bau neuer Gleise."),
            [constants.TOOLTIP .. constants.CAT_CASHFLOW] = ("Betriebsgewinn als Summe der Einnahmen abzüglich Wartung."),
            [constants.TOOLTIP .. constants.CAT_MARGIN] = ("Betriebsgewinn als Prozentsatz der Einnahmen, der angibt, wie effizient ein Unternehmen seine Einnahmen in Betriebsgewinn umwandelt."),
            [constants.TOOLTIP .. constants.CAT_PROFIT] = ("Gesamtgewinn als Summe der Einnahmen abzüglich Wartung und Investitionen aus allen Transportarten."),
            [constants.TOOLTIP .. constants.CAT_LOAN] = ("Höhe des von der Bank aufgenommenen Geldes."),
            [constants.TOOLTIP .. constants.CAT_INTEREST] = ("Zinsen, die auf aufgenommenes Geld gezahlt werden."),
            [constants.TOOLTIP .. constants.CAT_OTHER] = ("Sonstige Ausgaben ohne spezifische Kategorie, z. B. Landschaftsgestaltung."),
            [constants.TOOLTIP .. constants.CAT_BALANCE] = ("Aktueller Kontostand."),
            [constants.TOOLTIP_GAMEINFO] = ("Betriebsgewinn als Summe der Einnahmen abzüglich Wartung seit Jahresbeginn.")
        },
		cs_CZ = {
            [constants.TRANSPORT_TYPE_ROAD] = ("Silniční doprava"),
            [constants.TRANSPORT_TYPE_TRAM] = ("Tramvajová doprava"),
            [constants.TRANSPORT_TYPE_RAIL] = ("Železniční doprava"),
            [constants.TRANSPORT_TYPE_WATER] = ("Lodní doprava"),
            [constants.TRANSPORT_TYPE_AIR] = ("Letecká doprava"),
            [constants.TRANSPORT_TYPE_ALL] = ("Veškerá doprava"),
            [constants.CAT_TOTAL] = ("Celkem"),
            [constants.CAT_INCOME] = ("Příjem"),
            [constants.CAT_MAINTENANCE] = ("Údržba"),
            [constants.CAT_MAINTENANCE_VEHICLES] = ("Vozidla"),
            [constants.CAT_MAINTENANCE_INFRASTRUCTURE] = ("Infrastruktura"),
            [constants.CAT_INVESTMENTS] = ("Investice"),
            [constants.CAT_INVESTMENTS_VEHICLES] = ("Vozidla"),
            [constants.CAT_INVESTMENTS_TRACKS] = ("Železnice"),
            [constants.CAT_INVESTMENTS_ROADS] = ("Silnice"),
            [constants.CAT_INVESTMENTS_INFRASTRUCTURE] = ("Infrastruktura"),
            [constants.CAT_CASHFLOW] = ("Provozní zisk"),
            [constants.CAT_MARGIN] = ("Provozní marže"),
            [constants.CAT_PROFIT] = ("Zisk"),
            [constants.CAT_LOAN] = ("Půjčka"),
            [constants.CAT_INTEREST] = ("Úroky"),
            [constants.CAT_OTHER] = ("Ostatní"),
            [constants.CAT_BALANCE] = ("Zůstatek"),
            [constants.COLUMN_TOTAL] = ("Celkem"),
			["pm-Parameter.Label"] = ("Počet roků v přehledu"),
			["pm-Parameter.Tooltip"] = ("Vyberte počet roků, které se mají zobrazit v tabulce finančního přehledu."),
            [constants.TOOLTIP .. constants.CAT_TOTAL] = ("Celkový zisk jako součet příjmů snížený o údržbu a investice."),
            [constants.TOOLTIP .. constants.CAT_INCOME] = ("Příjem z jízdenek."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE] = ("Celková údržba včetně vozidel a infrastruktury."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE_VEHICLES] = ("Náklady na údržbu vozidel."),
            [constants.TOOLTIP .. constants.CAT_MAINTENANCE_INFRASTRUCTURE] = ("Náklady na údržbu stanic, dep a případně kolejí či silnic."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS] = ("Celkové investice včetně vozidel, infrastruktury a případně kolejí či silnic."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_VEHICLES] = ("Nákup nových vozidel."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_INFRASTRUCTURE] = ("Stavba nových budov."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_ROADS] = ("Stavba nových silnic."),
            [constants.TOOLTIP .. constants.CAT_INVESTMENTS_TRACKS] = ("Stavba nových kolejí."),
            [constants.TOOLTIP .. constants.CAT_CASHFLOW] = ("Provozní zisk jako součet příjmů snížený o údržbu."),
            [constants.TOOLTIP .. constants.CAT_MARGIN] = ("Provozní zisk jako procento příjmů, který udává, jak efektivně společnost přeměňuje příjmy na provozní zisk."),
            [constants.TOOLTIP .. constants.CAT_PROFIT] = ("Celkový zisk jako součet příjmů snížený o údržbu a investice ze všech druhů dopravy."),
            [constants.TOOLTIP .. constants.CAT_LOAN] = ("Částka vypůjčená od banky."),
            [constants.TOOLTIP .. constants.CAT_INTEREST] = ("Úroky zaplacené z vypůjčených peněz."),
            [constants.TOOLTIP .. constants.CAT_OTHER] = ("Ostatní výdaje bez konkrétní kategorie, např. terénní úpravy."),
            [constants.TOOLTIP .. constants.CAT_BALANCE] = ("Aktuální zůstatek na účtu."),
            [constants.TOOLTIP_GAMEINFO] = ("Provozní zisk jako součet příjmů snížený o údržbu od začátku roku.")
		}
	}
end