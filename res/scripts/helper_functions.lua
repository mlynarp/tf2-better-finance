require "tableutil"

local function isLeapYear(year)
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local function getDaysInMonth(month, year)
  local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
  
  if month == 2 and isLeapYear(year) then
    return 29
  else
    return daysInMonth[month]
  end
end

function getYearStartEndTime(year)
	local currentDate = game.interface.getGameTime().date
  debugPrint(currentDate)
  local currentTime = game.interface.getGameTime().time * 1000
  debugPrint(currentTime)
  local daysFromYearStart = currentDate.day
  debugPrint(daysFromYearStart)
  local millisPerDay = game.interface.getMillisPerDay()
  debugPrint(millisPerDay)

  for i = 1, currentDate.month - 1 do
    daysFromYearStart = daysFromYearStart + getDaysInMonth(i, year)
    debugPrint(daysFromYearStart)
  end

  local yearStart = currentTime - (daysFromYearStart * millisPerDay)
  debugPrint(yearStart)
  if year == currentDate.year then
    return {yearStart, currentTime}
  else
    debugPrint(yearStart - (currentDate.year - year) * 365.25 * millisPerDay)
    debugPrint(yearStart - (currentDate.year - 1 - year) * 365.25 * millisPerDay)
    return {yearStart - (currentDate.year - year) * 365.25 * millisPerDay, yearStart - (currentDate.year - 1 - year) * 365.25 * millisPerDay}
  end
end

function getCurrentGameYear()
	return game.interface.getGameTime().date.year
end

function getYearColumnIndex(year, numberOfColumns)
  return numberOfColumns - (getCurrentGameYear() - year)
end
