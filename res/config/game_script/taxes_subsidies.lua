require "tax_sub_helpfunctions"

local currentTime = 0
local level1Elements = {"Income", "Maintenance", "Investments"}
local level2Elements = {Income={}, Maintenance={"Vehicles", "Infrastructure"}, Investments={"Acquisiton", "Construction"}}
local level3Elements = {Vehicles={}, Infrastructure={}, Construction={"Stations", "Depots", "Track"}, Acquisiton={}}
local taxTable
local numberOfYearColumns = 5

local config =
{
	vehicleCat = {"road", "tram", "rail", "water", "air"},
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

function createExpandButton(sLevel, financeTable)
	local iconExpandPath = "ui/design/components/slim_arrow_right@2x.tga"
	local iconCollapsePath = "ui/design/components/slim_arrow_down@2x.tga"
	local imageView = api.gui.comp.ImageView.new(iconCollapsePath)
	local button = api.gui.comp.Button.new(imageView, false)
	button:setStyleClassList({sLevel,"sButton"})
	button:onClick(function() 
				
		local start= (itemNo - 1)*7 + 2 
		local lastRowToHide = start + 5
		local firstElement = taxTable:getItem(start,0)
		local setToVisible = not firstElement:isVisible()
		for c=0, financeTable:getNumCols() - 1 do
			for r = start,lastRowToHide  do
				local element = taxTable:getItem(r,c)
				element:setVisible(setToVisible,false)
				if setToVisible then
					l0_expBut_image:setImage(icon_collapse_path,false)
					ui_hide_detailRows(taxTable,itemNo,cat)
				else
					l0_expBut_image:setImage(icon_expand_path,false)
				end
			end
		end
	end)
	return button
end

function createTextView(text, sLevel, sOtherStyle, id)
	local textView = api.gui.comp.TextView.new(text)
	textView:setStyleClassList({sLevel, sOtherStyle})
	textView:setId(id)
	return textView
end

function layoutComponentsHorizontal(components, sLevel)
	local component = api.gui.comp.Component.new("")
	local layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
	layout:setName(sLevel)
	component:setStyleClassList({sLevel})
	for i = 1, #components do
		layout:addItem(components[i])
	end
	component:setLayout(layout)
	return component
end

function addTableLine(financeTable, cat, sLevel, label, button)
	local row = {}
	local textView = createTextView(label, sLevel, "sLeft", "")
	if button then
		table.insert(row, layoutComponentsHorizontal({button, textView}, sLevel))	
	else
		table.insert(row, layoutComponentsHorizontal({textView}, sLevel))
		textView:addStyleClass("sLevelPadding")
	end

	for i = 1, numberOfYearColumns do
		textView = createTextView("0", sLevel, "sRight", label..cat..i)
		table.insert(row, layoutComponentsHorizontal({textView}, sLevel))
	end

	textView = createTextView("0", sLevel, "sRight", label..cat.."total")
	table.insert(row, layoutComponentsHorizontal({textView}, sLevel))

	financeTable:addRow(row)
end

function addTableCategory(financeTable,cat)
	-- level 0
	addTableLine(financeTable, cat, "sLevel0", _(cat), createExpandButton("sLevel0", financeTable))

	-- level 1
	for i = 1, #level1Elements do
		local l1Element = level1Elements[i]
		if ( #level2Elements[l1Element] == 0) then
			addTableLine(financeTable, cat, "sLevel1", _(l1Element), nil)
		else
			addTableLine(financeTable, cat, "sLevel1", _(l1Element), createExpandButton("sLevel1", financeTable))
			-- level 2
			for j = 1, #level2Elements[l1Element] do
				local l2Element = level2Elements[l1Element][j]
				if ( #level3Elements[l2Element] == 0) then
					addTableLine(financeTable, cat, "sLevel2", _(l2Element), nil)
				else
					addTableLine(financeTable, cat, "sLevel2", _(l2Element), createExpandButton("sLevel2", financeTable))
					-- level 3
					for k = 1, #level3Elements[l2Element] do
						local l3Element = level3Elements[l2Element][k]
						addTableLine(financeTable, cat, "sLevel3", _(l3Element), nil)
					end
				end
			end
		end
	end

	addTableLine(financeTable, cat, "sLevel0", _("Cashflow"), nil)
	addTableLine(financeTable, cat, "sLevel0", _("Total"), nil)
	--l0ExpButton:click()
end

function addTableHeader(financeTable)
	local row = {} 
	
	local textView = api.gui.comp.TextView.new("")
	textView:setStyleClassList({"sHeader", "sRight"})
	table.insert(row, textView)
	
	local gameYear = getCurrentGameYear()
	for i = 1, numberOfYearColumns do
		textView = api.gui.comp.TextView.new(tostring(gameYear - numberOfYearColumns + i))
		textView:setStyleClassList({"sHeader", "sRight"})
		textView:setId("Year"..i)
		table.insert(row, textView)
	end

	textView = api.gui.comp.TextView.new(_("Total"))
	textView:setStyleClassList({"sHeader", "sRight"})
	table.insert(row, textView)
	
	financeTable:addRow(row)
end

function initFinanceTable()
	local financeTable = api.gui.comp.Table.new(numberOfYearColumns + 2,"NONE")

	addTableHeader(financeTable)
	
	-- Vehicle Rows
	for j = 1, #config.vehicleCat do
		local vc = config.vehicleCat[j]
		--ui_tableConstructor(tblDetails,NoOfCols,vc,j)
		addTableCategory(financeTable,vc)
	end
	-- Summary Rows
	--ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"empty",""},"empty")
	
	--ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxInterest","Interest"},"level1")
	--ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxPayedTaxes","Payed Taxes (for previous year)"},"level1")
	--ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxTotal","Total"},"level1")
	--ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxNetResult","Net Result"},"Total")
	
	-- Tax Summary Details
	
	--ui_refresh_taxDetails()
	print("Created Details Table")
	return financeTable
end

function initFinanceTab ()
	local financeTabWindow = api.gui.util.getById("menu.finances.category")
	local myFinancesOverviewWindowLayout = api.gui.layout.BoxLayout.new("VERTICAL")

	local myFinancesOverviewWindow = api.gui.comp.Component.new("myFinancesOverviewWindow")
	myFinancesOverviewWindow:setLayout(myFinancesOverviewWindowLayout)
	myFinancesOverviewWindow:setId("myFinancesOverviewWindow")
	local myFinancesOverviewTable = initFinanceTable()
	myFinancesOverviewTable:setId("myFinancesOverviewTable")
	taxTable = myFinancesOverviewTable

	local txt = api.gui.comp.TextView.new("")
	txt:setText(_("FinanceTabOverviewLabel"))

	myFinancesOverviewWindowLayout:addItem(myFinancesOverviewTable)
	--financeTabWindow:addTabText(_("FinanceTabOverviewLabel"), myFinancesOverviewWindow)
	financeTabWindow:insertTab(txt, myFinancesOverviewWindow, 0)

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
