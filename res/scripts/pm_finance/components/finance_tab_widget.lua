local transport = require "pm_finance/constants/transport"
local columns = require "pm_finance/constants/columns"

local guiTabWidget = require "pm_finance/gui/tab_widget"
local guiImageView = require "pm_finance/gui/image_view"
local guiLayout = require "pm_finance/gui/layout"

local compTransportTable = require "pm_finance/components/transport_table"

local constants = {}
local functions = {}

constants.FinanceTabWidget = { Id = "pm-financeTabWidget", Name =  "FinanceTabWidget"}
constants.TransportTable = { Id = "pm-transportTable", Name =  "TransportTable"}


function functions.CreateFinanceTabWidget()
	local financeTabWidget = guiTabWidget.functions.CreateTabWidget(guiTabWidget.constants.ORIENTATION.TOP, constants.FinanceTabWidget.Id, constants.FinanceTabWidget.Name)

    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        local iconView = guiImageView.functions.CreateImageView(transport.functions.IconPathForTransportType(transportType))
        iconView:setTooltip(_(transportType))
        
        local table = compTransportTable.functions.CreateTransportTable(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2, transportType)
        guiTabWidget.functions.AddTab(financeTabWidget, guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, {iconView}, ""), table)
    end

    guiTabWidget.functions.SelectTab(financeTabWidget, 0)
	return financeTabWidget
end

local financeTabWidget = {}
financeTabWidget.constants = constants
financeTabWidget.functions = functions

return financeTabWidget