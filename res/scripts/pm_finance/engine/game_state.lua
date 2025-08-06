local gameState = {
    gameData = {},
    constants = {},
    functions = {}
}

gameState.constants.COLORS = "Colors"

function gameState.functions.GetYearState(year)
    return gameState.gameData[tostring(year)]
end

function gameState.functions.StoreColor(key, color)
    local storedColors = gameState.gameData[gameState.constants.COLORS]
    if storedColors == nil then
        storedColors = {}
        gameState.gameData[gameState.constants.COLORS] = storedColors
    end

    storedColors[key] = { R = tonumber(color.x), G = tonumber(color.y), B = tonumber(color.z) }
end

function gameState.functions.GetColor(key)
    local storedColors = gameState.gameData[gameState.constants.COLORS]
    if storedColors == nil or storedColors[key] == nil then
        return nil
    end
    local color = storedColors[key]
    return api.type.Vec3f.new(color.R, color.G, color.B)
end

return gameState