-- To make things simpler, Lua’s table module is extended here

local function isArray(t, N)
  return next(t, N > 0 and N or nil) == nil
end

local function requireArray(t, N)
  if isArray(t, N) then return end
  error('Array is required')
end

function table.removeItem(t, item)
  local N = #t
  if isArray(t, N) then
    local e = 0
    for i = 1, N do
      if t[i] == item then
        e = i
        break
      end
    end
    if e ~= 0 then
      table.remove(t, e)
    end
  else
    local r = nil
    for key, value in pairs(t) do
      if value == item then
        r = key
      end
    end
    if r ~= nil then
      t[r] = nil
    end
  end
end

function table.contains(t, item)
  local N = #t
  if isArray(t, N) then
    for key = 1, N do
      if t[key] == item then
        return true
      end
    end
  else
    for _, value in pairs(t) do
      if value == item then
        return true
      end
    end
  end
  return false
end

function table.random(t, filter)
  local N = #t
  local r, k = nil, nil
  if isArray(t, N) then
    if filter == nil then
      k = math.random(N)
      r = t[k]
    else
      local n = 1
      for key = 1, N do
        local value = t[key]
        if filter(value, key) then
          if 1 / n >= math.random() then
            r, k = value, key
          end
          n = n + 1
        end
      end
    end
  else
    local n = 1
    for key, value in pairs(t) do
      if not filter or filter(value, key) then
        if 1 / n >= math.random() then
          r, k = value, key          
        end
        n = n + 1
      end
    end
  end
  return r, k
end

function table.indexOf(t, item)
  local N = #t
  if isArray(t, N) then
    for i = 1, N do
      if t[i] == item then
        return i
      end
    end
  else
    for key, value in pairs(t) do
      if value == item then
        return key
      end
    end
  end
  return nil
end

-- Finds first element for which testFn is true, returns index of an element before it
function table.findLeftOf(t, testFn)
  local N = #t
  requireArray(t, N)
  local countSearch = N
  local index = 0
  while countSearch > 0 do
    local step = math.floor(countSearch / 2)
    if testFn(t[index + step + 1], index + step + 1) then
      countSearch = step
    else
      index = index + step + 1
      countSearch = countSearch - step - 1
    end
  end
  return index
end

function table.join(t, s, sq)
  if s == nil then s = ',' end
  local ret = ''
  local N = #t
  if isArray(t, N) then
    for key = 1, N do
      if key > 1 then ret = ret .. s end
      ret = ret .. tostring(t[key])
    end
  else
    if sq == nil then sq = '=' end
    local f = true
    for key, value in pairs(t) do
      if f then ret = ret .. s f = false end
      ret = ret .. tostring(key) .. sq .. tostring(value)
    end
  end
  return ret
end

function table.slice(t, from, to, step)
  local ret = {}
  local N = #t
  requireArray(t, N)
  if from == nil or from == 0 then from = 1 elseif from < 0 then from = N + from end
  if to == nil or to == 0 then to = N elseif to < 0 then to = N + to end
  if step == nil or step == 0 then step = 1 end
  if step > 0 and to > from or step < 0 and to < from then
    for i = from, to, step do
      table.insert(ret, t[i])
    end
  end
  return ret
end

function table.reverse(t)
  local ret = {}
  local N = #t
  requireArray(t, N)
  for i = N, 1, -1 do
    table.insert(ret, t[i])
  end
  return ret
end

function table.map(t, callback)
  local ret = {}
  local N = #t
  if isArray(t, N) then
    for key = 1, N do
      local value = callback(t[key], key)
      if value ~= nil then
        table.insert(ret, value)
      end
    end
  else
    for key, value in pairs(t) do
      local newValue, newKey = callback(value, key)
      if newValue ~= nil then
        if newKey ~= nil then ret[newKey] = newValue
        else table.insert(ret, newValue) end
      end
    end
  end
  return ret
end

function table.filter(t, callback)
  local ret = {}
  local N = #t
  if isArray(t, N) then
    for key = 1, N do
      local value = t[key]
      if callback(value, key) then
        table.insert(ret, value)
      end
    end
  else
    for key, value in pairs(t) do
      if callback(value, key) then
        ret[key] = value
      end
    end
  end
  return ret
end

function table.every(t, callback)
  local N = #t
  if isArray(t, N) then
    for key = 1, N do
      local v = callback(t[key], key)
      if v == false or v == nil then
        return false
      end
    end
  else
    for key, value in pairs(t) do
      local v = callback(value, key) 
        if v == false or v == nil then
          return false
        end
    end
  end
  return true
end

function table.some(t, callback)
  local N = #t
  if isArray(t, N) then
    for i = 1, N do
      local e = t[i]
      if callback(e, i) then
        return e, i
      end
    end
  else
    for key, value in pairs(t) do
      if callback(value, key) then
        return value, key
      end
    end
  end
  return nil, nil
end

function table.maxEntry(t, callback)
  local r, k = nil, nil
  local v = -1/0
  table.forEach(t, function (item, key)
    local l = callback(item, key)
    if l > v then
      v = l
      r, k = item, key
    end
  end)
  return r, k
end

function table.minEntry(t, callback)
  local r, k = nil, nil
  local v = 1/0
  table.forEach(t, function (item, key)
    local l = callback(item, key)
    if l < v then
      v = l
      r, k = item, key
    end
  end)
  return r, k
end

function table.range(t, f, s, callback)
  if type(f) == 'function' then f, s, callback = 1, 1, f end
  if type(s) == 'function' then s, callback = 1, s end
  local r = {}
	for i = f, t, s do
		r[#r + 1] = callback(i)
	end
  return r
end

function table.isArray(t)
  if type(t) ~= 'table' then return false end
  local N = #t
  return isArray(t, N)
end

function table.forEach(t, callback)
  local N = #t
  if isArray(t, N) then
    for i = 1, N do
      callback(t[i], i)
    end
  else
    for key, value in pairs(t) do
      callback(value, key)
    end
  end
end

function table.distinct(t, callback)
  local N = #t
  local d = {}
  local r = {}
  if isArray(t, N) then
    for key = 1, N do
      local value = t[key]
      local u = callback and callback(value) or value
      if u ~= nil then
        if not d[u] then
          d[u] = true
          table.insert(r, value)
        end
      end
    end
  else
    for key, value in pairs(t) do
      local u = callback and callback(value) or value
      if u ~= nil then
        if not d[u] then
          d[u] = true
          r[key] = value
        end
      end
    end
  end
  return r
end

function table.merge(...)
  local ret = {}
  local args = {...}
  for i = 1, #args do
    local t = args[i]
    local N = #t
    requireArray(t, N)
    for j = 1, N do
      table.insert(ret, t[j])
    end
  end
  return ret
end

function table.flatten(t, maxLevel)
  local N = #t
  requireArray(t, N)
  maxLevel = maxLevel or 1

  local function flattenTo(ret, t, N, level)
    for key = 1, N do
      local value = t[key]
      if table.isArray(value) and level < maxLevel then
        flattenTo(ret, value, #value, level + 1)
      else
        table.insert(ret, value)
      end
    end
  end

  local ret = {}
  flattenTo(ret, t, N, 0)
  return ret
end
