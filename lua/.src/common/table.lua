-- To make things simpler, Lua’s table module is extended here

function table.removeItem(t, item)
  local e = 0
  for i = 1, #t do
    if t[i] == item then
      e = i
      break
    end
  end
  if e ~= 0 then
    table.remove(t, e)
  end
end

function table.reverse(t)
  local ret = {}
  for i = #t, 1, -1 do
    table.insert(ret, t[i])
  end
  return ret
end

function table.map(t, callback)
  local ret = {}
  for i = 1, #t do
    local v = callback(t[i], i)
    if v ~= nil then
      table.insert(ret, v)
    end
  end
  return ret
end

function table.filter(t, callback)
  local ret = {}
  for i = 1, #t do
    if callback(t[i], i) then
      table.insert(ret, t[i])
    end
  end
  return ret
end

function table.every(t, callback)
  for i = 1, #t do
    if not callback(t[i], i) then
      return false
    end
  end
  return true
end

function table.some(t, callback)
  for i = 1, #t do
    if callback(t[i], i) then
      return true
    end
  end
  return false
end

function table.forEach(t, callback)
  for i = 1, #t do
    callback(t[i], i)
  end
end
