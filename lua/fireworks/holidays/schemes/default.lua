local yield = coroutine.yield
local list = {}

-- Simple spread launch
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  local dir = vec2(math.random() - 0.5, math.random() - 0.5):normalize()
  for i = 1, 10 do
    local offset = math.sin((i - 5) / 15)
    rocketType:new{ dir = vec3(offset * dir.x, 1, offset * dir.y), delay = i / 10 }
      -- :chain(FastExplosion)
      :chain(Explosion, { color = ColorGeneric })
  end
  yield(3.5)
  for i = 1, 5 do
    Rocket:new{ }:chain(
      math.random() > 0.9 and OrderedExplosion or Explosion, 
      { color = ColorGeneric })
    yield(1.5)
  end
end

-- Complex spread lauch
list[#list + 1] = function ()
  local dir = vec2(math.random() - 0.5, math.random() - 0.5):normalize()
  local rocketType = RandomRocket()
  for i = 1, 10 do
    local offset = math.sin((i - 5) / 15)
    rocketType:new{ dir = vec3(offset * dir.x, 1, offset * dir.y) }
      :chain(FastExplosion, { color = ColorGeneric })
      :chain(Explosion, SpawnDelayedExplosion, { count = 5, size = 0.4, color = ColorGeneric })
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
    :chain(Explosion, { color = ColorGeneric })
    :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorGeneric })
    :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorGeneric })
  yield(3.5)
end

-- Rockets and spirals
list[#list + 1] = function ()
  local rocketType1 = RandomRocket()
  local rocketType2 = RandomRocket()
  for i = 1, 4 do
    rocketType1:new{ dir = randomVec3() + vec3(0, 5, i > 2 and 2 or -2) }
      :chain(RandomContinuousEffect(), { color = ColorGeneric })
    yield(0.1)
  end
  yield(1)
  rocketType2:new{ }
    :chain(MassiveExplosion, { color = ColorGeneric })
    :chain(ConeSpark, SpawnExplosion, { count = 20, color = ColorGeneric })
  yield(1)
  rocketType2:new{ }
    :chain(Explosion, { size = 0.7, color = ColorGeneric })
    :chain(MassiveSpark, SpawnExplosion, { count = 20, color = ColorGeneric })
  yield(1)
  rocketType2:new{ }
    :chain(OrderedExplosion, { size = 0.7, color = ColorGeneric })
    :chain(TrailingSpark, SpawnExplosion, { count = 20, color = ColorGeneric })
  yield(5.5)
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
    rocketType:new{ }
      :chain(Explosion, { color = ColorGeneric })
      :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorGeneric })
    yield(1)
  end
  yield(1.5)
end

-- Small custom spark rockets
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  local sparkType = RandomSpark()
  for i = 1, 3 + math.random() * 3 do
    rocketType:new{ }
      :chain(FastExplosion, { color = ColorGeneric })
      :chain(sparkType, SpawnExplosion, { count = 6, color = ColorGeneric })
    yield(0.1)
  end
  yield(3.5)
end

-- Fountains
list[#list + 1] = function ()
  Fountain:new{ color = ColorGeneric, 
    offset = vec3(10 + math.random(), 0, 10 + math.random()), 
    delay = math.random() * 0.5 }
  Fountain:new{ color = ColorGeneric, 
    offset = vec3(-10 + math.random(), 0, -10 + math.random()), 
    delay = math.random() * 0.5 }
  RocketsGroup:new{}
  yield(2.5)
end

-- Spirals
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 3 + math.random() * 3 do
    rocketType:new{ aligned = 2 }:chain(RandomContinuousEffect(), { color = ColorGeneric })
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

-- Bursts
list[#list + 1] = function ()
  RandomRocket():new{}
    :chain(Explosion, SpawnBurst, { color = ColorGeneric })
  yield(5)
end

-- Big complex explosion
list[#list + 1] = function ()
  RandomRocket():new{}
    :chain(Explosion, { size = 0.6, color = ColorGeneric })
    :chain(Explosion, { size = 1, color = ColorGeneric })
    :chain(Explosion, { size = 1.4, color = ColorGeneric })
    :chain(MassiveSpark, SpawnExplosion, { count = 40, tiltUp = 0.5, speed = 30 })
    :chain(Explosion, { size = 0.1 })
  yield(3)
end

-- Simple random colored explosions
list[#list + 1] = function ()
  local rocketType = RandomRocket()
  for i = 1, 5 do
    rocketType:new{}
      :chain(Explosion, { color = rgb(math.random(), math.random(), math.random()) })
    yield(0.3)
  end
end

-- Spectacular failure
list[#list + 1] = function ()
  if math.random() > 0.02 then 
    return list[1 + math.floor((#list - 1) * math.random())]()
  end

  local l = 10 + 10 * math.random()
  for i = 1, l do
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
