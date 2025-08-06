local guiColor = require "pm_finance/gui/color"

local constants = {}
local functions = {}

constants.TOTAL = "Cat.Total"
constants.INCOME = "Cat.Income"
constants.MAINTENANCE = "Cat.Maintenance"
constants.MAINTENANCE_VEHICLES = "Cat.Maintenance.Vehicles"
constants.MAINTENANCE_INFRASTRUCTURE = "Cat.Maintenance.Infrastructure"
constants.INVESTMENTS = "Cat.Investments"
constants.INVESTMENTS_VEHICLES = "Cat.Investments.Vehicles"
constants.INVESTMENTS_TRACKS = "Cat.Investments.Tracks"
constants.INVESTMENTS_ROADS = "Cat.Investments.Roads"
constants.INVESTMENTS_INFRASTRUCTURE = "Cat.Investments.Infrastructure"
constants.CASHFLOW = "Cat.Cashflow"
constants.MARGIN = "Cat.Margin"
constants.PROFIT = "Cat.Profit"
constants.LOAN = "Cat.Loan"
constants.INTEREST = "Cat.Interest"
constants.OTHER = "Cat.Other"
constants.BALANCE = "Cat.Balance"

function functions.GetDefaultColor(category)
    if category == constants.INCOME then
        return guiColor.functions.MakeColor({153,204,255})
    end
    if category == constants.MAINTENANCE then
        return guiColor.functions.MakeColor({255,153,153})
    end
    if category == constants.INVESTMENTS then
        return guiColor.functions.MakeColor({98,237,52})
    end
    if category == constants.CASHFLOW then
        return guiColor.functions.MakeColor({8,0,255})
    end
    if category == constants.TOTAL then
        return guiColor.functions.MakeColor({255,255,255})
    end

    return guiColor.functions.MakeColor({0,0,0})
end

local category = {}
category.constants = constants
category.functions = functions

return category
