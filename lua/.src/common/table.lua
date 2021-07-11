-- To make things simpler, Lua’s table module is extended here

function table.removeItem(table, item)
  local e = 0
  for i = 1, #table do
    if table[i][2] == item then
      e = i
      break
    end
  end
  if e ~= 0 then
    table.remove(table, e)
  end
end
