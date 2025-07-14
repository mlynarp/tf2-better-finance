local columns = require "pm_finance/constants/columns"

local calendar = {
    gameState = {}
}

local constants = {}
local functions = {}

function functions.GetGameStatePerYear(year)
    return calendar.gameState[tostring(year)]
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

function functions.GetYearFromYearIndex(yearIndex)
    return functions.GetCurrentGameYear() - columns.constants.NUMBER_OF_YEARS_COLUMNS + yearIndex
end

calendar.constants = constants
calendar.functions = functions

return calendar