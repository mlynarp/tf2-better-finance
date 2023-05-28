require "pm_finance_constants"
require "pm_finance_functions"

local financeTabWindow = nil
local financeTable = nil
local summaryTable = nil
local guiUpdate = false
local lastBalance = 0
local lastYear = 0


local tooltips = {
    settings = {
        Income = _("#Tooltip.Settings.Income"),
        Vehicles = _("#Tooltip.Settings.Vehicles"),
        Infrastructure = _("#Tooltip.Settings.Infrastructure"),
    },
    Details = {
        Income = _("#Tooltip.Details.Income"),
        Maintenance = _("#Tooltip.Details.Maintenance"),
        Vehicles = _("#Tooltip.Details.Vehicles"),
        Infrastructure = _("#Tooltip.Details.Infrastructure")
    },
    Menu =
    {
        Button = _("#Tooltip.Menu.Button"),
        gameInfo = _("#Tooltip.GameYear"),
    }
}

local state = {
    currentYear = 0,
}

function UpdateValueCell(amount, textViewId)
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

function IsCategoryAllowedForTransportType(transportType, category)
     if category == CAT_INVESTMENTS_TRACKS and transportType ~= TRANSPORT_TYPE_RAIL then
        return false
     elseif category == CAT_INVESTMENTS_ROADS and transportType ~= TRANSPORT_TYPE_ROAD then
        return false
     end
     return true
end

function RefreshVehicleCategoryValues(transportType, journal, column)
    --total
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_TOTAL), transportType .. CAT_TOTAL .. column)
    --income
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_INCOME), transportType .. CAT_INCOME .. column)
    --maintenance
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE), transportType .. CAT_MAINTENANCE .. column)
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_VEHICLES), transportType .. CAT_MAINTENANCE_VEHICLES .. column)
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_MAINTENANCE_INFRASTRUCTURE), transportType .. CAT_MAINTENANCE_INFRASTRUCTURE .. column)
    --investment
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS), transportType .. CAT_INVESTMENTS .. column)
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_VEHICLES), transportType .. CAT_INVESTMENTS_VEHICLES .. column)
    if IsCategoryAllowedForTransportType(transportType, CAT_INVESTMENTS_TRACKS) then
        UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_TRACKS), transportType .. CAT_INVESTMENTS_TRACKS .. column)
    elseif IsCategoryAllowedForTransportType(transportType, CAT_INVESTMENTS_ROADS) then
        UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_ROADS), transportType .. CAT_INVESTMENTS_ROADS .. column)
    end
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_INVESTMENTS_INFRASTRUCTURE), transportType .. CAT_INVESTMENTS_INFRASTRUCTURE .. column)
    --cashflow
    UpdateValueCell(GetValueFromJournal(journal, transportType, CAT_CASHFLOW), transportType .. CAT_CASHFLOW .. column)
    
end

function CreateExpandButton(level)
    local iconExpandPath = "ui/design/components/slim_arrow_right@2x.tga"
    local iconCollapsePath = "ui/design/components/slim_arrow_down@2x.tga"
    local imageView = api.gui.comp.ImageView.new(iconCollapsePath)
    local button = api.gui.comp.Button.new(imageView, false)
    button:setStyleClassList({ "sLevel" .. level, "sButton" })
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

        for c = 0, financeTable:getNumCols() - 1 do
            for r = startRowIndex, lastRowIndex do
                local element = financeTable:getItem(r, c)
                element:setVisible(setToVisible, false)
                if setToVisible then
                    imageView:setImage(iconCollapsePath, false)
                else
                    imageView:setImage(iconExpandPath, false)
                end
            end
        end
    end)
    return button
end

function CreateTextView(text, styleList, id)
    local textView = api.gui.comp.TextView.new(text)
    textView:setStyleClassList(styleList)
    textView:setId(id)
    return textView
end

function LayoutComponentsHorizontally(components, styleList, level)
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

function AddTransportCategoryLineToTable(labelComponents, rowId, sLevel, level)
    local row = {}

    table.insert(row, LayoutComponentsHorizontally(labelComponents, { sLevel }, level))
    for i = 1, NUMBER_OF_YEARS_COLUMNS do
        local yearCellView = CreateTextView(api.util.formatMoney(0), { sLevel, "sRight" }, rowId .. i)
        table.insert(row, LayoutComponentsHorizontally({ yearCellView }, { sLevel }, level))
    end
    local totalCellView = CreateTextView(api.util.formatMoney(0), { sLevel, "sRight" }, rowId .. COLUMN_TOTAL)
    table.insert(row, LayoutComponentsHorizontally({ totalCellView }, { sLevel }, level))

    financeTable:addRow(row)
end

function AddSummaryLineToTable(labelComponents, id, sLevel)
    local row = {}

    table.insert(row, LayoutComponentsHorizontally(labelComponents, { sLevel }, 0))
    
    local cellView = CreateTextView(api.util.formatMoney(0), { sLevel, "sRight" }, id)
    table.insert(row, LayoutComponentsHorizontally({ cellView }, { sLevel }, 0))

    summaryTable:addRow(row)
end

function AddTransportCategoriesToTable(transportType)
    -- level 0
    local labelView = CreateTextView(_(transportType), { "sLevel0", "sLeft" }, "")
    AddTransportCategoryLineToTable({ CreateExpandButton(0), labelView }, transportType .. CAT_TOTAL, "sLevel0", 0)

    -- level 1
    for i, level1Category in ipairs(TRANSPORT_CATEGORIES_LEVEL1) do
        if (#TRANSPORT_CATEGORIES_LEVEL2[level1Category] == 0) then
            labelView = CreateTextView(_(level1Category), { "sLevel1", "sLeft", "sLevelPadding" }, "")
            AddTransportCategoryLineToTable({ labelView }, transportType .. level1Category, "sLevel1", 1)
        else
            labelView = CreateTextView(_(level1Category), { "sLevel1", "sLeft" }, "")
            AddTransportCategoryLineToTable({ CreateExpandButton(1), labelView }, transportType .. level1Category, "sLevel1", 1)

            -- level 2
            for j, level2Category in ipairs(TRANSPORT_CATEGORIES_LEVEL2[level1Category]) do
                if IsCategoryAllowedForTransportType(transportType, level2Category) then
                    labelView = CreateTextView(_(level2Category), { "sLevel2", "sLeft", "sLevelPadding" }, "")
                    AddTransportCategoryLineToTable({ labelView }, transportType .. level2Category, "sLevel2", 2)
                end
            end
        end
    end

    labelView = CreateTextView(_(CAT_CASHFLOW), { "sLevel1", "sRight" }, "")
    AddTransportCategoryLineToTable({ labelView }, transportType .. CAT_CASHFLOW, "sLevel1", 0)
end

function AddTransportTableHeaders()
    local row = {}
    local gameYear = GetCurrentGameYear()

    table.insert(row, CreateTextView("", { "sHeader", "sRight" }, ""))
    for i = 1, NUMBER_OF_YEARS_COLUMNS do
        table.insert(row, CreateTextView(tostring(gameYear - NUMBER_OF_YEARS_COLUMNS + i), { "sHeader", "sRight" }, COLUMN_YEAR .. i))
    end
    table.insert(row, CreateTextView(_(COLUMN_TOTAL), { "sHeader", "sRight" }, COLUMN_TOTAL))

    financeTable:addRow(row)
end

function InitFinanceTable()
    financeTable = api.gui.comp.Table.new(NUMBER_OF_YEARS_COLUMNS + 2, "NONE")
    financeTable:setId("myFinancesOverviewTable")
    financeTable:setName("myFinancesOverviewTable")

    AddTransportTableHeaders()

    for j = 1, #TRANSPORT_TYPES do
        AddTransportCategoriesToTable(TRANSPORT_TYPES[j])
    end
end

function InitSummaryTable()
    summaryTable = api.gui.comp.Table.new(2, "NONE")
    summaryTable:setId("mySummaryTable")
    summaryTable:setName("mySummaryTable")
    summaryTable:setStyleClassList({"mySummaryTable"})

    local profitView = CreateTextView(_(CAT_PROFIT), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ profitView }, "profitCell", "mySummaryTableLine")
    local loanView = CreateTextView(_(CAT_LOAN), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ loanView }, "loanCell", "mySummaryTableLine")
    local interestView = CreateTextView(_(CAT_INTERESTS), { "mySummaryTableLineLabel", "sLeft" }, "")
    AddSummaryLineToTable({ interestView }, "interestCell", "mySummaryTableLine")
    local totalView = CreateTextView(_(CAT_BALANCE), { "mySummaryTableLineTotalLabel", "sLeft" }, "")
    AddSummaryLineToTable({ totalView }, "totalCell", "mySummaryTableLineTotal")
end

function InitFinanceTab()
    InitFinanceTable()
    InitSummaryTable()

    financeTabWindow = api.gui.util.getById("menu.finances.category")
    financeTabWindow:getParent():getParent():setSize(api.gui.util.Size.new(1100, 800))
    financeTabWindow:getParent():getParent():onVisibilityChange(function(visible)
        guiUpdate = visible
    end)

    local financeTableLayout = financeTabWindow:getTab(0):getLayout()
    --replace current finance table
    financeTableLayout:removeItem(financeTableLayout:getItem(0))
    financeTableLayout:insertItem(financeTable, 0)

    --replace current summary table
    financeTableLayout:removeItem(financeTableLayout:getItem(3))
    financeTableLayout:insertItem(summaryTable, 3)
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
        guiInit = function()
            InitFinanceTab()
        end,
        guiUpdate = function()
            local currentBalance = game.interface.getEntity(game.interface.getPlayer()).balance
            local currentYear = GetCurrentGameYear()
            if guiUpdate and financeTabWindow:getCurrentTab() == 0 and (currentBalance ~= lastBalance or currentYear ~= lastYear) then
                local overallJournal = GetJournal(0)
                for i = 1, #TRANSPORT_TYPES do
                    if lastYear ~= currentYear then
                        for j = 1, NUMBER_OF_YEARS_COLUMNS do
                            local year = currentYear - NUMBER_OF_YEARS_COLUMNS + j
                            RefreshVehicleCategoryValues(TRANSPORT_TYPES[i], GetJournal(year), j)
                            api.gui.util.getById(COLUMN_YEAR .. j):setText(tostring(year))
                        end
                    else
                        RefreshVehicleCategoryValues(TRANSPORT_TYPES[i], GetJournal(lastYear), NUMBER_OF_YEARS_COLUMNS)
                    end
                    RefreshVehicleCategoryValues(TRANSPORT_TYPES[i], overallJournal, COLUMN_TOTAL)
                end
                UpdateValueCell(GetValueFromJournal(overallJournal, TRANSPORT_TYPE_ALL, CAT_TOTAL), "profitCell")
                UpdateValueCell(overallJournal.loan, "loanCell")
                UpdateValueCell(overallJournal.interest, "interestCell")
                UpdateValueCell(overallJournal._sum, "totalCell")
              
                lastYear = currentYear
                lastBalance = currentBalance
            end
        end,
    }
end
