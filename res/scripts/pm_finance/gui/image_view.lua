local constants = {}
local functions = {}

function functions.CreateImageView(imagePath)
    local imageView = api.gui.comp.ImageView.new(imagePath)
    return imageView
end

function functions.SetImagePath(imageView, imagePath)
    imageView:setImage(imagePath, true)
end

local imageView = {}
imageView.constants = constants
imageView.functions = functions

return imageView