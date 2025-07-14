--copy of system script name to override earnings field in the status bar
local categories = require "pm_finance/constants/categories"
local transport = require "pm_finance/constants/transport"
local tooltips = require "pm_finance/constants/tooltips"
local functions = require "pm_finance/functions"
local ui_functions = require "pm_finance/ui_functions"

local arrivaltracker = require "mission.arrivaltracker"

local state = {
	earnings = nil,
	numPassenger = nil,
	numCargo = nil,
	earningsPanel = nil,
}

local function trackerinit()
	arrivaltracker.track("__ug_gui_game_info_cargo", { })
	arrivaltracker.track("__ug_gui_game_info_passenger", { cargotype = "PASSENGERS" })
end

function data()
return {
	init = function()
		trackerinit()
	end,
	guiInit = function()
		local earningsText = gui.textView_create("gameInfo.earningsComp.earningsText", _(categories.constants.CAT_CASHFLOW))
		state.earnings = gui.textView_create("gameInfo.earningsComp.earnings", "")
		
		local earningsLayout = gui.boxLayout_create("gameInfo.earningsComp.layout", "HORIZONTAL")
		earningsLayout:addItem(earningsText)
		earningsLayout:addItem(state.earnings)
		
		local earningsComp = gui.component_create("gameInfo.earningsComp", "EarningsComp")
		earningsComp:setLayout(earningsLayout)
        earningsComp:setToolTip(_("Total earnings"))
		state.earningsPanel = earningsComp
		
		
		local passengerIcon = gui.imageView_create("gameInfo.passengerComp.passengerIcon", "ui/icons/construction-menu/filter_passengers.tga")
		state.numPassenger = gui.textView_create("gameInfo.passengerComp.numPassenger", "")
		
		local passengerLayout = gui.boxLayout_create("gameInfo.passengerComp.layout", "HORIZONTAL")
		passengerLayout:addItem(passengerIcon)
		passengerLayout:addItem(state.numPassenger)
		
		local passengerComp = gui.component_create("gameInfo.passengerComp", "PassengerComp")
		passengerComp:setLayout(passengerLayout)
		passengerComp:setToolTip(_("Number of passenger transported"))
		
		
		local cargoIcon = gui.imageView_create("gameInfo.cargoComp.cargoIcon", "ui/icons/construction-menu/filter_cargo.tga")
		state.numCargo = gui.textView_create("gameInfo.cargoComp.numCargo", "")
		
		local cargoLayout = gui.boxLayout_create("gameInfo.cargoComp.layout", "HORIZONTAL")
		cargoLayout:addItem(cargoIcon)
		cargoLayout:addItem(state.numCargo)
		
		local cargoComp = gui.component_create("gameInfo.cargoComp", "CargoComp")
		cargoComp:setLayout(cargoLayout)
		cargoComp:setToolTip(_("Number of cargo items transported"))
		
		local layout = gui.boxLayout_create("gameInfo.layout", "HORIZONTAL")
		layout:addItem(earningsComp)
		layout:addItem(gui.component_create("gameInfo.verticalLine1", "VerticalLine"))
		layout:addItem(passengerComp)
		layout:addItem(gui.component_create("gameInfo.verticalLine2", "VerticalLine"))
		layout:addItem(cargoComp)
		
		gui.component_get("gameInfo"):setLayout(layout)
	end,
	save = function ()
		return { }
	end,
	load = function (state)
		if not arrivaltracker.get("__ug_gui_game_info_passenger") then trackerinit() end
	end,
	guiUpdate = function ()
		local data = api.engine.util.getTransportedData()

		state.numPassenger:setText(ug.formatNumber(data["passengersTransported"]))
		state.numCargo:setText(ug.formatNumber(data["cargoTransported"]))
		
		local journal = functions.GetJournal(functions.GetCurrentGameYear())
		
		ui_functions.UpdateCellValue(functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_CASHFLOW), "gameInfo.earningsComp.earnings")
        local breakdownTooltip = _(tooltips.constants.TOOLTIP_GAMEINFO) .. "\n"
        .. "      " .. _(categories.constants.CAT_INCOME) .. ": " .. api.util.formatMoney(functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_INCOME)) .. "\n"
        .. "      " .. _(categories.constants.CAT_MAINTENANCE) .. ": " .. api.util.formatMoney(functions.GetValueFromJournal(journal, transport.constants.TRANSPORT_TYPE_ALL, categories.constants.CAT_MAINTENANCE))

        state.earningsPanel:setToolTip(breakdownTooltip)
	end,
}
end
