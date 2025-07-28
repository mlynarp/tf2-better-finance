local transport = require "pm_finance/constants/transport"
local columns = require "pm_finance/constants/columns"

local engineJournal = require "pm_finance/engine/journal"
local engineCalendar = require "pm_finance/engine/calendar"

local guiTabWidget = require "pm_finance/gui/tab_widget"
local guiImageView = require "pm_finance/gui/image_view"
local guiLayout = require "pm_finance/gui/layout"
local guiComponent = require "pm_finance/gui/component"
local guiTextView = require "pm_finance/gui/text_view"

local compTransportTable = require "pm_finance/components/transport_table"

local constants = {}
local functions = {}

constants.TransportTableTabWidget = { Id = "pm-transportTableTabWidget", Name =  "TransportTableTabWidget"}

function functions.CreateTransportTableTabWidget()
	local tabWidget = guiTabWidget.functions.CreateTabWidget(guiTabWidget.constants.ORIENTATION.TOP, constants.TransportTableTabWidget.Id, constants.TransportTableTabWidget.Name)

    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        local iconView = guiImageView.functions.CreateImageView(transport.functions.IconPathForTransportType(transportType))
        iconView:setTooltip(_(transportType))
        
        local table = compTransportTable.functions.CreateTransportTable(columns.constants.NUMBER_OF_YEARS_COLUMNS + 2, transportType)
        guiTabWidget.functions.AddTab(tabWidget, guiLayout.functions.LayoutComponents(guiLayout.constants.ORIENTATION.HORIZONTAL, {iconView}, ""), table)
    end

    guiTabWidget.functions.SelectTab(tabWidget, 0)
	return tabWidget
end

function functions.UpdateTableValues(currentYearOnly)
    for i, transportType in ipairs(transport.constants.TRANSPORT_TYPES) do
        if currentYearOnly then
            compTransportTable.functions.RefreshTransportCategoryValues(transportType, engineJournal.functions.GetJournal(engineCalendar.functions.GetCurrentGameYear()), columns.constants.YEAR .. columns.constants.NUMBER_OF_YEARS_COLUMNS)
        else
            for j = 1, columns.constants.NUMBER_OF_YEARS_COLUMNS do
                local year = engineCalendar.functions.GetYearFromYearIndex(j)
                compTransportTable.functions.RefreshTransportCategoryValues(transportType, engineJournal.functions.GetJournal(year), columns.constants.YEAR .. j)
                local id = compTransportTable.functions.GetHeaderColumnId(columns.constants.YEAR .. j, transportType)
                local textView = guiComponent.functions.FindById(id)
                guiTextView.functions.SetText(textView, tostring(year))
            end
        end
        compTransportTable.functions.RefreshTransportCategoryValues(transportType, engineJournal.functions.GetJournal(0), columns.constants.TOTAL)
    end
end

local transportTableTabWidget = {}
transportTableTabWidget.constants = constants
transportTableTabWidget.functions = functions

return transportTableTabWidget