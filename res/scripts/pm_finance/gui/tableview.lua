local constants = {}
local functions = {}

function functions.CreateTableView(numberOfColumns, id , name)
	local tableView = api.gui.comp.Table.new(numberOfColumns, "NONE")

    if (id) then
        tableView:setId(id)
    end

    if (name) then
        tableView:setName(id)
    end

	return tableView
end

function functions.SetHeader(tableView, components)
    tableView:setHeader(components)
end



local tableView = {}
tableView.constants = constants
tableView.functions = functions

return tableView