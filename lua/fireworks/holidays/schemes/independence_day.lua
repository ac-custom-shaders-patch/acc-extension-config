local yield = coroutine.yield
local list = {}

-- Flood of smaller rockets
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 10 + math.random() * 20 do
    rocketType:new{}:chain(Explosion, { color = ColorIndependenceDay })
    yield(0.2 * math.random())
  end
  yield(1.5)
end

-- A few massive rockets
list[#list + 1] = function ()
  for i = 1, 3 + math.random() * 9 do
    if math.random() > 0.8 then
      for i = 1, 2 + math.random() * 2 do
        ArcingRocket:new{}
      end
    end
    local color = ColorIndependenceDay()
    if math.random() > 0.5 then
      Rocket:new{ flyTo = 100 }
        :chain(MassiveExplosion, { color = color, density = 4, size = 1.5 })
        :chain(ConeSpark, SpawnExplosion, { count = 30, color = color, speed = 90 })
    else
      Rocket:new{ flyTo = 100 }
        :chain(MassiveExplosion, { color = color, density = 4, size = 1.5 })
        :chain(TrailingSpark, SpawnExplosion, { count = 30, color = color, speed = 40 })
    end
    yield(1.5)
  end
  yield(1.5)
end

-- Combined explosions
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 5 + math.random() * 10 do
    if math.random() > 0.8 then
      for i = 1, 2 + math.random() * 2 do
        ArcingRocket:new{}
      end
    end
    local color = ColorIndependenceDay()
    rocketType:new{ }
      :chain(Explosion, { color = color })
      :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = color })
    yield(1)
  end
  yield(1.5)
end

-- Small custom spark rockets
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  local sparkType = RandomSpark()
  for i = 1, 3 + math.random() * 3 do
    local color = ColorIndependenceDay()
    rocketType:new{ }
      :chain(FastExplosion, { color = color })
      :chain(sparkType, SpawnExplosion, { count = 6, color = color })
    yield(0.1)
  end
  yield(3.5)
end

-- Bursts
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 3 + math.random() * 3 do
    rocketType:new{}
      :chain(Explosion, SpawnBurst, { color = ColorIndependenceDay })
    yield(2)
  end
  yield(5)
end

-- Big complex explosion
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  rocketType:new{ flyTo = 80 }
    :chain(Explosion, { size = 0.6, color = ColorIndependenceDay })
    :chain(Explosion, { size = 1, color = ColorIndependenceDay })
    :chain(Explosion, { size = 1.4, color = ColorIndependenceDay })
    :chain(MassiveSpark, SpawnExplosion, { count = 40, tiltUp = 0.5, speed = 30 })
    :chain(Explosion, { size = 0.1, color = ColorIndependenceDay })
  yield(3)
end

-- Spirals
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 3 + math.random() * 3 do
    rocketType:new{ aligned = 2 }:chain(RandomContinuousEffect(), { color = ColorIndependenceDay })
    yield(0.2)
  end
  yield(2)
  if math.random() > 0.2 then
    RocketsGroup:new{}
  end
  yield(2)
  if math.random() > 0.2 then
    Fountain:new{}
  end
  yield(2)
end

-- Spectacular failure
list[#list + 1] = function ()
  if math.random() > 0.02 then 
    return list[1 + math.floor((#list - 1) * math.random())]()
  end

  for i = 1, 10 + 10 * math.random() do
    local r = math.random()
    local type = r > 0.6 and FastExplosion
      or r > 0.4 and MassiveExplosion
      or r > 0.3 and RandomRocket()
      or r > 0.1 and Fountain
      or ArcingRocket
      type:new{ delay = math.sqrt(math.random()), offset = vec3(math.random() - 0.5, 0, math.random() - 0.5) * 10 }
    yield(math.random() > 0.2 and 0.2 * math.random() or 0)
  end
  yield(25)
end

return list
