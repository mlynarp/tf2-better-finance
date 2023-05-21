require "tax_sub_helpfunctions"

local journal
local currentTime = 0
local taxes= {}
local level1Elements = {"Investments","Income"}
local level2Elements = {Investments={"Vehicles","Infrastructure"},Income={"Income","Maintenance"}}
local taxTable

local config = {
	vehicleCat ={"rail","road","tram","air","water"},
	taxes ={
		Categories= {"Income","Maintenance","Vehicles","Infrastructure","Taxes"},
		TaxCategories= {"Income","Vehicles","Infrastructure"},
	},
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
function ui_tableConstructor_singleLine(taxTable,NoOfCols,texts,level)
	local row = {}
	for i = 1, NoOfCols do
		local lbl_element 	= api.gui.comp.Component.new("Taxtotal")
		local lbl_layout 	= api.gui.layout.BoxLayout.new("HORIZONTAL")
		local txt 			= api.gui.comp.TextView.new("")
		txt:setId(texts[1]..math.abs(i-NoOfCols-1))
		if level ~="empty" then 
			if i ==1 then
				txt:setText(_(texts[2]))
				txt:setStyleClassList({level,"tableElement","Total","Tax"})
				lbl_element:setStyleClassList({"level1","Label","Tax"})
			
			elseif i==2 or i==3 or i==6 or i==7 then
				txt:setText("")
				txt:setStyleClassList({level,"tableElement","Tax","odd"})
				lbl_element:setStyleClassList({"level1","Tax","odd"})
				
			elseif i==4 or i==5 or i==8 or i==9 then
				txt:setText("")
				txt:setStyleClassList({level,"tableElement","Tax","even"})
				lbl_element:setStyleClassList({"level1","Tax","even"})
			
			end
		else
			txt:setText("")
			txt:setStyleClassList({"empty"})
			lbl_element:setStyleClassList({"empty"})
		end
		lbl_layout:addItem(txt)
		lbl_element:setLayout(lbl_layout)
		
		table.insert(row,lbl_element)
	end
	taxTable:addRow(row)
	row ={}

end

function ui_tableConstructor(taxTable,NoOfCols,cat,itemNo)
	local icon_expand_path = "ui/design/components/slim_arrow_right@2x.tga"
	local icon_collapse_path = "ui/design/components/slim_arrow_down@2x.tga"
	
	
	-- Button + Children Elements
	local l0_expBut_image = api.gui.comp.ImageView.new(icon_collapse_path)
	local l0_expButton = api.gui.comp.Button.new(l0_expBut_image,false)
	local row ={}
	
	--style
	l0_expButton:setId("L0Button"..cat)
	l0_expButton:setStyleClassList({"level0","tableElement","Button","Tax"})
	l0_expButton:onClick(function() 
				
				local start= (itemNo - 1)*7 + 3 
				local lastRowToHide = start + 5
				local firstElement = taxTable:getItem(start,0)
				local setToVisible = not firstElement:isVisible()
				for c=0,8 do
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
		
	for i = 1, NoOfCols do
		local l0_component = api.gui.comp.Component.new(state.custom_journal[cat].label)
		local l0_layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
		local txt = api.gui.comp.TextView.new(_(cat))
		-- Add Button to Component if Column 1
		if i==1 then
			l0_layout:addItem(l0_expButton)
			txt:setStyleClassList({"level0","tableElement","Total","Tax"})
			l0_component:setStyleClassList({"level0","Label","Tax"})
			
		else
			txt:setText("")
			txt:setStyleClassList({"level0","tableElement","Tax"})
			l0_component:setStyleClassList({"level0","Tax"})
		end
		txt:setId("Tax"..cat..math.abs(i-NoOfCols-1))		
		
		l0_layout:setName("L0Layout")
		l0_layout:addItem(txt)
		l0_component:setLayout(l0_layout)
		
		-- Add Component to Row Element
		table.insert(row,l0_component)		
	end
	taxTable:addRow(row)
	row ={}
	-- add other Elements
	for l1 = 1,#level1Elements do
		local L_one_Element = level1Elements[l1]
		for i = 1, NoOfCols do
			local guiComp = api.gui.comp.Component.new(L_one_Element)
			local guiLayout = api.gui.layout.BoxLayout.new("HORIZONTAL")
			local guiText = api.gui.comp.TextView.new(_(L_one_Element))
			
			-- Add Button to Component if Column 1
			if i==1 then
				-- Expand Button 
				
				local guiExpBut_image = api.gui.comp.ImageView.new(icon_collapse_path)
				local guiExpButton = api.gui.comp.Button.new(guiExpBut_image,false)
				guiExpBut_image:setId("bt"..cat..l1)
				guiExpButton:setName("expanded")
				guiExpButton:setStyleClassList({"level1","tableElement","Button","Tax"})
				guiExpButton:onClick(function() 
					local start= (itemNo - 1)*7 + 3 + (l1-1)*3 +1
					local lastRowToHide = start + 1
					for c=0,8 do
						for r = start,lastRowToHide  do
							local element = taxTable:getItem(r,c)
							if element:isVisible() then
								element:setVisible(false,false)
								guiExpBut_image:setImage(icon_expand_path,false)
							else
								element:setVisible(true,false)
								guiExpBut_image:setImage(icon_collapse_path,false)
							end
						end
					end
				end)
				guiLayout:addItem(guiExpButton)
				guiText:setStyleClassList({"level1","tableElement","Label","Tax"})
				guiComp:setStyleClassList({"level1","Label","Tax"})
				
			
			elseif i==2 or i==3 or i==6 or i==7 then
				guiText:setText("")
				guiText:setStyleClassList({"level1","tableElement","Tax","odd"})
				guiComp:setStyleClassList({"level1","Tax","odd"})
				
			elseif i==4 or i==5 or i==8 or i==9 then
				guiText:setText("")
				guiText:setStyleClassList({"level1","tableElement","Tax","even"})
				guiComp:setStyleClassList({"level1","Tax","even"})
			end
			guiText:setId("Tax"..cat..L_one_Element..math.abs(i-NoOfCols-1))		
			
			guiLayout:addItem(guiText)
			guiComp:setLayout(guiLayout)
			
			-- Add Component to Row Element
			table.insert(row,guiComp)		
		end
		taxTable:addRow(row)
		row = {}
		
		for l2 =1, #level2Elements[L_one_Element] do
			local L_two_Element  = level2Elements[L_one_Element][l2]
			for i = 1, NoOfCols do
				local guiComp = api.gui.comp.Component.new(L_two_Element)
				local guiLayout = api.gui.layout.BoxLayout.new("HORIZONTAL")
				local guiText = api.gui.comp.TextView.new(_(L_two_Element))
				-- Add Button to Component if Column 1
				if i==1 then
					guiText:setStyleClassList({"level2","tableElement","Label","Tax"})
					guiComp:setStyleClassList({"level2","Label","Tax"})
					
				elseif i==2 or i==3 or i==6 or i==7 then
					guiText:setText("")
					guiText:setStyleClassList({"level2","tableElement","Tax","odd"})
					guiComp:setStyleClassList({"level2","Tax","odd"})
					
				elseif i==4 or i==5 or i==8 or i==9 then
					guiText:setText("")
					guiText:setStyleClassList({"level2","tableElement","Tax","even"})
					guiComp:setStyleClassList({"level2","Tax","even"})
				end
				if i%2== 1 then
					if L_one_Element=="Income" and L_two_Element=="Income" then
						guiText:setTooltip("Gross Profit Margin")
					elseif L_one_Element=="Income" and L_two_Element=="Maintenance" then
						guiText:setTooltip("Taxrate")
					end
				end
				
				guiText:setId("Tax"..cat..L_one_Element..L_two_Element..math.abs(i-NoOfCols-1))		
				
				guiLayout:addItem(guiText)
				guiComp:setLayout(guiLayout)
				
				-- Add Component to Row Element
				table.insert(row,guiComp)		
			end
			taxTable:addRow(row)
			row = {}
			
		end
	end
	l0_expButton:click()
end

function addTableHeader(financeTable, numberOfYears)
	local row = {} 
	
	local textView = api.gui.comp.TextView.new("")
	textView:setStyleClassList({"Subheader"})
	table.insert(row, textView)
	
	local gameYear = getCurrentGameYear()
	for i = 1, numberOfYears do
		textView = api.gui.comp.TextView.new(tostring(gameYear - numberOfYears + i))
		textView:setStyleClassList({"Subheader"})
		textView:setId("Year"..i)
		table.insert(row, textView)
	end

	textView = api.gui.comp.TextView.new("Total")
	textView:setStyleClassList({"Subheader"})
	table.insert(row, textView)
	
	financeTable:addRow(row)
end

function initFinanceTable()
	local NoOfCols = 9
	local tblDetails = api.gui.comp.Table.new(NoOfCols,"NONE")
	local icon_expand_path = "ui/design/components/slim_arrow_right@2x.tga"
	local icon_collapse_path = "ui/design/components/slim_arrow_down@2x.tga"

	addTableHeader(tblDetails, 7)
	
	local expandButton
	local row ={} -- Local Variable holding all rows for the table
	
	-- Vehicle Rows
	for j = 1, #config.vehicleCat do
		local vc = config.vehicleCat[j]
		--ui_tableConstructor(tblDetails,NoOfCols,vc,j)
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
	return tblDetails
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
