local constants = {}

constants.TRANSPORT_TYPE_ROAD = "Transport.Road"
constants.TRANSPORT_TYPE_TRAM = "Transport.Tram"
constants.TRANSPORT_TYPE_RAIL = "Transport.Rail"
constants.TRANSPORT_TYPE_WATER = "Transport.Water"
constants.TRANSPORT_TYPE_AIR = "Transport.Air"
constants.TRANSPORT_TYPE_ALL = "Transport.All"

constants.CAT_TOTAL = "Cat.Total"
constants.CAT_INCOME = "Cat.Income"
constants.CAT_MAINTENANCE = "Cat.Maintenance"
constants.CAT_MAINTENANCE_VEHICLES = "Cat.Maintenance.Vehicles"
constants.CAT_MAINTENANCE_INFRASTRUCTURE = "Cat.Maintenance.Infrastructure"
constants.CAT_INVESTMENTS = "Cat.Investments"
constants.CAT_INVESTMENTS_VEHICLES = "Cat.Investments.Vehicles"
constants.CAT_INVESTMENTS_TRACKS = "Cat.Investments.Tracks"
constants.CAT_INVESTMENTS_ROADS = "Cat.Investments.Roads"
constants.CAT_INVESTMENTS_INFRASTRUCTURE = "Cat.Investments.Infrastructure"
constants.CAT_CASHFLOW = "Cat.Cashflow"
constants.CAT_MARGIN = "Cat.Margin"
constants.CAT_PROFIT = "Cat.Profit"
constants.CAT_LOAN = "Cat.Loan"
constants.CAT_INTEREST = "Cat.Interest"
constants.CAT_OTHER = "Cat.Other"
constants.CAT_BALANCE = "Cat.Balance"

constants.COLUMN_LABEL = "Column.Label"
constants.COLUMN_YEAR = "Column.Year"
constants.COLUMN_TOTAL = "Column.Total"

constants.TRANSPORT_TYPES =
{ 
    constants.TRANSPORT_TYPE_ROAD,
    constants.TRANSPORT_TYPE_TRAM,
    constants.TRANSPORT_TYPE_RAIL,
    constants.TRANSPORT_TYPE_WATER,
    constants.TRANSPORT_TYPE_AIR,
    constants.TRANSPORT_TYPE_ALL
}

constants.TRANSPORT_CATEGORIES_LEVEL1 =
{
    constants.CAT_INCOME,
    constants.CAT_MAINTENANCE,
    constants.CAT_INVESTMENTS
}

constants.TRANSPORT_CATEGORIES_LEVEL2 =
{
    [constants.CAT_INCOME] = {},
    [constants.CAT_MAINTENANCE] = { constants.CAT_MAINTENANCE_VEHICLES, constants.CAT_MAINTENANCE_INFRASTRUCTURE },
    [constants.CAT_INVESTMENTS] = { constants.CAT_INVESTMENTS_VEHICLES, constants.CAT_INVESTMENTS_INFRASTRUCTURE, constants.CAT_INVESTMENTS_TRACKS, constants.CAT_INVESTMENTS_ROADS }
}

constants.NUMBER_OF_YEARS_COLUMNS = 4

constants.STYLE_BUTTON = "pm-style-button"
constants.STYLE_TABLE_CELL = "pm-style-table-cell"
constants.STYLE_TABLE_HEADER = "pm-style-table-header"

constants.STYLE_TEXT_LEFT = "pm-style-text-left"
constants.STYLE_TEXT_RIGHT = "pm-style-text-right"

constants.STYLE_LEVEL_0 = "pm-style-level-0"
constants.STYLE_LEVEL_1 = "pm-style-level-1"
constants.STYLE_LEVEL_2 = "pm-style-level-2"
constants.STYLE_LEVEL_PADDING = "pm-style-level-padding"

constants.STYLE_SUMMARY_LABEL = "pm-style-summary-label"
constants.STYLE_SUMMARY_TABLE = "pm-style-summary-table"

constants.TOOLTIP = "pm-Tooltip"
constants.TOOLTIP_GAMEINFO = "pm-Tooltip.GameInfo"

return constants
