require "pm_finance_constants"

function data()
	return {
		en = {
            [TRANSPORT_TYPE_ROAD] = ("Road transport"),
            [TRANSPORT_TYPE_TRAM] = ("Tram transport"),
            [TRANSPORT_TYPE_RAIL] = ("Railroad transport"),
            [TRANSPORT_TYPE_WATER] = ("Water transport"),
            [TRANSPORT_TYPE_AIR] = ("Air transport"),
            [TRANSPORT_TYPE_ALL] = ("All transport"),
            [CAT_TOTAL] = ("Total"),
            [CAT_INCOME] = ("Income"),
            [CAT_MAINTENANCE] = ("Maintenance"),
            [CAT_MAINTENANCE_VEHICLES] = ("Vehicles"),
            [CAT_MAINTENANCE_INFRASTRUCTURE] = ("Infrastructure"),
            [CAT_INVESTMENTS] = ("Investments"),
            [CAT_INVESTMENTS_VEHICLES] = ("Vehicles"),
            [CAT_INVESTMENTS_TRACKS] = ("Railways"),
            [CAT_INVESTMENTS_ROADS] = ("Roads"),
            [CAT_INVESTMENTS_INFRASTRUCTURE] = ("Infrastructure"),
            [CAT_CASHFLOW] = ("Cashflow"),
            [CAT_PROFIT] = ("Profit"),
            [CAT_LOAN] = ("Loan"),
            [CAT_INTEREST] = ("Interest"),
            [CAT_OTHER] = ("Others"),
            [CAT_BALANCE] = ("Balance"),
            [COLUMN_TOTAL] = ("Total"),
            ["Parameter.Label"] = ("Number of years in overview"),
            ["Parameter.Tooltip"] = ("Choose the number of years to be displayed in the financial overview table."),
            [TOOLTIP .. CAT_TOTAL] = ("Overall profit as sum of income deducted by maintenance and investments"),
            [TOOLTIP .. CAT_INCOME] = ("Revenue from tickets."),
            [TOOLTIP .. CAT_MAINTENANCE] = ("Total maintenance incl. vehicles and infrastructure."),
            [TOOLTIP .. CAT_MAINTENANCE_VEHICLES] = ("Maintenance from the operation of vehicles."),
            [TOOLTIP .. CAT_MAINTENANCE_INFRASTRUCTURE] = ("Maintenance from the operation of stations, depots and tracks or roads if relevant."),
            [TOOLTIP .. CAT_INVESTMENTS] = ("Total investments incl. vehicles, infrastructure and tracks or roads if relevant."),
            [TOOLTIP .. CAT_INVESTMENTS_VEHICLES] = ("Acquisition of new vehicles."),
            [TOOLTIP .. CAT_INVESTMENTS_INFRASTRUCTURE] = ("Construction of new buildings."),
            [TOOLTIP .. CAT_INVESTMENTS_ROADS] = ("Construction of new roads."),
            [TOOLTIP .. CAT_INVESTMENTS_TRACKS] = ("Construction of new tracks."),
            [TOOLTIP .. CAT_CASHFLOW] = ("Operating profit as sum of income deducted by maintenance."),
            [TOOLTIP .. CAT_PROFIT] = ("Overall profit as sum of income deducted by maintenance and investments from all transports."),
            [TOOLTIP .. CAT_LOAN] = ("Amount of money borrowed from the bank."),
            [TOOLTIP .. CAT_INTEREST] = ("Interest paid on borrowed money."),
            [TOOLTIP .. CAT_OTHER] = ("Other expenditure without a specific category, e.g. landscaping."),
            [TOOLTIP .. CAT_BALANCE] = ("Current bank balance."),
            [TOOLTIP_GAMEINFO] = ("Operating profit as sum of income deducted by maintenance since the beginning of the year."),
            ["DESCRIPTION"] = ( "Do you want to see finance better organized?\n"..
                                "Do you want to see totals for each transport category or just operating profit?\n"..
                                "Do you want to have yearly based accounting independent of game calendar speed?\n"..
                                "Do you want to see current year cashflow instead of earnings in buttom status bar?\n\n"..
                            
                                "This mod shows finances organized per transport type or all transport category. It always shows accounting on yearly base.\n"..

                                "Version 1.0 release notes:\n"..
                                "    - each transport has its own category in finance overview including trams (original table is replaced)\n"..
                                "    - every transport category show data per configurable number of years backwar and totals\n"..
                                "    - summary table with the overall profit, loan, interest, other and bank account\n"..
                                "    - every cell in table has a proper tooltip\n"..
                                "    - earnings field in status bar was replaced by cashflow field to show current year progress\n"..
                                "    - english, czech translation\n"..
                                
                                "Any feedback is highly appreciated.")
		},
		cs_CZ = {
            [TRANSPORT_TYPE_ROAD] = ("Silniční doprava"),
            [TRANSPORT_TYPE_TRAM] = ("Tramvajová doprava"),
            [TRANSPORT_TYPE_RAIL] = ("Železniční doprava"),
            [TRANSPORT_TYPE_WATER] = ("Lodní doprava"),
            [TRANSPORT_TYPE_AIR] = ("Letecká doprava"),
            [TRANSPORT_TYPE_ALL] = ("Veškerá doprava"),
            [CAT_TOTAL] = ("Celkem"),
            [CAT_INCOME] = ("Příjem"),
            [CAT_MAINTENANCE] = ("Údržba"),
            [CAT_MAINTENANCE_VEHICLES] = ("Vozidla"),
            [CAT_MAINTENANCE_INFRASTRUCTURE] = ("Infrastruktura"),
            [CAT_INVESTMENTS] = ("Investice"),
            [CAT_INVESTMENTS_VEHICLES] = ("Vozidla"),
            [CAT_INVESTMENTS_TRACKS] = ("Železnice"),
            [CAT_INVESTMENTS_ROADS] = ("Silnice"),
            [CAT_INVESTMENTS_INFRASTRUCTURE] = ("Infrastruktura"),
            [CAT_CASHFLOW] = ("Provozní zisk "),
            [CAT_PROFIT] = ("Zisk"),
            [CAT_LOAN] = ("Půjčka"),
            [CAT_INTEREST] = ("Úroky"),
            [CAT_OTHER] = ("Ostatní"),
            [CAT_BALANCE] = ("Zůstatek"),
            [COLUMN_TOTAL] = ("Celkem"),
			["Parameter.Label"] = ("Počet roků v přehledu"),
			["Parameter.Tooltip"] = ("Vyberte počet roků, které se mají zobrazit v tabulce finančního přehledu."),
            [TOOLTIP .. CAT_TOTAL] = ("Celkový zisk jako součet příjmů snížený o údržbu a investice."),
            [TOOLTIP .. CAT_INCOME] = ("Příjem z jízdenek."),
            [TOOLTIP .. CAT_MAINTENANCE] = ("Celková údržba včetně vozidel a infrastruktury."),
            [TOOLTIP .. CAT_MAINTENANCE_VEHICLES] = ("Náklady na údržbu vozidel."),
            [TOOLTIP .. CAT_MAINTENANCE_INFRASTRUCTURE] = ("Náklady na údržbu stanic, dep a případně kolejí či silnic."),
            [TOOLTIP .. CAT_INVESTMENTS] = ("Celkové investice včetně vozidel, infrastruktury a případně kolejí či silnic."),
            [TOOLTIP .. CAT_INVESTMENTS_VEHICLES] = ("Nákup nových vozidel."),
            [TOOLTIP .. CAT_INVESTMENTS_INFRASTRUCTURE] = ("Stavba nových budov."),
            [TOOLTIP .. CAT_INVESTMENTS_ROADS] = ("Stavba nových silnic."),
            [TOOLTIP .. CAT_INVESTMENTS_TRACKS] = ("Stavba nových kolejí."),
            [TOOLTIP .. CAT_CASHFLOW] = ("Provozní zisk jako součet příjmů snížený o údržbu."),
            [TOOLTIP .. CAT_PROFIT] = ("Celkový zisk jako součet příjmů snížený o údržbu a investice ze všech druhů dopravy."),
            [TOOLTIP .. CAT_LOAN] = ("Částka vypůjčená od banky."),
            [TOOLTIP .. CAT_INTEREST] = ("Úroky zaplacené z vypůjčených peněz."),
            [TOOLTIP .. CAT_OTHER] = ("Ostatní výdaje bez konkrétní kategorie, např. terénní úpravy."),
            [TOOLTIP .. CAT_BALANCE] = ("Aktuální zůstatek na účtu."),
            [TOOLTIP_GAMEINFO] = ("Provozní zisk jako součet příjmů snížený o údržbu od začátku roku."),
		}
	}
end