local constants = {}
local functions = {}

constants.TRANSPORT_TYPE_ROAD = "Transport.Road"
constants.TRANSPORT_TYPE_TRAM = "Transport.Tram"
constants.TRANSPORT_TYPE_RAIL = "Transport.Rail"
constants.TRANSPORT_TYPE_WATER = "Transport.Water"
constants.TRANSPORT_TYPE_AIR = "Transport.Air"
constants.TRANSPORT_TYPE_ALL = "Transport.All"

constants.TRANSPORT_TYPES =
{ 
    constants.TRANSPORT_TYPE_ALL,
    constants.TRANSPORT_TYPE_ROAD,
    constants.TRANSPORT_TYPE_TRAM,
    constants.TRANSPORT_TYPE_RAIL,
    constants.TRANSPORT_TYPE_WATER,
    constants.TRANSPORT_TYPE_AIR
}

function functions.IconPathForTransportType(transportType)
    if (transportType == constants.TRANSPORT_TYPE_ALL) then
        return "ui/icons/construction-menu/filter_all.tga"
    end

    if (transportType == constants.TRANSPORT_TYPE_ROAD) then
        return "ui/icons/construction-menu/filter_bus.tga"
    end

    if (transportType == constants.TRANSPORT_TYPE_TRAM) then
        return "ui/icons/construction-menu/filter_tram.tga"
    end

    if (transportType == constants.TRANSPORT_TYPE_RAIL) then
        return "ui/icons/construction-menu/filter_train.tga"
    end

    if (transportType == constants.TRANSPORT_TYPE_WATER) then
        return "ui/icons/construction-menu/filter_ship.tga"
    end

    if (transportType == constants.TRANSPORT_TYPE_AIR) then
        return "ui/icons/construction-menu/filter_plane.tga"
    end

    return ""
end

local transport = {}
transport.constants = constants
transport.functions = functions

return transport
