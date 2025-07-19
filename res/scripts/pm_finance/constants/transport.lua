local constants = {}
local functions = {}

constants.ROAD = "Transport.Road"
constants.TRAM = "Transport.Tram"
constants.RAIL = "Transport.Rail"
constants.WATER = "Transport.Water"
constants.AIR = "Transport.Air"
constants.ALL = "Transport.All"

constants.TRANSPORT_TYPES =
{ 
    constants.ALL,
    constants.ROAD,
    constants.TRAM,
    constants.RAIL,
    constants.WATER,
    constants.AIR
}

function functions.IconPathForTransportType(transportType)
    if (transportType == constants.ALL) then
        return "ui/icons/construction-menu/filter_all.tga"
    end

    if (transportType == constants.ROAD) then
        return "ui/icons/construction-menu/filter_bus.tga"
    end

    if (transportType == constants.TRAM) then
        return "ui/icons/construction-menu/filter_tram.tga"
    end

    if (transportType == constants.RAIL) then
        return "ui/icons/construction-menu/filter_train.tga"
    end

    if (transportType == constants.WATER) then
        return "ui/icons/construction-menu/filter_ship.tga"
    end

    if (transportType == constants.AIR) then
        return "ui/icons/construction-menu/filter_plane.tga"
    end

    return ""
end

local transport = {}
transport.constants = constants
transport.functions = functions

return transport
