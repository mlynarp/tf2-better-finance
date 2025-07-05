local constants = require "pm_finance/constants"

local functions = {
    gameState = {}
}

function functions.GetGameStatePerYear(year)
    if functions.gameState then
        return functions.gameState[tostring(year)]
    end
    return nil
end

function functions.IsLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function functions.GetDaysInMonth(month, year)
    local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and functions.IsLeapYear(year) then
        return 29
    else
        return daysInMonth[month]
    end
end

function functions.GetCurrentGameYear()
    return game.interface.getGameTime().date.year
end

function functions.GetYearTimeLength(year)
    local millisPerDay = game.interface.getMillisPerDay()
    if functions.IsLeapYear(year) then
        return 366 * millisPerDay
    else
        return 365 * millisPerDay
    end
end

function functions.GetYearStartTime(year)
    local storedTime = functions.GetGameStatePerYear(year)
    if storedTime then
        return storedTime
    end
    local gameTime = game.interface.getGameTime()
    local millisPerDay = game.interface.getMillisPerDay()
    if millisPerDay == 0 then
        return gameTime.time * 1000
    end
    local currentDayStartTime = math.floor((gameTime.time * 1000) / millisPerDay) * millisPerDay
    local daysFromYearStart = gameTime.date.day - 1

    for i = 1, gameTime.date.month - 1 do
        daysFromYearStart = daysFromYearStart + functions.GetDaysInMonth(i, gameTime.date.year)
    end

    local currentYearStartTime = currentDayStartTime - (daysFromYearStart * millisPerDay)
    for i = year, functions.GetCurrentGameYear() - 1 do
        currentYearStartTime = currentYearStartTime - functions.GetYearTimeLength(i)
    end

    if currentYearStartTime < 0 then
        currentYearStartTime = 0
    end
    return currentYearStartTime
end

function functions.GetYearStartEndTime(year)
    if year == functions.GetCurrentGameYear() then
        return { functions.GetYearStartTime(year), game.interface.getGameTime().time * 1000 }
    else
        return { functions.GetYearStartTime(year), functions.GetYearStartTime(year + 1) }
    end
end

function functions.GetJournal(year)
    if year == 0 then
        return game.interface.getPlayerJournal(0, game.interface.getGameTime().time * 1000, false)
    else
        local yearStartEnd = functions.GetYearStartEndTime(year)
        return game.interface.getPlayerJournal(yearStartEnd[1], yearStartEnd[2], false)
    end
end

function functions.GetJournalKeyForTransport(transportType)
    if transportType == constants.TRANSPORT_TYPE_ROAD then
        return "road"
    elseif transportType == constants.TRANSPORT_TYPE_TRAM then
        return "tram"
    elseif transportType == constants.TRANSPORT_TYPE_RAIL then
        return "rail"
    elseif transportType == constants.TRANSPORT_TYPE_WATER then
        return "water"
    elseif transportType == constants.TRANSPORT_TYPE_AIR then
        return "air"
    end
    return nil
end

function functions.GetTotalValueFromJournal(journal, category)
    local result = 0
    for i = 1, #constants.TRANSPORT_TYPES - 1 do
        result = result + functions.GetValueFromJournal(journal, constants.TRANSPORT_TYPES[i], category)
    end
    return result
end

function functions.GetValueOrZero(value)
    if value == nil then
        return 0
    end
    return value
end

function functions.GetValueFromJournal(journal, transportType, category)
    local transportKey = functions.GetJournalKeyForTransport(transportType)
    if transportKey == nil then
        return functions.GetTotalValueFromJournal(journal, category)
    end

     --total
    if category == constants.CAT_TOTAL then
        return  functions.GetValueFromJournal(journal, transportType, constants.CAT_INCOME) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS)
    --income
    elseif category == constants.CAT_INCOME then
        return functions.GetValueOrZero(journal.income[transportKey])
    --maintenance
    elseif category == constants.CAT_MAINTENANCE then
        return  functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_VEHICLES) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE_INFRASTRUCTURE)
    elseif category == constants.CAT_MAINTENANCE_VEHICLES then
        return functions.GetValueOrZero(journal.maintenance[transportKey].vehicle)
    elseif category == constants.CAT_MAINTENANCE_INFRASTRUCTURE then
        return functions.GetValueOrZero(journal.maintenance[transportKey].infrastructure)
    --investment		
    elseif category == constants.CAT_INVESTMENTS then
        return  functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_VEHICLES) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_TRACKS) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_ROADS) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_INVESTMENTS_INFRASTRUCTURE)
    elseif category == constants.CAT_INVESTMENTS_VEHICLES then
        return functions.GetValueOrZero(journal.acquisition[transportKey])
    elseif category == constants.CAT_INVESTMENTS_TRACKS then
        return functions.GetValueOrZero(journal.construction[transportKey].track)
    elseif category == constants.CAT_INVESTMENTS_ROADS then
        return functions.GetValueOrZero(journal.construction[transportKey].street)
    elseif category == constants.CAT_INVESTMENTS_INFRASTRUCTURE then
        return  functions.GetValueOrZero(journal.construction[transportKey].station) +
                functions.GetValueOrZero(journal.construction[transportKey].depot) +
                functions.GetValueOrZero(journal.construction[transportKey].signal)
    --cashflow
    elseif category == constants.CAT_CASHFLOW then
        return  functions.GetValueFromJournal(journal, transportType, constants.CAT_INCOME) +
                functions.GetValueFromJournal(journal, transportType, constants.CAT_MAINTENANCE)
function functions.GetEndOfYearBalance(year)
    local balance = functions.GetCurrentBalance()
    if functions.GetCurrentGameYear() == year then
        return balance
    end

    for i = year + 1, functions.GetCurrentGameYear() do
        balance = balance - functions.GetJournal(i)._sum
    end

    return balance
end

function functions.GetCurrentBalance()
    return game.interface.getEntity(game.interface.getPlayer()).balance
end

function functions.IsCategoryAllowedForTransportType(transportType, category)
    if transportType == constants.TRANSPORT_TYPE_ALL then
        return true
    end
    if category == constants.CAT_INVESTMENTS_TRACKS and transportType ~= constants.TRANSPORT_TYPE_RAIL then
        return false
    elseif category == constants.CAT_INVESTMENTS_ROADS and transportType ~= constants.TRANSPORT_TYPE_ROAD then
        return false
    end
    return true
end

function functions.GetYearFromYearIndex(yearIndex)
    return functions.GetCurrentGameYear() - constants.NUMBER_OF_YEARS_COLUMNS + yearIndex
end

return functions
