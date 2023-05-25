function isLeapYear(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

function getDaysInMonth(month, year)
    local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 and isLeapYear(year) then
        return 29
    else
        return daysInMonth[month]
    end
end

function getCurrentGameYear()
    return game.interface.getGameTime().date.year
end

function getYearTimeLength(year)
    local millisPerDay = game.interface.getMillisPerDay()
    if isLeapYear(year) then
        return 366 * millisPerDay
    else
        return 365 * millisPerDay
    end
end

function getYearStartTime(year)
    local gameTime = game.interface.getGameTime()
    local millisPerDay = game.interface.getMillisPerDay()

    local currentDayStartTime = math.floor((gameTime.time * 1000) / millisPerDay) * millisPerDay
    local daysFromYearStart = gameTime.date.day - 1

    for i = 1, gameTime.date.month - 1 do
        daysFromYearStart = daysFromYearStart + getDaysInMonth(i, gameTime.date.year)
    end

    local currentYearStartTime = currentDayStartTime - (daysFromYearStart * millisPerDay)
    for i = year, getCurrentGameYear() - 1 do
        currentYearStartTime = currentYearStartTime - getYearTimeLength(i)
    end

    if currentYearStartTime < 0 then
        currentYearStartTime = 0
    end
    return currentYearStartTime
end

function getYearStartEndTime(year)
    if year == getCurrentGameYear() then
        return { getYearStartTime(year), game.interface.getGameTime().time * 1000 }
    else
        return { getYearStartTime(year), getYearStartTime(year + 1) }
    end
end

function getJournal(year)
    if year == 0 then
        return game.interface.getPlayerJournal(0, game.interface.getGameTime().time * 1000, false)
    else
        local yearStartEnd = getYearStartEndTime(year)
        return game.interface.getPlayerJournal(yearStartEnd[1], yearStartEnd[2], false)
    end
end
