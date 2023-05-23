require "tax_sub_helpfunctions"

local currentTime = 0
local level1Elements = {"Income", "Maintenance", "Investments"}
local level2Elements = {Income={}, Maintenance={"Vehicles", "Infrastructure"}, Investments={"Acquisiton", "Construction"}}
local level3Elements = {Vehicles={}, Infrastructure={}, Construction={"Stations", "Depots", "Track"}, Acquisiton={}}
local financeTable = nil
local numberOfYearColumns = 5

local config =
{
	vehicleCategory = {"road", "tram", "rail", "water", "air", "total"},
}

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

-- ############
-- ## User Interface 
-- ############
function ui_refresh_taxDetails()
	local cyTotal = getCurrentGameYear()
	local cy,comp
	-- Header:
	for c=1,7,2 do
		cy = cyTotal-((c-1)/2)
		comp=api.gui.util.getById("TaxHeader"..c)
		if comp and state.custom_journal.header.labels["Year "..cy] then 
			comp:setText(_("Year").." "..state.custom_journal.header.labels["Year "..cy]..sum) 
		end
	end
	-- Values
	
	
	local vc
	for c=1,7,2 do
		local totals =0
		local totalTax = 0
		cy = cyTotal-((c-1)/2)
		for i = 1,#config.vehicleCat do 
			vc = config.vehicleCat[i]
			
			local vehiclesum =0
			local value, tax, veh, infr = 0,0,0,0
			-- Investments
				veh = state.custom_journal[vc].Vehicles["Year "..cy] or 0
				infr = state.custom_journal[vc].Infrastructure["Year "..cy] or 0
				value = veh + infr
				vehiclesum = vehiclesum + value
				
				ui_updateText(vc,"Investments","",1+c,value,"level1") -- Sum
				ui_updateText(vc,"Investments","Infrastructure",1+c,infr,"level2") -- Infrastructure
				ui_updateText(vc,"Investments","Vehicles",1+c,veh,"level2") -- Vehicle
				veh =0
				infr=0
				value =0
			-- Investments Taxes
				veh = state.custom_journal[vc].Taxes.Vehicles["Year "..cy] or 0
				infr = state.custom_journal[vc].Taxes.Infrastructure["Year "..cy] or 0
				value = veh + infr
				tax = tax + value
				
				ui_updateText(vc,"Investments","",c,value,"level1") -- Sum
				ui_updateText(vc,"Investments","Infrastructure",c,infr,"level2") -- Infrastructure
				ui_updateText(vc,"Investments","Vehicles",c,veh,"level2") -- Vehicle	
				veh =0
				infr=0
				value =0
			-- Income
				infr = state.custom_journal[vc].Income._sum["Year "..cy] or 0
				veh = state.custom_journal[vc].Maintenance._sum["Year "..cy] or 0
				value = veh + infr
				vehiclesum = vehiclesum + value
				
				ui_updateText(vc,"Income","",c+1,value,"level1") -- Sum
				ui_updateText(vc,"Income","Income",c+1,infr,"level2") -- Infrastructure
				ui_updateText(vc,"Income","Maintenance",c+1,veh,"level2") -- Vehicle
				veh =0
				infr=0
				value =0
			-- Income Taxes
				value = state.custom_journal[vc].Taxes.Income["Year "..cy] or 0
				tax = tax + value
				
				ui_updateText(vc,"Income","",c,value,"level1") -- Sum
				value =0
				if state.custom_journal[vc].Income.GPMargin then
					value = state.custom_journal[vc].Income.GPMargin["Year "..cy] or 0
				end
				ui_updateText(vc,"Income","Income",c,value*100,"level2","%")
				
				value =0
				if state.custom_journal[vc].Income.TaxRate then
					value = state.custom_journal[vc].Income.TaxRate["Year "..cy] or 0
				end
				ui_updateText(vc,"Income","Maintenance",c,value*100,"level2","%")
				
				veh =0
				infr=0
				value =0
			-- Vehicle Sum
				ui_updateText(vc,"","",c+1,vehiclesum,"level0") -- Sum Results
				ui_updateText(vc,"","",c,tax,"level0") -- Sum Taxes
				
				totals = totals + vehiclesum
				totalTax = totalTax + tax
		end -- categories
		value = state.custom_journal.interest["Year " ..cy] or 0
		ui_updateText("Interest","","",c+1,value,"level1") -- Sum Results
		
		totals = totals  + value
		value = 0
		
		if state.custom_journal.TotalTax then 
			value = state.custom_journal.TotalTax["Year " ..cy] or 0
			ui_updateText("PayedTaxes","","",c+1,value,"level1") -- Sum Results
			totals = totals  + value
		end
		value = 0
		
		ui_updateText("Total","","",c,totalTax,"level1") -- Sum Results
		ui_updateText("Total","","",c+1,totals,"level1") -- Sum Results
		
		ui_updateText("NetResult","","",c+1,(totals+totalTax),"Total") -- Sum Results
		
	end -- columns	
 end -- function
function ui_hide_detailRows(taxTable,itemNo,cat)
	local icon_expand_path = "ui/design/components/slim_arrow_right@2x.tga"
	local icon_collapse_path = "ui/design/components/slim_arrow_down@2x.tga"
	
	for i = 1,2 do
		local guiExpBut_image = api.gui.util.getById("bt"..cat..i)
		local start= (itemNo - 1)*7 + 3 + (i-1)*3 +1
		local lastRowToHide = start + 1
		for c=0,8 do
			for r = start,lastRowToHide  do
				local element = taxTable:getItem(r,c)
				element:setVisible(false,false)
				guiExpBut_image:setImage(icon_expand_path,false)				
			end
		end
	end
end
function ui_updateText(vehicleType,ID1,ID2,c,value,lvl,sign)
	local comp = api.gui.util.getById("Tax"..vehicleType..ID1..ID2..c)
	if comp then
		if not sign then
			comp:setText(format_num(value,0,"$","- ","")) 
		else
			comp:setText(format_num(value,0,"","- ","%")) 
		end
		
		if c==1 or c==2 or c==5 or c==6 then
			comp:setStyleClassList({lvl,"tableElement","Tax","even",value > 0 and "positive" or "negative"})
		elseif c==3 or c==4 or c==7 or c==8 then 
			comp:setStyleClassList({lvl,"tableElement","Tax","odd",value > 0 and "positive" or "negative"})
		end
		
	end

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
		print("Start index"..tostring(startRowIndex))
		local lastRowIndex = myRowIndex + 1
		local setToVisible = not financeTable:getItem(startRowIndex, 0):isVisible()
		for i = 1, 11 do
			if tonumber(financeTable:getItem(startRowIndex + i - 1, 0):getName()) <= level then
				lastRowIndex = myRowIndex + i - 1
				print("Last index"..tostring(lastRowIndex))
				print("Visible"..tostring(setToVisible))
				break
			end
		end
		
		for c=0, financeTable:getNumCols() - 1 do
			for r = startRowIndex,lastRowIndex  do
				local element = financeTable:getItem(r,c)
				element:setVisible(setToVisible,false)
				if setToVisible then
					imageView:setImage(iconCollapsePath,false)
					--ui_hide_detailRows(taxTable,itemNo,cat)
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

function createTableLine(labelComponents, category, sLevel, level)
	local row = {}
	
	table.insert(row, layoutComponentsHorizontally(labelComponents, {sLevel}, level))
	for i = 1, numberOfYearColumns do
		local yearCellView = createTextView(api.util.formatMoney(0), {sLevel, "sRight"}, category..i)
		table.insert(row, layoutComponentsHorizontally({yearCellView}, {sLevel}, level))
	end
	local totalCellView = createTextView(api.util.formatMoney(0), {sLevel, "sRight"}, category.."total")
	table.insert(row, layoutComponentsHorizontally({totalCellView}, {sLevel}, level))

	financeTable:addRow(row)
end

function addTableCategory(category)
	-- level 0
	local labelView = createTextView(_(category), {"sLevel0", "sLeft"}, "")
	createTableLine({createExpandButton(0), labelView}, category, "sLevel0", 0)

	-- level 1
	for i = 1, #level1Elements do
		local l1Element = level1Elements[i]
		if ( #level2Elements[l1Element] == 0) then
			labelView = createTextView(_(l1Element), {"sLevel1", "sLeft", "sLevelPadding"}, "")
			createTableLine({labelView}, category..l1Element, "sLevel1", 1)
		else
			labelView = createTextView(_(l1Element), {"sLevel1", "sLeft"}, "")
			createTableLine({createExpandButton(1), labelView}, category..l1Element, "sLevel1", 1)
			
			-- level 2
			for j = 1, #level2Elements[l1Element] do
				local l2Element = level2Elements[l1Element][j]
				if ( #level3Elements[l2Element] == 0) then
					labelView = createTextView(_(l2Element), {"sLevel2", "sLeft", "sLevelPadding"}, "")
					createTableLine({labelView}, category..l2Element, "sLevel2", 2)
				else
					labelView = createTextView(_(l2Element), {"sLevel2", "sLeft"}, "")
					createTableLine({createExpandButton(2), labelView}, category..l2Element, "sLevel2", 2)
					
					-- level 3
					for k = 1, #level3Elements[l2Element] do
						local l3Element = level3Elements[l2Element][k]
						labelView = createTextView(_(l3Element), {"sLevel3", "sLeft", "sLevelPadding"}, "")
						createTableLine({labelView}, category..l3Element, "sLevel3", 3)
					end
				end
			end
		end
	end

	labelView = createTextView(_("Total"), {"sLevel1", "sRight"}, "")
	createTableLine({labelView}, category.."total", "sLevel1", 0)
end

function addTableHeader()
	local row = {} 
	local gameYear = getCurrentGameYear()

	table.insert(row, createTextView("", {"sHeader", "sRight"}, ""))
	for i = 1, numberOfYearColumns do
		table.insert(row, createTextView(tostring(gameYear - numberOfYearColumns + i), {"sHeader", "sRight"}, "yearLabel"..i))
	end
	table.insert(row, createTextView(_("Total"), {"sHeader", "sRight"}, ""))

	financeTable:addRow(row)
end

function initFinanceTable()
	financeTable = api.gui.comp.Table.new(numberOfYearColumns + 2,"NONE")
	financeTable:setId("myFinancesOverviewTable")

	addTableHeader()

	for j = 1, #config.vehicleCategory do
		addTableCategory(config.vehicleCategory[j])
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
			print("visibility changed")
			--ui_refresh_taxDetails()
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
