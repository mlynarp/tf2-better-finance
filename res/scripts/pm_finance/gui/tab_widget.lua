local constants = {}
local functions = {}

constants.ORIENTATION = { TOP = "NORTH", LEFT = "WEST", BOTTOM = "SOUTH", RIGHT = "EAST" }

function functions.CreateTabWidget(orientation, id, name)
	local tabWidget = api.gui.comp.TabWidget.new(orientation or constants.ORIENTATION.TOP)
	tabWidget:setDeselectAllowed(false)

    if (id) then
        tabWidget:setId(id)
    end

    if (name) then
        tabWidget:setName(name)
    end

	return tabWidget
end

function functions.AddTab(tabWidget, indicator, content)
    tabWidget:addTab(indicator, content)
end

function functions.InsertTab(tabWidget, position,  indicator, content)
    tabWidget:insertTab(indicator, content, position)
end

function functions.SelectTab(tabWidget, index)
    tabWidget:setCurrentTab(index or 0, true)
end

local tabWidget = {}
tabWidget.constants = constants
tabWidget.functions = functions

return tabWidget