require "tax_sub_helpfunctions"

local journal
local currentTime = 0
local bookAmount =0
local taxes= {}
local drivesGameYear=false
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

local callbacks = {}

local state = {
	taxIntStartTime=0,
	taxIntNextTime = 0,
	currentYear = 0,
	showGameYear = 1,
	tax_rates = {
			road = {
				label=_("Road"),
				Income= {
					maxVal= -0.25,
					minVal= 0.05
					},
				Vehicles= -0.02,
				Infrastructure = -0.02,	
				vShow = true
			},
			rail = {
				label=_("Railway"),
				Income= {
					maxVal= -0.45,
					minVal= 0.20
					},
				Vehicles= -0.075,
				Infrastructure = -0.075,
				vShow = true
			},
			tram = {
				label=_("Tram"),
				Income= {
					maxVal= -0.25,
					minVal= 0.05
					},
				Vehicles= -0.02,
				Infrastructure = -0.02,	
				vShow = true
			},
			air = {
				label=_("Air"),
				Income= {
					maxVal= -0.65,
					minVal= -0.15
					},
				Vehicles= -0.15,
				Infrastructure = -0.15,	
				vShow = true
			},
			water = {
				label=_("Water"),
				Income= {
					maxVal= -0.50,
					minVal= 0.05
					},
				Vehicles= -0.1,
				Infrastructure = -0.1,	
				vShow = true
			},
		},
	
	fn = {},
	updList =nil,
	taxTabCreated = nil,
	LastLinesRefreshMonth = 0
}
-- ***************************
-- ** Taxes & Subsidies
-- ***************************

-- ~~~~~~~~~~~~~~~~
-- ~~ Data
-- ~~~~~~~~~~~~~~~~

function data_init_customJournal()
	local custJournal = {}
	custJournal["header"]={labels={}}
	custJournal["interest"]={}
	for i=1,#config.vehicleCat do
		
		custJournal[config.vehicleCat[i]]={label = _(config.vehicleCat[i]),IDs={}}
		for j=1,#config.taxes.Categories do
			if config.taxes.Categories[j]=="Income" or config.taxes.Categories[j]=="Maintenance" then
				custJournal[config.vehicleCat[i]][config.taxes.Categories[j]]={_sum={}}
			else
				custJournal[config.vehicleCat[i]][config.taxes.Categories[j]]={}
			end
		end
		for t =1,#config.taxes.TaxCategories do
			custJournal[config.vehicleCat[i]]["Taxes"][config.taxes.TaxCategories[t]]={}
		end
		custJournal[config.vehicleCat[i]]["Taxes"]["IDs"]={}
	end
	return custJournal
end
function data_calc_incomeTax(grossSales, main, rateTable,vc)
	local taxAmount,grossProfitMargin,taxRate =0
	local grossProfit = grossSales - math.abs(main)
	local cy = state.currentYear
	if grossSales >=1 then
		grossProfitMargin = grossProfit/grossSales -- Get Ratio between grossSalesome-Maintenance and grossSalesome
		
		if grossProfitMargin >= 0.05 then
			taxRate = rateTable.maxVal -- Taxes
		elseif grossProfitMargin > -0.05 and grossProfitMargin < 0.05 then
			taxRate = 0 -- No Taxes/Subsidues
		elseif grossProfitMargin <= -0.05 then
			taxRate = rateTable.minVal -- Subsidues
		end
		
		if grossProfitMargin <0 and grossProfitMargin >-(2/3) then
			taxRate = taxRate * (math.abs(grossProfitMargin)*2)
		elseif grossProfitMargin > 0 and grossProfitMargin<=0.25 then
			taxRate = taxRate * math.abs(grossProfitMargin)
		elseif grossProfitMargin > 0.25 and grossProfitMargin<=0.50 then
			taxRate = taxRate * math.abs(grossProfitMargin) *1.5
		elseif grossProfitMargin > 0.5 and grossProfitMargin<=0.75 then
			taxRate = taxRate * math.abs(grossProfitMargin) *1.75
		elseif grossProfitMargin > 0.75 and grossProfitMargin<=0.9 then
			taxRate = taxRate * math.abs(grossProfitMargin) *2.25
		elseif grossProfitMargin <= -(2/3) then
			taxRate = taxRate * (math.abs(grossProfitMargin)*2.5)
		end

	else
		taxRate = 0
	end
	-- 2: Add Elements to the state.revenue_and_taxes table
	taxAmount = grossSales * taxRate 
	state.custom_journal[vc].Income["_sum"]["Year "..cy]=grossSales
	state.custom_journal[vc].Maintenance["_sum"]["Year "..cy]=main
	state.custom_journal[vc]["Taxes"].Income["Year "..cy]=taxAmount
	if not state.custom_journal[vc].Income.GPMargin then state.custom_journal[vc].Income.GPMargin={} end
	if not state.custom_journal[vc].Income.TaxRate then state.custom_journal[vc].Income.TaxRate={} end
	state.custom_journal[vc].Income.GPMargin["Year "..cy]=grossProfitMargin
	state.custom_journal[vc].Income.TaxRate["Year "..cy]=taxRate
	
	return taxAmount 
end
function data_refresh_pastYears()
	if not state.custom_journal then return end
	local currentTime = getClosestYearStart(api.engine.getComponent(0,16).gameTime/1000) -- returns 3 parameters: Time in seconds and Year (counted from the beginning of the Savegame), Month in current Year 
	local vc 
	for y=currentTime[2]-6, currentTime[2]-1 do
		-- Check if in the cust Journal
		local journal = game.interface.getPlayerJournal(1000*730.5*(y-1), 1000*((y*730.5)-0.001), false)
		for i =1,#config.vehicleCat do
			vc=config.vehicleCat[i]
			state.custom_journal[vc]["Vehicles"]["Year "..y] = journal.acquisition[vc]
			state.custom_journal[vc]["Infrastructure"]["Year "..y]=journal.construction[vc]._sum
			state.custom_journal[vc]["Income"]["_sum"]["Year "..y]=journal.income[vc]
			state.custom_journal[vc]["Maintenance"]["_sum"]["Year "..y]=journal.maintenance[vc]._sum
		end
		state.custom_journal.interest["Year "..y]=journal.interest
		state.custom_journal.header.labels["Year "..y]=y
	end
	state.updList = 1
end
function data_shrink_log()
	for y = 1,(state.currentYear-7) do
		for i=1,#config.vehicleCat do
			local vc=config.vehicleCat[i]
			state.custom_journal[vc]["Income"]["_sum"]["Year " .. y]=nil
			state.custom_journal[vc]["Maintenance"]["_sum"]["Year " .. y]=nil
			state.custom_journal[vc]["Infrastructure"]["Year " .. y]=nil
			state.custom_journal[vc]["Vehicles"]["Year " .. y]=nil
			state.custom_journal[vc]["Taxes"]["Income"]["Year " .. y]=nil
			state.custom_journal[vc]["Taxes"]["Infrastructure"]["Year " .. y]=nil
			state.custom_journal[vc]["Taxes"]["Vehicles"]["Year " .. y]=nil		
			if state.custom_journal[vc].Income.GPMargin then 
				if state.custom_journal[vc].Income.GPMargin["Year "..y] then
					state.custom_journal[vc].Income.GPMargin["Year "..y]=nil
				end
			end
		end
		state.custom_journal["header"]["labels"]["Year " .. y]=nil
		state.custom_journal["interest"]["Year " .. y]=nil
		state.custom_journal["TotalTax"]["Year " .. y]=nil
		
	end
end
function data_getUsedCarriers()
	--local taxTable = api.gui.util.getById("Taxes_DetailsTable")
	if taxTable then
		local journal
		local year = getCurrentGameYear()
		local yearStartEnd = getYearStart_End(year)
		local start = yearStartEnd[1]-(3*(730.5)*1000)
		local endTime = yearStartEnd[2]-(1*(730.5)*1000)
		journal = game.interface.getPlayerJournal(start, endTime, false)
		for i=1,#config.vehicleCat do
			local vc=config.vehicleCat[i]
			if journal.maintenance[vc]._sum ~= 0 then
				local element = taxTable:getItem((i - 1)*7 + 2 ,0)
				if element:isVisible() == false then
					ui_refresh_TaxTable_usedCarriers(taxTable,i,true)
					local button = api.gui.util.getById("L0Button"..vc)
					button:click()
				end
			else
				ui_refresh_TaxTable_usedCarriers(taxTable,i,false)
			end
		end
	end
end
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
			comp:setText(_("Year").." "..state.custom_journal.header.labels["Year "..cy]) 
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
		local txt = api.gui.comp.TextView.new(_(state.custom_journal[cat].label))
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
function ui_init_detailsTable()
	-- Initiate Custom_Journal if not exists
	
			
	--1: Variable declaration / initalization
	local NoOfCols = 9
	local tblDetails = api.gui.comp.Table.new(NoOfCols,"NONE")
	local icon_expand_path = "ui/design/components/slim_arrow_right@2x.tga"
	local icon_collapse_path = "ui/design/components/slim_arrow_down@2x.tga"
	
	local expandButton
	local row ={} -- Local Variable holding all rows for the table
	
	--2.1: Create Header Row
	
	for i = 1, NoOfCols do
		local lbl_element 	= api.gui.comp.Component.new("Header")
		local lbl_layout 	= api.gui.layout.BoxLayout.new("HORIZONTAL")
		local txt 			= api.gui.comp.TextView.new("")
		txt:setId("TaxHeader"..math.abs(i-NoOfCols-1))
		
		if i ==1 then
			txt:setStyleClassList({"Header","tableElement","Total","Label"})
			lbl_element:setStyleClassList({"Header","Label"})
		else
			txt:setStyleClassList({"Header","tableElement"})
			lbl_element:setStyleClassList({"Header","Label"})
		end
		lbl_layout:addItem(txt)
		lbl_element:setLayout(lbl_layout)
		
		table.insert(row,lbl_element)
	end
	
	--add Row to table & reset
	tblDetails:addRow(row)
	row ={}
	
	for i = 1, NoOfCols do
		local lbl_element 	= api.gui.comp.Component.new("Subheader")
		local lbl_layout 	= api.gui.layout.BoxLayout.new("HORIZONTAL")
		local txt 			= api.gui.comp.TextView.new("")
			
		if i ==2 or i==4 or i==6 or i==8 then
			txt:setText("Result")
			txt:setStyleClassList({"Subheader","tableElement","subheader"})
			lbl_element:setStyleClassList({"Subheader","Label"})
		elseif i~= 1 then
			txt:setText("Tax")
			txt:setStyleClassList({"Subheader","tableElement","subheader"})
			lbl_element:setStyleClassList({"Subheader"})
		elseif i== 1 then
			txt:setStyleClassList({"Subheader","tableElement","Subheader"})
			lbl_element:setStyleClassList({"Subheader"})
		end
		lbl_layout:addItem(txt)
		lbl_element:setLayout(lbl_layout)
		
		table.insert(row,lbl_element)
	end
	
	--add Row to table & reset
	tblDetails:addRow(row)
	row ={}
	-- Vehicle Rows
	for j = 1, #config.vehicleCat do
		local vc = config.vehicleCat[j]
		ui_tableConstructor(tblDetails,NoOfCols,vc,j)
	end
	-- Summary Rows
	ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"empty",""},"empty")
	
	ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxInterest","Interest"},"level1")
	ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxPayedTaxes","Payed Taxes (for previous year)"},"level1")
	ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxTotal","Total"},"level1")
	ui_tableConstructor_singleLine(tblDetails,NoOfCols,{"TaxNetResult","Net Result"},"Total")
	
	-- Tax Summary Details
	
	ui_refresh_taxDetails()
	-- return state.custom_journal.cat.IDs & state.custom_journal.cat.vc.IDs to engine
	callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("extendedStats.Main","StateUpdate","custom_journal",{custom_journal = state.custom_journal}))
	print("Created Details Table")
	return tblDetails
end
function ui_init_settingsTable()
	--1: Variable declaration / initalization
	local NoOfCols = 3
	local tblDetails = api.gui.comp.Table.new(NoOfCols,"NONE")
	local icon_expand_path = "ui/design/components/slim_arrow_right@2x.tga"
	local icon_collapse_path = "ui/design/components/slim_arrow_down@2x.tga"
	
	local expandButton
	local row ={} -- Local Variable holding all rows for the table

-- 3.0 Table Content
-- 3.0.1 Structure
	-- Level 0: Top Level Category (Vehicle Types){"rail","road","tram","air","water"}
	-- Level 1: TaxCategories: Income, Vehicle Acquisitions, Infrastructure construction
	
	for a=1, #config.vehicleCat do
		local cat = config.vehicleCat[a]
		-- Level 0 Row Label
			for i = 1, NoOfCols do
				local l0_component = api.gui.comp.Component.new(_(state.tax_rates[cat].label) or _(tax_rates[cat].label))
				local l0_layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
				local txt = api.gui.comp.TextView.new(_(state.tax_rates[cat].label) or _(tax_rates[cat].label))
				-- Add Button to Component if Column 1
				if i==1 then
					txt:setStyleClassList({"level0","tableElement","Label","Setting"})
					l0_component:setStyleClassList({"level0","Label","Setting"})
					
				elseif i==2 then
					txt:setText("Max (Tax rate)")
					txt:setStyleClassList({"level0","tableElement","Setting"})
					l0_component:setStyleClassList({"level0","Setting"})
				elseif i==3 then
					txt:setText("Min (negative = tax rate, positive = subsidies")
					txt:setStyleClassList({"level0","tableElement","Setting"})
					l0_component:setStyleClassList({"level0","Setting"})
				end
				txt:setId("Setting"..cat.."TextView"..math.abs(i-NoOfCols-1))		
				
				l0_component:setId("Setting"..cat..""..math.abs(i-NoOfCols-1))
				l0_layout:setName("L0Layout")
				l0_layout:addItem(txt)
				l0_component:setLayout(l0_layout)
				
				-- Add Component to Row Element
				table.insert(row,l0_component)
				
			end
		tblDetails:addRow(row)
		row ={}
		
		-- 3.1.2: Subcategories
		for i=1,#config.taxes.TaxCategories do -- Create the same structure for all config.vehicleCat
			local tx= config.taxes.TaxCategories[i]
			
			-- Create columns
			for c = 1,NoOfCols do
				local lbl_element = api.gui.comp.Component.new(cat..tx..c)
				local lbl_layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
				lbl_element:setLayout(lbl_layout)
				lbl_layout:setName("L1Layout")
				
				local txt = api.gui.comp.TextView.new("")
				if c== 1 then
					txt:setText(_(tx))
					if tooltips.settings[tx] then txt:setTooltip(tooltips.settings[tx]) end
					lbl_layout:addItem(txt)
					lbl_element:setStyleClassList({"level1","Label","Setting"})
				elseif c== 2 then
					local setting_max_layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
					local setting_max_sldr = api.gui.comp.Slider.new(true)			
					local setting_val_max = api.gui.comp.TextView.new("") 
					lbl_element:setStyleClassList({"level1","Slider","Setting"})
					
					if tx=="Income" then
						setting_max_sldr:setValue(math.floor(((state.tax_rates[cat][tx].maxVal or tax_rates[cat][tx].maxVal)+1)*100), false)
						setting_val_max:setText(format_num((state.tax_rates[cat][tx].maxVal or tax_rates[cat][tx].maxVal) * 100,0,"","-","%"))
					else
						setting_max_sldr:setValue(math.floor((state.tax_rates[cat][tx]+1 or tax_rates[cat][tx] +1)*100), false)
						setting_val_max:setText(format_num((state.tax_rates[cat][tx] or tax_rates[cat][tx]) * 100,0,"","-","%"))
					end
					setting_max_sldr:setId("tax"..cat..""..tx.."maxslider")
					setting_max_sldr:setStep(5)
					setting_max_sldr:setMinimum(05)
					setting_max_sldr:setMaximum(100)
					setting_max_sldr:setStyleClassList({"SliderClass"})
					
					setting_max_sldr:onValueChanged(function(value)
						setting_val_max:setText(format_num((value-100),0,"","-","%"))
						callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("extendedStats.Main","SettingsChange",tx,
								{ 
									rate = (value/100)-1,
									type = cat,
									minmax ="maxVal"
								}
							))
						end)
						setting_max_layout:addItem(setting_max_sldr)
						setting_max_layout:addItem(setting_val_max)
						lbl_layout:addItem(setting_max_layout)
				elseif c==3 then
					if tx=="Income" then
						local setting_min_layout = api.gui.layout.BoxLayout.new("HORIZONTAL")
						local setting_min_sldr = api.gui.comp.Slider.new(true)
						local setting_val_min = api.gui.comp.TextView.new(format_num((state.tax_rates[cat][tx].minVal or tax_rates[cat][tx].minVal) * 100,0,"","-","%")) 
						lbl_element:setStyleClassList({"level1","Slider","Setting"})
						
						setting_min_sldr:setValue(math.floor((state.tax_rates[cat][tx].minVal+1 or tax_rates[cat][tx].minVal+1)*100), false)
						setting_min_sldr:setId("tax"..cat..""..tx.."minslider")
						setting_min_sldr:setStep(5)
						setting_min_sldr:setMinimum(80)
						setting_min_sldr:setMaximum(120)
						setting_min_sldr:setStyleClassList({"SliderClass"})
						setting_min_sldr:onValueChanged(function(value)
							setting_val_min:setText(format_num((value-100),0,"","-","%"))
							callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("extendedStats.Main","SettingsChange",tx,
								{ 
									rate = (value/100)-1,
									type = cat,
									minmax ="minVal"
								}
								))          
							end)
							setting_min_layout:addItem(setting_min_sldr)
							setting_min_layout:addItem(setting_val_min)
							lbl_layout:addItem(setting_min_layout)
					else
						lbl_layout:addItem(txt)
					end
					
				end
				table.insert(row,lbl_element)
			end
			tblDetails:addRow(row)
			row ={}
		end
	end
	-- Show / Hide Year Label
	local labelContainer= api.gui.comp.Component.new("ShowYearLabel")
	local labelLayout = api.gui.layout.BoxLayout.new("HORIZONTAL") 
	local labelText = _("#SettingsYearButtonText") 
	local labelTextView = api.gui.comp.TextView.new(labelText)		
	labelContainer:setLayout(labelLayout)
	labelLayout:addItem(labelTextView)
	
	local yearButtonContainer = api.gui.comp.Component.new("YearButton")
	local yearButtonLayout = api.gui.layout.BoxLayout.new("HORIZONTAL")
	local yearButtonText = ""
	local yearButtonTextView = api.gui.comp.TextView.new(yearButtonText)	
	yearButtonTextView:setId("taxes.yearButtonText")
	local yearButton = api.gui.comp.Button.new(yearButtonTextView,false)
	yearButton:setId("taxes.YearButton")
	if state.showGameYear==0 then
		yearButtonText = _("#SettingsYearButtonLabelNo")
	
	else
		yearButtonText = _("#SettingsYearButtonLabelYes")
	end
	yearButtonTextView:setText(yearButtonText)
	
	labelTextView:setStyleClassList({"level0","tableElement","Setting"})
	labelContainer:setStyleClassList({"level0","tableElement","Setting"})
	yearButton:setStyleClassList({"level0","tableElement","Setting"})
	yearButtonContainer:setStyleClassList({"level0","Setting"})
	
	yearButtonContainer:setLayout(yearButtonLayout)
	yearButtonLayout:addItem(yearButton)
	yearButton:onClick(function()
		if state.showGameYear == 1 then 
			state.showGameYear = 0
			yearButtonText = _("#SettingsYearButtonLabelNo")
			
		else
			state.showGameYear = 1
			yearButtonText = _("#SettingsYearButtonLabelYes")
		end
		api.gui.util.getById("taxes.yearButtonText"):setText(yearButtonText)
		callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("TaxesSubsidies","Taxes_Subsidies","IngameYear",{show = state.showGameYear}))
	end)
	
	local emptyCont = api.gui.comp.Component.new("YearButtonEmpty")
	tblDetails:addRow({labelContainer,yearButtonContainer,emptyCont})
	
	return tblDetails		
end
function ui_init_taxTab ()
	
	--1.1: Components
		local parentElement = api.gui.util.getById("menu.finances.category")
		local window = parentElement:getParent():getParent()
		local winSize = api.gui.util.Size.new(1200,650)
		window:setSize(winSize)
		
		local useComp = api.gui.comp.Component.new("FinancesTaxes")
	--1.2: Call Sub Routines to create Setting & Details Tables	
		local setting_component = ui_init_settingsTable()
		local details_component = ui_init_detailsTable()
		details_component:setId("Taxes_DetailsTable")
		taxTable = details_component
	--1.2: Layouts
		local useLayout = api.gui.layout.BoxLayout.new("VERTICAL")
				
	--1.4: Text / Value Components
		local taxDescText = _("#TaxesDescription")
		local taxesDescription = api.gui.comp.TextView.new(taxDescText)		
        local useButtonLabel = api.gui.comp.TextView.new(_("Show Settings"))
		local useSettings = api.gui.comp.Button.new(useButtonLabel,false)
		useSettings:setId("Taxes_SettingsButton")
		useSettings:setStyleClassList({"SettingsButton"})
		
		local buttonsLayout = api.gui.layout.BoxLayout.new("HORIZONTAL")
		
		buttonsLayout:addItem(useSettings)
		
	--2 : Define Layouts & set Ids
	    useComp:setLayout(useLayout)
		useComp:setId("FinancesTaxesID")
		
	--3 : Add Elements to the Layouts:
	
		useLayout:addItem(taxesDescription)
		
		useLayout:addItem(buttonsLayout)
		
		useLayout:addItem(setting_component)
		useLayout:addItem(details_component)
			
		-- Add Tab to Finance Category Window
		parentElement:addTabText(_("Taxes"),useComp)
		
		setting_component:setVisible(false,false)
		details_component:setVisible(true,false)
		-- Update FUnctions
		useSettings:onClick(function()
			if setting_component:isVisible() then
				setting_component:setVisible(false,false)
				details_component:setVisible(true,false)
				useButtonLabel:setText(_("Show Settings"))
			else
				useButtonLabel:setText(_("Hide Settings"))
				setting_component:setVisible(true,false)
				details_component:setVisible(false,false)
			end
		end)
		
	
end
function ui_refresh_TaxTable_usedCarriers(taxTable,itemNo,showHide)
	local start= (itemNo - 1)*7 + 2 
	local lastRowToHide = start + 5
	local firstElement = taxTable:getItem(start,0)
	for c=0,8 do
		for r = start,lastRowToHide  do
			local element = taxTable:getItem(r,c)
			element:setVisible(showHide,false)
		end		
	end

end

-- ***************************
-- ** Main
-- ***************************

local extendedStats_script = {
	save = function ()
		return state
	end,

	load = function (data)
		
		local correctGameTime = getClosestYearStart(game.interface.getGameTime().time)
		if data then
			state.taxIntStartTime = correctGameTime[1]
			state.taxIntNextTime  = (correctGameTime[1] + 2 * 365.25) -- Current Time + 1 ingame Year
			state.currentYear 	  = correctGameTime[2]
			
			state.tax_rates 	  = data.tax_rates or state.tax_rates
			-- check if Journal exists
			if not data.custom_journal then
				state.custom_journal = data_init_customJournal()
				data_refresh_pastYears()
				callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("TaxesSubsidies","Mod_Initiation","custom_journal",{custom_journal = state.custom_journal,fullInit=true}))
				print("Created Custom Journal")
			else
				state.custom_journal  = data.custom_journal
			end
			state.showGameYear = data.showGameYear
			state.updList 		  = data.updList
			state.LastLinesRefreshMonth	  = data.LastLinesRefreshMonth or (correctGameTime[3]-1)
						
		else
			state.taxIntStartTime 	= correctGameTime[1]
			state.taxIntNextTime 	= (correctGameTime[1] + 2 * 365.25) -- Current Time + 1 ingame Year
			state.currentYear		= correctGameTime[2]
			state.updList			= nil
			state.LastLinesRefreshMonth  = (correctGameTime[3]-1)
			state.showGameYear = 1
			
			state.custom_journal = data_init_customJournal()
			data_refresh_pastYears()
			
			callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("TaxesSubsidies","Mod_Initiation","custom_journal",{custom_journal = state.custom_journal,fullInit=true}))
			print("Created Custom Journal")
		end
	end,

	guiUpdate = function ()
		if callback then
			for k,v in pairs(callback) do v() end
			callback ={}
		end
		if drivesGameYear then
			if state.showGameYear ==1 then
				api.gui.util.getById("gameInfo.gameYear"):setText(_("GT")..getCurrentGameYear().." M: "..getCurrentGameMonth())
				api.gui.util.getById("gameInfo.gameYear"):setVisible(true,false)
			elseif state.showGameYear ==0 then
				api.gui.util.getById("gameInfo.gameYear"):setVisible(false,false)
			end
			
		end
		if state.updList == 1 then
			ui_refresh_taxDetails()
			--data_getUsedCarriers()
			state.updList = 0
			callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("TaxesSubsidies","UI_Refresh","TaxTable",{updList = 0}))
		end
		if state.taxTabCreated==nil then 
			ui_init_taxTab()
			state.updList =0
			state.taxTabCreated = true
			callbacks[#callbacks + 1] = api.cmd.sendCommand(api.cmd.make.sendScriptEvent("TaxesSubsidies","Mod_Initiation","GuiObjects",{taxTabCreated = state.taxTabCreated, updList = state.updList}))
		end
		
	end,
	guiInit = function ()
		debugPrint(config)
		if not api.gui.util.getById("gameInfo.gameYear") then
			print("taxes: gameyear")
			drivesGameYear=true
			-- element for the divider
			local line = api.gui.comp.Component.new("VerticalLine")
			-- element for the Year
			local txtGameYear = api.gui.comp.TextView.new("")
			txtGameYear:setId("gameInfo.gameYear")
			txtGameYear:setTooltip(tooltips.Menu.gameInfo)
			-- add elements to ui
			local gameInfoLayout = api.gui.util.getById("menu.datePanel"):getLayout()
			gameInfoLayout:addItem(line) 
			gameInfoLayout:addItem(txtGameYear)
		end
	end,
	update = function ()
		
		local currentYearStart = getClosestYearStart(game.interface.getGameTime().time) -- returns 3 parameters: Time in seconds and Year (counted from the beginning of the Savegame), Month in current Year 
		local nextRefresh = getRefreshStart(game.interface.getGameTime().time)
		if (nextRefresh == currentYearStart[4][1] or nextRefresh == currentYearStart[4][2] or nextRefresh == currentYearStart[4][3] or nextRefresh == currentYearStart[4][4] or nextRefresh == currentYearStart[4][5] or nextRefresh == currentYearStart[4][6]) and state.LastLinesRefreshMonth ~= nextRefresh then -- Update every second month
			state.LastLinesRefreshMonth = nextRefresh
			
			bookAmount = 0
			-- get Journal for the past 365 ingame days
			journal = game.interface.getPlayerJournal(1000*state.taxIntStartTime, 1000*(state.taxIntNextTime-0.001), false)
			
			-- set new timeline today to today +365
			state.taxIntStartTime = currentYearStart[1]
			state.taxIntNextTime = (state.taxIntStartTime + 2 * 365.25)
			state.custom_journal.header.labels["Year "..state.currentYear]=state.currentYear
			local cy = state.currentYear
			
			for i=1,#config.vehicleCat do
				local vc=config.vehicleCat[i]
				-- add income to custom_journal
					bookAmount = bookAmount + data_calc_incomeTax(journal.income[vc],journal.maintenance[vc]._sum,state.tax_rates[vc].Income,vc)
					
				-- Vehicle Acquisitions
					local vehicleAcq = journal.acquisition[vc]
					local vehicleTax = math.abs(vehicleAcq) * state.tax_rates[vc].Vehicles
					-- book to custom_journal
					state.custom_journal[vc]["Vehicles"]["Year "..cy]= vehicleAcq
					state.custom_journal[vc]["Taxes"]["Vehicles"]["Year "..cy]=vehicleTax
					-- add to total tax
					bookAmount = bookAmount + vehicleTax
				-- Infrastructure
					local vehicleTypeInfrastructure = journal.construction[vc]._sum
					local vehicleTypeInfrastructureTax = (math.abs(vehicleTypeInfrastructure) * state.tax_rates[vc].Infrastructure)
					-- book to custom_journal
					state.custom_journal[vc]["Infrastructure"]["Year "..cy]=vehicleTypeInfrastructure
					state.custom_journal[vc]["Taxes"]["Infrastructure"]["Year "..cy]=vehicleTypeInfrastructureTax
					-- add to total Tax
					bookAmount = bookAmount + vehicleTypeInfrastructureTax
					
			end
			state.currentYear = currentYearStart[2] -- Update Year
			state.custom_journal.interest["Year "..cy] = journal.interest
			-- Book the Amount to the Journal. Current Category "other". 
			if nextRefresh == currentYearStart[4][1] then
				print("Year "..cy.. ": " .. bookAmount)
				game.interface.book(bookAmount, false) 
				if not state.custom_journal["TotalTax"] then state.custom_journal["TotalTax"] = {} end
				state.custom_journal["TotalTax"]["Year " .. (cy+1)] = bookAmount
				data_shrink_log()				
			end
			-- debugPrint(state)
			state.updList =1
		end
	
	end,

	handleEvent = function (src, id, name, param)
		if src=="extendedStats.Main" and id=="SettingsChange" and param then
			if name=="Income" then
				state.tax_rates[param.type][name][param.minmax]=param.rate
			else
				state.tax_rates[param.type][name]=param.rate
			end
		
		elseif src=="extendedStats.Main" and id=="StateUpdate" and name=="custom_journal" then
			-- Construction
			if param.fullInit then
				state.custom_journal = param.custom_journal_gui
			else
				for i=1, #config.vehicleCat do
					local cat = config.vehicleCat[i]
					state.custom_journal[cat].IDs = param.custom_journal[cat].IDs
					state.custom_journal[cat]["Taxes"].IDs=param.custom_journal[cat]["Taxes"].IDs
				end
			end
		elseif src=="TaxesSubsidies" and id=="Mod_Initiation" and name=="custom_journal" then
			state.custom_journal = param.custom_journal
		elseif src=="TaxesSubsidies" and id=="Taxes_Subsidies" and name =="IngameYear" then
			state.showGameYear = param.show
		elseif src =="TaxesSubsidies" and id =="UI_Refresh" and name=="TaxTable" then
			state.updList = param.updList
		end
	end,
	
	guiHandleEvent = function (id, name, param)
		
	end,
}

function data()
return extendedStats_script
end
