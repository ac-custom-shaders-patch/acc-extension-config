local lastId = 0
local timeouts = {}

function setTimeout(fn, delay, uniqueKey)
  if uniqueKey ~= nil then
    local len = #timeouts
    for i = 1, len do
      if timeouts[i].key == uniqueKey then return end
    end
  end

  if period == nil then period = 0 end
  local id = lastId
  lastId = lastId + 1
  table.insert(timeouts, { id = id, fn = fn, delay = delay, period = -1, key = uniqueKey })
  return id
end

function setInterval(fn, period, uniqueKey)
  if uniqueKey ~= nil then
    local len = #timeouts
    for i = 1, len do
      if timeouts[i].key == uniqueKey then return end
    end
  end

  if period == nil then period = 0 end
  local id = lastId
  lastId = lastId + 1
  table.insert(timeouts, { id = id, fn = fn, delay = period, period = period, key = uniqueKey })
  return id
end

function clearTimeout(id)
  for i = len, 1, -1 do
    if timeouts[i].id == id then
      table.remove(timeouts, i)
      return true
    end
  end
  return false
end

ac.clearInterval = ac.clearTimeout

function __updateInner(dt)
  local len = #timeouts
  for i = len, 1, -1 do
    local t = timeouts[i]
    t.delay = t.delay - dt
    if t.delay < 0 then
      if t.period >= 0 then
        t.delay = t.period
      else
        table.remove(timeouts, i)
      end
      t.fn()
    end
  end
end