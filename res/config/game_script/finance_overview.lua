require "helper_functions"

local TRANSPORT_TYPE_ROAD = "road"
local TRANSPORT_TYPE_TRAM = "tram"
local TRANSPORT_TYPE_RAIL = "rail"
local TRANSPORT_TYPE_WATER = "water"
local TRANSPORT_TYPE_AIR = "air"
local TRANSPORT_TYPE_ALL = "all"

local CAT_INCOME = "income"

local CAT_MAINTENANCE = "maintenance"
local CAT_MAINTENANCE_VEHICLES = "maintenance_vehicles"
local CAT_MAINTENANCE_INFRASTRUCTURE = "maintenance_infrastructure"

local CAT_INVESTMENTS = "investments"
local CAT_INVESTMENTS_VEHICLES = "investments_vehicles"
local CAT_INVESTMENTS_TRACKS = "investments_tracks"
local CAT_INVESTMENTS_INFRASTRUCTURE = "investments_infrastructure"

local CAT_TOTAL = "Total"

local COLUMN_YEAR = "year"
local COLUMN_TOTAL = "total"


local transportTypes = { TRANSPORT_TYPE_ROAD, TRANSPORT_TYPE_TRAM, TRANSPORT_TYPE_RAIL, TRANSPORT_TYPE_WATER, TRANSPORT_TYPE_AIR, TRANSPORT_TYPE_ALL }
local level1Categories = { CAT_INCOME, CAT_MAINTENANCE, CAT_INVESTMENTS }
local level2Categories = { [CAT_INCOME]={},
						 [CAT_MAINTENANCE]={ CAT_MAINTENANCE_VEHICLES, CAT_MAINTENANCE_INFRASTRUCTURE },
						 [CAT_INVESTMENTS]={ CAT_INVESTMENTS_VEHICLES, CAT_INVESTMENTS_INFRASTRUCTURE, CAT_INVESTMENTS_TRACKS }
					   }
local financeTable = nil
local financeTabWindow = nil
local numberOfYearColumns = 5
local guiUpdate = false
local lastBalance = 0


local tooltips = {
	settings ={
		Income =_("#Tooltip.Settings.Income"),
		Vehicles = _("#Tooltip.Settings.Vehicles"),
		Infrastructure = _("#Tooltip.Settings.Infrastructure"),
		},
	Details = {
		Income = _("#Tooltip.Details.Income"),
		Maintenance =_("#Tooltip.Details.Maintenance"),
		Vehicles = _("#Tooltip.Details.Vehicles"),
		Infrastructure = _("#Tooltip.Details.Infrastructure")
	},
	Menu =
		{
			Button= _("#Tooltip.Menu.Button"),
			gameInfo=_("#Tooltip.GameYear"),
		}
}

local state = {
	currentYear = 0,
}

function getValueFromJournal(journal, transportType, category)
	--total transport
	if transportType == TRANSPORT_TYPE_ALL then
		if category == CAT_INCOME then
			return journal.income._sum
		--maintenance
		elseif category == CAT_MAINTENANCE then
			return journal.maintenance._sum
		elseif category == CAT_MAINTENANCE_VEHICLES then
			local result = 0
			for i = 1, #transportTypes - 1 do
				local vehicle = journal.maintenance[transportTypes[i]].vehicle
				if vehicle then
					result = result + vehicle
				end
			end
			return result
		elseif category == CAT_MAINTENANCE_INFRASTRUCTURE then
			local result = 0
			for i = 1, #transportTypes - 1 do
				local infrastructure = journal.maintenance[transportTypes[i]].infrastructure
				if infrastructure then
					result = result + infrastructure
				end
			end
			return result
		--investment		
		elseif category == CAT_INVESTMENTS then
			return journal.construction._sum + journal.acquisition._sum - journal.construction.other._sum
		elseif category == CAT_INVESTMENTS_VEHICLES then
			return journal.acquisition._sum
		elseif category == CAT_INVESTMENTS_INFRASTRUCTURE then
			local result = 0
			for i = 1, #transportTypes - 1 do
				result = result + journal.construction[transportTypes[i]]._sum
			end
			return result
		--total
		elseif category == CAT_TOTAL then
			return journal._sum - journal.construction.other._sum
		end
		return 0
	end
	--individual transport
	if category == CAT_INCOME then
		return journal.income[transportType]
	--maintenance
	elseif category == CAT_MAINTENANCE then
		return journal.maintenance[transportType]._sum
	elseif category == CAT_MAINTENANCE_VEHICLES then
		return journal.maintenance[transportType].vehicle
	elseif category == CAT_MAINTENANCE_INFRASTRUCTURE then
		return journal.maintenance[transportType].infrastructure
	--investment		
	elseif category == CAT_INVESTMENTS then
		return journal.construction[transportType]._sum + journal.acquisition[transportType]
	elseif category == CAT_INVESTMENTS_VEHICLES then
		return journal.acquisition[transportType]
	elseif category == CAT_INVESTMENTS_TRACKS then
		if transportType == TRANSPORT_TYPE_RAIL then
			return journal.construction[transportType].track
		else
			return journal.construction[transportType].street
		end
	elseif category == CAT_INVESTMENTS_INFRASTRUCTURE then
		return journal.construction[transportType].station + journal.construction[transportType].depot + journal.construction[transportType].signal
	--total
	elseif category == CAT_TOTAL then
		return journal.construction[transportType]._sum + journal.acquisition[transportType] + journal.income[transportType] + journal.maintenance[transportType]._sum
	end
end

function updateValueCell(amount, textViewId)
	local textView = api.gui.util.getById(textViewId)
	if not textView then
		return
	end
	textView:removeStyleClass("negative")
	textView:removeStyleClass("positive")
	if not amount then
		amount = 0
	end
	if amount > 0 then
		textView:addStyleClass("positive")
	elseif amount < 0 then
		textView:addStyleClass("negative")
	end
	textView:setText(api.util.formatMoney(amount))
end

function refreshVehicleCategoryValues(transportType, journal, column)
	local income = getValueFromJournal(journal, transportType, CAT_INCOME)
	local maintenance = getValueFromJournal(journal, transportType, CAT_MAINTENANCE)
	--cashflow
	updateValueCell(income + maintenance, transportType..column)
	--income
	updateValueCell(income, transportType..CAT_INCOME..column)
	--maintenance
	updateValueCell(maintenance, transportType..CAT_MAINTENANCE..column)
	updateValueCell(getValueFromJournal(journal, transportType, CAT_MAINTENANCE_VEHICLES), transportType..CAT_MAINTENANCE_VEHICLES..column)
	updateValueCell(getValueFromJournal(journal, transportType, CAT_MAINTENANCE_INFRASTRUCTURE), transportType..CAT_MAINTENANCE_INFRASTRUCTURE..column)
	--investment
	updateValueCell(getValueFromJournal(journal, transportType, CAT_INVESTMENTS), transportType..CAT_INVESTMENTS..column)
	updateValueCell(getValueFromJournal(journal, transportType, CAT_INVESTMENTS_VEHICLES), transportType..CAT_INVESTMENTS_VEHICLES..column)
	updateValueCell(getValueFromJournal(journal, transportType, CAT_INVESTMENTS_TRACKS), transportType..CAT_INVESTMENTS_TRACKS..column)
	updateValueCell(getValueFromJournal(journal, transportType, CAT_INVESTMENTS_INFRASTRUCTURE), transportType..CAT_INVESTMENTS_INFRASTRUCTURE..column)
	--total
	updateValueCell(getValueFromJournal(journal, transportType, CAT_TOTAL), transportType..CAT_TOTAL..column)
end

function createExpandButton(level)
	local iconExpandPath = "ui/design/components/slim_arrow_right@2x.tga"
	local iconCollapsePath = "ui/design/components/slim_arrow_down@2x.tga"
	local imageView = api.gui.comp.ImageView.new(iconCollapsePath)
	local button = api.gui.comp.Button.new(imageView, false)
	button:setStyleClassList({"sLevel"..level,"sButton"})
	local myRowIndex = financeTable:getNumRows()
	button:onClick(function() 
		local startRowIndex = myRowIndex + 1
		local lastRowIndex = myRowIndex + 1
		local setToVisible = not financeTable:getItem(startRowIndex, 0):isVisible()
		for i = 1, 11 do
			if tonumber(financeTable:getItem(startRowIndex + i - 1, 0):getName()) <= level then
				lastRowIndex = myRowIndex + i - 1
				break
			end
		end
		
		for c=0, financeTable:getNumCols() - 1 do
			for r = startRowIndex,lastRowIndex  do
				local element = financeTable:getItem(r,c)
				element:setVisible(setToVisible,false)
				if setToVisible then
					imageView:setImage(iconCollapsePath,false)
				else
					imageView:setImage(iconExpandPath,false)
				end
			end
		end
	end)
	return button
end

function createTextView(text, styleList, id)
	local textView = api.gui.comp.TextView.new(text)
	textView:setStyleClassList(styleList)
	textView:setId(id)
	return textView
end

function layoutComponentsHorizontally(components, styleList, level)
	local component = api.gui.comp.Component.new(tostring(level))
	local layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
	layout:setName(tostring(level))
	component:setStyleClassList(styleList)
	for i = 1, #components do
		layout:addItem(components[i])
	end
	component:setLayout(layout)
	return component
end

function createTableLine(labelComponents, rowId, sLevel, level)
	local row = {}
	
	table.insert(row, layoutComponentsHorizontally(labelComponents, {sLevel}, level))
	for i = 1, numberOfYearColumns do
		local yearCellView = createTextView(api.util.formatMoney(0), {sLevel, "sRight"}, rowId..i)
		table.insert(row, layoutComponentsHorizontally({yearCellView}, {sLevel}, level))
	end
	local totalCellView = createTextView(api.util.formatMoney(0), {sLevel, "sRight"}, rowId..COLUMN_TOTAL)
	table.insert(row, layoutComponentsHorizontally({totalCellView}, {sLevel}, level))

	financeTable:addRow(row)
end

function isCategoryValidForTransportType(transportType, category)
	if category == CAT_INVESTMENTS_TRACKS then
		return transportType == TRANSPORT_TYPE_RAIL or transportType == TRANSPORT_TYPE_ROAD
	end
	return true;
end

function addTableCategory(transportType)
	-- level 0
	local labelView = createTextView(_(transportType), {"sLevel0", "sLeft"}, "")
	createTableLine({createExpandButton(0), labelView}, transportType, "sLevel0", 0)

	-- level 1
	for i = 1, #level1Categories do
		local level1Category = level1Categories[i]
		if ( #level2Categories[level1Category] == 0) then
			labelView = createTextView(_(level1Category), {"sLevel1", "sLeft", "sLevelPadding"}, "")
			createTableLine({labelView}, transportType..level1Category, "sLevel1", 1)
		else
			labelView = createTextView(_(level1Category), {"sLevel1", "sLeft"}, "")
			createTableLine({createExpandButton(1), labelView}, transportType..level1Category, "sLevel1", 1)
			
			-- level 2
			for j = 1, #level2Categories[level1Category] do
				local level2Category = level2Categories[level1Category][j]
				if isCategoryValidForTransportType(transportType, level2Category) then
					local title = level2Category
					if level2Category == CAT_INVESTMENTS_TRACKS and transportType == TRANSPORT_TYPE_ROAD then
						title = "investments_roads"
					end
					labelView = createTextView(_(title), {"sLevel2", "sLeft", "sLevelPadding"}, "")
					createTableLine({labelView}, transportType..level2Category, "sLevel2", 2)	
				end
			end
		end
	end

	labelView = createTextView(_("Total"), {"sLevel1", "sRight"}, "")
	createTableLine({labelView}, transportType..CAT_TOTAL, "sLevel1", 0)
end

function addTableHeader()
	local row = {} 
	local gameYear = getCurrentGameYear()

	table.insert(row, createTextView("", {"sHeader", "sRight"}, ""))
	for i = 1, numberOfYearColumns do
		table.insert(row, createTextView(tostring(gameYear - numberOfYearColumns + i), {"sHeader", "sRight"}, COLUMN_YEAR..i))
	end
	table.insert(row, createTextView(_(CAT_TOTAL), {"sHeader", "sRight"}, COLUMN_TOTAL))

	financeTable:addRow(row)
end

function initFinanceTable()
	financeTable = api.gui.comp.Table.new(numberOfYearColumns + 2,"NONE")
	financeTable:setId("myFinancesOverviewTable")

	addTableHeader()

	for j = 1, #transportTypes do
		addTableCategory(transportTypes[j])
	end

	local companyValueView = createTextView(_("CompanyValue"), {"sLevel0", "sLeft"}, "")
	createTableLine({companyValueView}, "company", "sLevel0", 0)

	local scoreValueView = createTextView(_("ScoreValue"), {"sLevel0", "sLeft"}, "")
	createTableLine({scoreValueView}, "score", "sLevel0", 0)
end

function initFinanceTab()
	initFinanceTable()

	local verticalLayout = api.gui.layout.BoxLayout.new("VERTICAL")
	verticalLayout:addItem(financeTable)

	local myFinancesOverviewWindow = api.gui.comp.Component.new("myFinancesOverviewWindow")
	myFinancesOverviewWindow:setLayout(verticalLayout)
	myFinancesOverviewWindow:setId("myFinancesOverviewWindow")

	financeTabWindow = api.gui.util.getById("menu.finances.category")
	financeTabWindow:insertTab(api.gui.comp.TextView.new(_("FinanceTabOverviewLabel")), myFinancesOverviewWindow, 0)
	financeTabWindow:setCurrentTab(0, true)
	financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
		guiUpdate = visible
	end)
end

-- ***************************
-- ** Main
-- ***************************
function data()
	return {
		save = function()
		end,
		load = function()
		end,
		guiInit = function ()
			initFinanceTab()
		end,
		guiUpdate = function()
			local currentBalance = game.interface.getEntity(game.interface.getPlayer()).balance
			if guiUpdate and financeTabWindow:getCurrentTab() == 0 and currentBalance ~= lastBalance then
				lastBalance = currentBalance
				for i = 1, #transportTypes do
					for j = getCurrentGameYear() - numberOfYearColumns + 1, getCurrentGameYear() do
						local yearStartEnd = getYearStartEndTime(j)
						local yearJournal = game.interface.getPlayerJournal(yearStartEnd[1], yearStartEnd[2], false)
						refreshVehicleCategoryValues(transportTypes[i], yearJournal, getYearColumnIndex(j, numberOfYearColumns) )
					end
					refreshVehicleCategoryValues(transportTypes[i], game.interface.getPlayerJournal(0, game.interface.getGameTime().time * 1000, false), COLUMN_TOTAL )
				end
			end
		end,
	}
end
