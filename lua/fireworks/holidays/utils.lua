function randomVec3()
  return (vec3(math.random(), math.random(), math.random()) - 0.5):normalize()
end

function deepCopy(x)
  if type(x) ~= 'table' then return x end
  local t = {}
  for k, v in pairs(x) do
    t[k] = deepCopy(v)
  end
  return t
end

function fillProps(self, p)
  if p ~= nil then
    for k, v in pairs(p) do
      self[k] = v
    end
  end
end

function runGC()
  local before = collectgarbage('count')
  collectgarbage()
  ac.debug('GC', math.floor((before - collectgarbage('count')) * 100) / 100 .. " KB")
end

math.randomseed(os.time())