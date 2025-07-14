local constants = {}
local functions = {}

function functions.CreateTableView(numberOfColumns, id , name)
	local tableView = api.gui.comp.Table.new(numberOfColumns, "NONE")

    if (id) then
        tableView:setId(id)
    end

    if (name) then
        tableView:setName(name)
    end

	return tableView
end

function functions.SetHeader(tableView, components)
    tableView:setHeader(components)
end

function functions.SetRowVisibilityInTable(tableView, row, visible)
    if row >= tableView:getNumRows() then
        return
    end
    for column = 0, tableView:getNumCols() - 1 do
        tableView:getItem(row, column):setVisible(visible, false)
    end
end



local tableView = {}
tableView.constants = constants
tableView.functions = functions

return tableView