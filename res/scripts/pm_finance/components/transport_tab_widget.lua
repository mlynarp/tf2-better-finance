local transport = require "pm_finance/constants/transport"

local guiTabWidget = require "pm_finance/gui/tab_widget"
local guiImageView = require "pm_finance/gui/image_view"
local guiLayout = require "pm_finance/gui/layout"

local constants = {}
local functions = {}

constants.TransportTabWidget = { Id = "pm-transportTabWidget", Name =  "TransportTabWidget"}

function functions.CreateTabWidget(subId, contentFunction)
	local tabWidget = guiTabWidget.functions.CreateTabWidget(guiTabWidget.constants.ORIENTATION.TOP, constants.TransportTabWidget.Id .. subId, constants.TransportTabWidget.Name)

    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        local iconView = guiImageView.functions.CreateImageView(transport.functions.IconPathForTransportType(transportType))
        iconView:setTooltip(_(transportType))
        
        local widget = contentFunction(transportType)
        guiTabWidget.functions.AddTab(tabWidget, guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, {iconView}, ""), widget)
    end

    guiTabWidget.functions.SelectTab(tabWidget, 0)
	return tabWidget
end

local transportTabWidget = {}
transportTabWidget.constants = constants
transportTabWidget.functions = functions

return transportTabWidget