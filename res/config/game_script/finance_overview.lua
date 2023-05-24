require "helper_functions"

local TRANSPORT_CATEGORY_ROAD = "road"
local TRANSPORT_CATEGORY_TRAM = "tram"
local TRANSPORT_CATEGORY_RAIL = "rail"
local TRANSPORT_CATEGORY_WATER = "water"
local TRANSPORT_CATEGORY_AIR = "air"

local CAT_INCOME = "Income"

local CAT_MAINTENANCE = "Maintenance"
local CAT_MAINTENANCE_VEHICLES = "Vehicles"
local CAT_MAINTENANCE_TRACKS = "Tracks"
local CAT_MAINTENANCE_INFRASTRUCTURE = "Infrastructure"

local CAT_INVESTMENTS = "Investments"
local CAT_INVESTMENTS_VEHICLES = "Acquisiton"
local CAT_INVESTMENTS_TRACKS = "Track"
local CAT_INVESTMENTS_STATIONS = "Stations"
local CAT_INVESTMENTS_DEPOTS = "Depots"

local CAT_TOTAL = "Total"

local COLUMN_YEAR = "year"
local COLUMN_TOTAL = "total"


local transportCategories = { TRANSPORT_CATEGORY_ROAD, TRANSPORT_CATEGORY_TRAM, TRANSPORT_CATEGORY_RAIL, TRANSPORT_CATEGORY_WATER, TRANSPORT_CATEGORY_AIR }
local level1Elements = { CAT_INCOME, CAT_MAINTENANCE, CAT_INVESTMENTS }
local level2Elements = { Income={},
						 Maintenance={CAT_MAINTENANCE_VEHICLES, CAT_MAINTENANCE_TRACKS, CAT_MAINTENANCE_INFRASTRUCTURE},
						 Investments={CAT_INVESTMENTS_VEHICLES, CAT_INVESTMENTS_TRACKS, CAT_INVESTMENTS_STATIONS, CAT_INVESTMENTS_DEPOTS}
					   }
local financeTable = nil
local numberOfYearColumns = 5


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

function getValueFromJournal(journal, transportCategory, category)
	if category == CAT_INCOME then
		return journal.income[transportCategory]
	--maintenance
	elseif category == CAT_MAINTENANCE then
		return journal.maintenance[transportCategory]._sum
	elseif category == CAT_MAINTENANCE_VEHICLES then
		return journal.maintenance[transportCategory].vehicle
	elseif category == CAT_MAINTENANCE_TRACKS then
		return journal.maintenance[transportCategory].track
	elseif category == CAT_MAINTENANCE_INFRASTRUCTURE then
		return journal.maintenance[transportCategory].infrastructure
	--investment		
	elseif category == CAT_INVESTMENTS then
		return journal.construction[transportCategory]._sum + journal.acquisition[transportCategory]
	elseif category == CAT_INVESTMENTS_VEHICLES then
		return journal.acquisition[transportCategory]
	elseif category == CAT_INVESTMENTS_TRACKS then
		if transportCategory == TRANSPORT_CATEGORY_RAIL then
			return journal.construction[transportCategory].track	
		else
			return journal.construction[transportCategory].street					
		end
	elseif category == CAT_INVESTMENTS_STATIONS then
		return journal.construction[transportCategory].station
	elseif category == CAT_INVESTMENTS_DEPOTS then
		return journal.construction[transportCategory].depot
	--total
	elseif category == CAT_TOTAL then
		return journal.construction[transportCategory]._sum + journal.acquisition[transportCategory] + journal.income[transportCategory] + journal.maintenance[transportCategory]._sum
	end
end

function updateValueCell(amount, textViewId)
	local textView = api.gui.util.getById(textViewId)
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

function refreshVehicleCategoryValues(transportCategory, journal, column)
	local income = getValueFromJournal(journal, transportCategory, CAT_INCOME)
	local maintenance = getValueFromJournal(journal, transportCategory, CAT_MAINTENANCE)
	--cashflow
	updateValueCell(income + maintenance, transportCategory..column)
	--income
	updateValueCell(income, transportCategory..CAT_INCOME..column)
	--maintenance
	updateValueCell(maintenance, transportCategory..CAT_MAINTENANCE..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_MAINTENANCE_VEHICLES), transportCategory..CAT_MAINTENANCE_VEHICLES..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_MAINTENANCE_TRACKS), transportCategory..CAT_MAINTENANCE_TRACKS..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_MAINTENANCE_INFRASTRUCTURE), transportCategory..CAT_MAINTENANCE_INFRASTRUCTURE..column)
	--investment
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_INVESTMENTS), transportCategory..CAT_INVESTMENTS..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_INVESTMENTS_VEHICLES), transportCategory..CAT_INVESTMENTS_VEHICLES..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_INVESTMENTS_TRACKS), transportCategory..CAT_INVESTMENTS_TRACKS..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_INVESTMENTS_STATIONS), transportCategory..CAT_INVESTMENTS_STATIONS..column)
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_INVESTMENTS_DEPOTS), transportCategory..CAT_INVESTMENTS_DEPOTS..column)
	--total
	updateValueCell(getValueFromJournal(journal, transportCategory, CAT_TOTAL), transportCategory..CAT_TOTAL..column)
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

function addTableCategory(transportCategory)
	-- level 0
	local labelView = createTextView(_(transportCategory), {"sLevel0", "sLeft"}, "")
	createTableLine({createExpandButton(0), labelView}, transportCategory, "sLevel0", 0)

	-- level 1
	for i = 1, #level1Elements do
		local l1Element = level1Elements[i]
		if ( #level2Elements[l1Element] == 0) then
			labelView = createTextView(_(l1Element), {"sLevel1", "sLeft", "sLevelPadding"}, "")
			createTableLine({labelView}, transportCategory..l1Element, "sLevel1", 1)
		else
			labelView = createTextView(_(l1Element), {"sLevel1", "sLeft"}, "")
			createTableLine({createExpandButton(1), labelView}, transportCategory..l1Element, "sLevel1", 1)
			
			-- level 2
			for j = 1, #level2Elements[l1Element] do
				local l2Element = level2Elements[l1Element][j]
				labelView = createTextView(_(l2Element), {"sLevel2", "sLeft", "sLevelPadding"}, "")
				createTableLine({labelView}, transportCategory..l2Element, "sLevel2", 2)
			end
		end
	end

	labelView = createTextView(_("Total"), {"sLevel1", "sRight"}, "")
	createTableLine({labelView}, transportCategory..CAT_TOTAL, "sLevel1", 0)
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

	for j = 1, #transportCategories do
		addTableCategory(transportCategories[j])
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

	local financeTabWindow = api.gui.util.getById("menu.finances.category")
	financeTabWindow:insertTab(api.gui.comp.TextView.new(_("FinanceTabOverviewLabel")), myFinancesOverviewWindow, 0)
	financeTabWindow:setCurrentTab(0, true)
	financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
		if visible then
			for i = 1850, getCurrentGameYear() do
				local yearStartEnd = getYearStartEndTime(i)
				local yearJournal = game.interface.getPlayerJournal(yearStartEnd[1], yearStartEnd[2], false)
				for j = 1, #transportCategories do
					refreshVehicleCategoryValues(transportCategories[j], yearJournal, getYearColumnIndex(i, numberOfYearColumns) )
				end
			end
			for j = 1, #transportCategories do
				refreshVehicleCategoryValues(transportCategories[j], game.interface.getPlayerJournal(0, game.interface.getGameTime().time * 1000, false), COLUMN_TOTAL )
			end

		end
	end)
end

-- ***************************
-- ** Main
-- ***************************
function data()
	return {
		guiInit = function ()
			initFinanceTab()
		end,
	}
end
