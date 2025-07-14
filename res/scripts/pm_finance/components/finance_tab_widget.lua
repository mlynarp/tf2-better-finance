local transport = require "pm_finance/constants/transport"
local columns = require "pm_finance/constants/columns"

local tabWidget = require "pm_finance/gui/tab_widget"
local imageView = require "pm_finance/gui/image_view"
local layout = require "pm_finance/gui/layout"

local transportTable = require "pm_finance/components/transport_table"

local constants = {}
local functions = {}

constants.FinanceTabWidget = { Id = "pm-financeTabWidget", Name =  "FinanceTabWidget"}
constants.TransportTable = { Id = "pm-transportTable", Name =  "TransportTable"}


function functions.CreateFinanceTabWidget()
	local financeTabWidget = tabWidget.functions.CreateTabWidget(tabWidget.constants.ORIENTATION.TOP, constants.FinanceTabWidget.Id, constants.FinanceTabWidget.Name)

    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        local iconView = imageView.functions.CreateImageView(transport.functions.IconPathForTransportType(transportType))
        iconView:setTooltip(_(transportType))
        
        local table = transportTable.functions.CreateTransportTable(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2, transportType)
        tabWidget.functions.AddTab(financeTabWidget, layout.functions.LayoutComponents(layout.constants.ORIENTATION.HORIZONTAL, {iconView}, ""), table)
    end

    tabWidget.functions.SelectTab(financeTabWidget, 0)
	return financeTabWidget
end

local financeTabWidget = {}
financeTabWidget.constants = constants
financeTabWidget.functions = functions

return financeTabWidget