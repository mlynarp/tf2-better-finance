function IsLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function GetDaysInMonth(month, year)
    local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and IsLeapYear(year) then
        return 29
    else
        return daysInMonth[month]
    end
end

function GetCurrentGameYear()
    return game.interface.getGameTime().date.year
end

function GetYearTimeLength(year)
    local millisPerDay = game.interface.getMillisPerDay()
    if IsLeapYear(year) then
        return 366 * millisPerDay
    else
        return 365 * millisPerDay
    end
end

function GetYearStartTime(year)
    local gameTime = game.interface.getGameTime()
    local millisPerDay = game.interface.getMillisPerDay()

    local currentDayStartTime = math.floor((gameTime.time * 1000) / millisPerDay) * millisPerDay
    local daysFromYearStart = gameTime.date.day - 1

    for i = 1, gameTime.date.month - 1 do
        daysFromYearStart = daysFromYearStart + GetDaysInMonth(i, gameTime.date.year)
    end

    local currentYearStartTime = currentDayStartTime - (daysFromYearStart * millisPerDay)
    for i = year, GetCurrentGameYear() - 1 do
        currentYearStartTime = currentYearStartTime - GetYearTimeLength(i)
    end

    if currentYearStartTime < 0 then
        currentYearStartTime = 0
    end
    return currentYearStartTime
end

function GetYearStartEndTime(year)
    if year == GetCurrentGameYear() then
        return { GetYearStartTime(year), game.interface.getGameTime().time * 1000 }
    else
        return { GetYearStartTime(year), GetYearStartTime(year + 1) }
    end
end

function GetJournal(year)
    if year == 0 then
        return game.interface.getPlayerJournal(0, game.interface.getGameTime().time * 1000, false)
    else
        local yearStartEnd = GetYearStartEndTime(year)
        return game.interface.getPlayerJournal(yearStartEnd[1], yearStartEnd[2], false)
    end
end

function GetJournalKeyForTransport(transportType)
    if transportType == TRANSPORT_TYPE_ROAD then
        return "road"
    elseif transportType == TRANSPORT_TYPE_TRAM then
        return "tram"
    elseif transportType == TRANSPORT_TYPE_RAIL then
        return "rail"
    elseif transportType == TRANSPORT_TYPE_WATER then
        return "water"
    elseif transportType == TRANSPORT_TYPE_AIR then
        return "air"
    end
    return nil
end

function GetTotalValueFromJournal(journal, category)
    local result = 0
    for i = 1, #TRANSPORT_TYPES - 1 do
        result = result + GetValueFromJournal(journal, TRANSPORT_TYPES[i], category)
    end
    return result
end

function GetValueOrZero(value)
    if value == nil then
        return 0
    end
    return value
end

function GetValueFromJournal(journal, transportType, category)
    local transportKey = GetJournalKeyForTransport(transportType)
    if transportKey == nil then
        return GetTotalValueFromJournal(journal, category)
    end

     --total
    if category == CAT_TOTAL then
        return  GetValueFromJournal(journal, transportType, CAT_INCOME) +
                GetValueFromJournal(journal, transportType, CAT_MAINTENANCE) +
                GetValueFromJournal(journal, transportType, CAT_INVESTMENTS)
    --income
    elseif category == CAT_INCOME then
        return GetValueOrZero(journal.income[transportKey])
    --maintenance
    elseif category == CAT_MAINTENANCE then
        return  GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_VEHICLES) +
                GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_INFRASTRUCTURE)
    elseif category == CAT_MAINTENANCE_VEHICLES then
        return GetValueOrZero(journal.maintenance[transportKey].vehicle)
    elseif category == CAT_MAINTENANCE_INFRASTRUCTURE then
        return GetValueOrZero(journal.maintenance[transportKey].infrastructure)
    --investment		
    elseif category == CAT_INVESTMENTS then
        return  GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_VEHICLES) +
                GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_TRACKS) +
                GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_ROADS) +
                GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_INFRASTRUCTURE)
    elseif category == CAT_INVESTMENTS_VEHICLES then
        return GetValueOrZero(journal.acquisition[transportKey])
    elseif category == CAT_INVESTMENTS_TRACKS then
        return GetValueOrZero(journal.construction[transportKey].track)
    elseif category == CAT_INVESTMENTS_ROADS then
        return GetValueOrZero(journal.construction[transportKey].street)
    elseif category == CAT_INVESTMENTS_INFRASTRUCTURE then
        return  GetValueOrZero(journal.construction[transportKey].station) +
                GetValueOrZero(journal.construction[transportKey].depot) +
                GetValueOrZero(journal.construction[transportKey].signal)
    --cashflow
    elseif category == CAT_CASHFLOW then
        return  GetValueFromJournal(journal, transportType, CAT_INCOME) +
                GetValueFromJournal(journal, transportType, CAT_MAINTENANCE)
    end
end
