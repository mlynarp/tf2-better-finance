require "tableutil"

-------------------------------------------
-- Iterate over a table in sorted key order
-------------------------------------------
function getTableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
-------------------------------------------
-- Number Formatting 
-------------------------------------------
function comma_value(amount)
  local formatted = amount
  local k
  while true do  
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function format_num(amount, decimal, prefix, neg_prefix,suffix)
  local str_amount,  formatted, famount, remain

  decimal = decimal or 2  -- default 2 decimal places
  neg_prefix = neg_prefix or "-" -- default negative sign

  famount = math.abs(round(amount,decimal))
  famount = math.floor(famount)

  remain = round(math.abs(amount) - famount, decimal)

        -- comma to separate the thousands
  formatted = comma_value(famount)

        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end

        -- attach prefix string e.g '$' 
  formatted = (prefix or "") .. formatted .. (suffix or "")

        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted 
    end
  end

  return formatted
end

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

-------------------------------------------
-- GameTime Helper
-------------------------------------------
function getClosestYearStart(gameTime)
	local time = math.floor(gameTime/730.5)*730.5
	local year =(math.floor(gameTime/730.5)+1)
	local month = (math.floor(((gameTime/730.5)%1)*12)+1)
	local refreshes = {time + (730.5/12)*0,time + (730.5/12)*2,time + (730.5/12)*4,time + (730.5/12)*6,time + (730.5/12)*8,time + (730.5/12)*10}
	return  {time , year, month,refreshes}
end
function getYearStart_End(Year)
	if Year and type(Year)=="number" then
		local result = {((Year-1)*730.5)*1000,1000*(((Year)*730.5)-0.001)}
		return result
	else 
		return {0,0}
	end
end
function getCurrentGameYear()
	return getClosestYearStart(api.engine.getComponent(0,16).gameTime/1000)[2]
end
function getCurrentGameMonth()
	return getClosestYearStart(api.engine.getComponent(0,16).gameTime/1000)[3]
end
function getYearForTimeMils(timeInMils)
	return getClosestYearStart(timeInMils/1000)[2]
end
function getRefreshStart(time)
	local importantTime = getClosestYearStart(time)
	local returnValue = nil
	if time >= importantTime[4][1] and time < importantTime[4][2] then
		returnValue =importantTime[4][1]
	elseif time >= importantTime[4][2] and time < importantTime[4][3] then
		returnValue =importantTime[4][2]
	elseif time >= importantTime[4][3] and time < importantTime[4][4] then
		returnValue =importantTime[4][3]
	elseif time >= importantTime[4][4] and time < importantTime[4][5] then
		returnValue =importantTime[4][4]
	elseif time >= importantTime[4][5] and time < importantTime[4][6] then
		returnValue =importantTime[4][5]
	else
		returnValue =importantTime[4][6]
	end
	return returnValue
end
