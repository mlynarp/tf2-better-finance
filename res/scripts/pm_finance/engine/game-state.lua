local categories = require "pm_finance/constants/categories"

local gameState = {
    gameData = {},
    constants = {},
    functions = {}
}

function gameState.functions.GetYearState(year)
    return gameState.gameData[tostring(year)]
end


return gameState