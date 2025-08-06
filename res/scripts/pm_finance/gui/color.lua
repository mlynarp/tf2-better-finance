local constants = {}
local functions = {}

function functions.MakeAlphaColor(intRGBA)
	return api.type.Vec4f.new(intRGBA[1] / 255.0, intRGBA[2] / 255.0, intRGBA[3] / 255.0, intRGBA[4] / 255.0)
end

function functions.MakeColor(intRGB)
	return api.type.Vec3f.new(intRGB[1] / 255.0, intRGB[2] / 255.0, intRGB[3] / 255.0)
end

function functions.ConvertColorToAlphaColor(color)
    return api.type.Vec4f.new(color[1], color[2], color[3], 1.0)
end

local color = {}
color.constants = constants
color.functions = functions

return color