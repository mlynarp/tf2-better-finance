local categories = require "pm_finance/constants/categories"
local transport = require "pm_finance/constants/transport"

local calendar = require "pm_finance/engine/calendar"

local constants = {}
local functions = {}

function functions.GetJournal(year)
    if year == 0 then
        return game.interface.getPlayerJournal(0, game.interface.getGameTime().time * 1000, false)
    else
        local yearStartEnd = calendar.functions.GetYearStartEndTime(year)
        return game.interface.getPlayerJournal(yearStartEnd[1], yearStartEnd[2], false)
    end
end

function functions.GetJournalKeyForTransport(transportType)
    if transportType == transport.constants.TRANSPORT_TYPE_ROAD then
        return "road"
    elseif transportType == transport.constants.TRANSPORT_TYPE_TRAM then
        return "tram"
    elseif transportType == transport.constants.TRANSPORT_TYPE_RAIL then
        return "rail"
    elseif transportType == transport.constants.TRANSPORT_TYPE_WATER then
        return "water"
    elseif transportType == transport.constants.TRANSPORT_TYPE_AIR then
        return "air"
    end
    return nil
end

function functions.GetTotalValueFromJournal(journal, category)
    local result = 0
    for i = 1, #transport.constants.TRANSPORT_TYPES do
        if (transport.constants.TRANSPORT_TYPES[i] ~= transport.constants.TRANSPORT_TYPE_ALL) then
            result = result + functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPES[i], category)
        end
    end
    return result
end

function functions.GetValueOrZero(value)
    if value == nil then
        return 0
    end
    return value
end

function functions.GetSafePrc(aval, bval)
	if functions.GetValueOrZero(bval) == 0 then
	   return 0
    end
    return (functions.GetValueOrZero(aval) / bval) * 100
end

function functions.GetValueFromJournal(journal, transportType, category)
    local transportKey = functions.GetJournalKeyForTransport(transportType)
    if transportKey == nil and category ~= categories.constants.CAT_MARGIN then
        return functions.GetTotalValueFromJournal(journal, category)
    end

     --total
    if category == categories.constants.CAT_TOTAL then
        return  functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INCOME) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS)
    --income
    elseif category == categories.constants.CAT_INCOME then
        return functions.GetValueOrZero(journal.income[transportKey])
    --maintenance
    elseif category == categories.constants.CAT_MAINTENANCE then
        return  functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE_VEHICLES) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE_INFRASTRUCTURE)
    elseif category == categories.constants.CAT_MAINTENANCE_VEHICLES then
        return functions.GetValueOrZero(journal.maintenance[transportKey].vehicle)
    elseif category == categories.constants.CAT_MAINTENANCE_INFRASTRUCTURE then
        return functions.GetValueOrZero(journal.maintenance[transportKey].infrastructure)
    --investment		
    elseif category == categories.constants.CAT_INVESTMENTS then
        return  functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_VEHICLES) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_TRACKS) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_ROADS) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INVESTMENTS_INFRASTRUCTURE)
    elseif category == categories.constants.CAT_INVESTMENTS_VEHICLES then
        return functions.GetValueOrZero(journal.acquisition[transportKey])
    elseif category == categories.constants.CAT_INVESTMENTS_TRACKS then
        return functions.GetValueOrZero(journal.construction[transportKey].track)
    elseif category == categories.constants.CAT_INVESTMENTS_ROADS then
        return functions.GetValueOrZero(journal.construction[transportKey].street)
    elseif category == categories.constants.CAT_INVESTMENTS_INFRASTRUCTURE then
        return  functions.GetValueOrZero(journal.construction[transportKey].station) +
                functions.GetValueOrZero(journal.construction[transportKey].depot) +
                functions.GetValueOrZero(journal.construction[transportKey].signal)
    --cashflow
    elseif category == categories.constants.CAT_CASHFLOW then
        return  functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INCOME) +
                functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_MAINTENANCE)
				
    elseif category == categories.constants.CAT_MARGIN then
        return  functions.GetSafePrc(functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_CASHFLOW),
								     functions.GetValueFromJournal(journal, transportType, categories.constants.CAT_INCOME))
    end
end

function functions.GetEndOfYearBalance(year)
    local balance = functions.GetCurrentBalance()
    if calendar.functions.GetCurrentGameYear() == year then
        return balance
    end

    for i = year + 1, calendar.functions.GetCurrentGameYear() do
        balance = balance - functions.GetJournal(i)._sum
    end

    return balance
end

function functions.GetCurrentBalance()
    return game.interface.getEntity(game.interface.getPlayer()).balance
end

local journal = {}
journal.constants = constants
journal.functions = functions

return journal
