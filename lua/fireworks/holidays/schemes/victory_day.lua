local yield = coroutine.yield
local list = {}

-- Simple spread launch
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  local dir = vec2(math.random() - 0.5, math.random() - 0.5):normalize()
  for i = 1, 10 do
    local offset = math.sin((i - 5) / 15)
    rocketType:new{ dir = vec3(offset * dir.x, 1, offset * dir.y), delay = i / 10 }
      :chain(Explosion, { color = ColorVictoryDay })
  end
  yield(3.5)
end

-- Complex spread lauch
list[#list + 1] = function ()
  local dir = vec2(math.random() - 0.5, math.random() - 0.5):normalize()
  local rocketType = RandomRocket()
  for i = 1, 10 do
    local offset = math.sin((i - 5) / 15)
    rocketType:new{ dir = vec3(offset * dir.x, 1, offset * dir.y) }
      :chain(FastExplosion, { color = ColorVictoryDay })
      :chain(Explosion, SpawnDelayedExplosion, { count = 5, size = 0.4, color = ColorVictoryDay })
    yield(0.5)
  end
  yield(2.5)
end

-- Massive combination
list[#list + 1] = function ()
  for i = 1, 3 + 3 * math.random() do
    ArcingRocket:new{}
  end
  GlowingRocket:new{ }
    :chain(Explosion, { color = ColorVictoryDay })
    :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorVictoryDay })
    :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorVictoryDay })
  yield(3.5)
end

-- Flood of smaller rockets
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 10 + math.random() * 20 do
    rocketType:new{}:chain(Explosion, { color = ColorVictoryDay })
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
    local color = ColorVictoryDay()
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

-- -- Combined explosions
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 5 + math.random() * 10 do
    if math.random() > 0.8 then
      for i = 1, 2 + math.random() * 2 do
        ArcingRocket:new{}
      end
    end
    local color = ColorVictoryDay()
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
    local color = ColorVictoryDay()
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
      :chain(Explosion, SpawnBurst, { color = ColorVictoryDay })
    yield(2)
  end
  yield(5)
end

-- Big complex explosion
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  rocketType:new{ flyTo = 80 }
    :chain(Explosion, { size = 0.6, color = ColorVictoryDay })
    :chain(Explosion, { size = 1, color = ColorVictoryDay })
    :chain(Explosion, { size = 1.4, color = ColorVictoryDay })
    :chain(MassiveSpark, SpawnExplosion, { count = 40, tiltUp = 0.5, speed = 30 })
    :chain(Explosion, { size = 0.1, color = ColorVictoryDay })
  yield(3)
end

return list
