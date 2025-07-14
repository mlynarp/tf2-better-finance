local guiImage = require "pm_finance/gui/image_view"
local guiTable = require "pm_finance/gui/table_view"

local styles = require "pm_finance/constants/styles"

local constants = {}
local functions = {}

function functions.CreateButton(component)
    local button = api.gui.comp.Button.new(component, false)
    return button
end

function functions.CreateExpandButton(tableView, rowIndex, level)
    local iconExpandPath = "ui/design/components/slim_arrow_right@2x.tga"
    local iconCollapsePath = "ui/design/components/slim_arrow_down@2x.tga"
    
    local imageView = guiImage.functions.CreateImageView(iconCollapsePath)
    local button = functions.CreateButton(imageView)
        
    button:addStyleClass( styles.button.BUTTON )
    button:onClick(function()
        local startRowIndex = rowIndex + 1
        local lastRowIndex = tableView:getNumRows() - 1
        local setToVisible = not tableView:getItem(startRowIndex, 0):isVisible()
        for row = startRowIndex, lastRowIndex do
            if tonumber(tableView:getItem(row, 0):getName()) <= level then
                lastRowIndex = row - 1
                break
            end
        end
        for row = startRowIndex, lastRowIndex do
            guiTable.functions.SetRowVisibilityInTable(tableView, row, setToVisible)
            if setToVisible then
                guiImage.functions.SetImagePath(imageView, iconCollapsePath)
            else
                guiImage.functions.SetImagePath(imageView, iconExpandPath)
            end
        end
    end)

    return button
end

local button = {}
button.constants = constants
button.functions = functions

return button
