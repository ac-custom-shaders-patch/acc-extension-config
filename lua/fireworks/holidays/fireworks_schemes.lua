local yield = coroutine.yield
PyroSchemesDev = nil
PyroSchemes = {}

PyroSchemes[#PyroSchemes + 1] = function ()
  for i = 1, 10 do
    Rocket:new{ dir = vec3(math.sin((i - 5) / 15), 1, 0), delay = i / 10 }
      -- :chain(FastExplosion)
      :chain(Explosion, { color = ColorChristmas })
  end
  yield(3.5)
  for i = 1, 5 do
    Rocket:new{ }:chain(
      math.random() > 0.9 and OrderedExplosion or Explosion, 
      { color = ColorChristmas })
    yield(1.5)
  end
end

PyroSchemes[#PyroSchemes + 1] = function ()
  for i = 1, 3 do
    ArcingRocket:new{}
  end
  GlowingRocket:new{ }
    :chain(Explosion, { color = ColorChristmas })
    :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorChristmas })
    :chain(Explosion, SpawnDelayedExplosion, { size = 0.4, color = ColorChristmas })
  yield(3.5)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  for i = 1, 10 do
    GlowingRocket:new{ dir = vec3(0, 1, math.sin((i - 5) / 15)) }
      :chain(FastExplosion, { color = ColorChristmas })
      :chain(Explosion, SpawnDelayedExplosion, { count = 5, size = 0.4, color = ColorChristmas })
    yield(0.5)
  end
  yield(2.5)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  function getType()
    if math.random() > 0.67 then return DoubleTwirl end
    if math.random() > 0.5 then return Twirl end
    return Spiral
  end
  for i = 1, 4 do
    GlowingRocket:new{ dir = randomVec3() + vec3(0, 5, i > 2 and 2 or -2) }
      :chain(getType(), { color = ColorChristmas })
    yield(0.1)
  end
  yield(1)
  Rocket:new{ }
    :chain(MassiveExplosion, { color = ColorChristmas })
    :chain(ConeSpark, SpawnExplosion, { count = 20, color = ColorChristmas })
  yield(1)
  Rocket:new{ }
    :chain(Explosion, { size = 0.7, color = ColorChristmas })
    :chain(MassiveSpark, SpawnExplosion, { count = 20, color = ColorChristmas })
  yield(1)
  Rocket:new{ }
    :chain(OrderedExplosion, { size = 0.7, color = ColorChristmas })
    :chain(TrailingSpark, SpawnExplosion, { count = 20, color = ColorChristmas })
  yield(5.5)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  Rocket:new{ }
    :chain(FastExplosion, { color = ColorChristmas })
    :chain(TrailingSpark, SpawnExplosion, { count = 6, color = ColorChristmas })
  Rocket:new{ }
    :chain(FastExplosion, { color = ColorChristmas })
    :chain(TrailingSpark, SpawnExplosion, { count = 6, color = ColorChristmas })
  Rocket:new{ }
    :chain(FastExplosion, { color = ColorChristmas })
    :chain(TrailingSpark, SpawnExplosion, { count = 6, color = ColorChristmas })
  yield(3.5)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  Fountain:new{ color = ColorChristmas, 
    offset = vec3(10 + math.random(), 0, 10 + math.random()), 
    delay = math.random() * 0.5 }
  Fountain:new{ color = ColorChristmas, 
    offset = vec3(-10 + math.random(), 0, -10 + math.random()), 
    delay = math.random() * 0.5 }
  RocketsGroup:new{}
  yield(2.5)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  function getType()
    if math.random() > 0.67 then return DoubleTwirl end
    if math.random() > 0.5 then return Twirl end
    return Spiral
  end
  Rocket:new{ aligned = 2 }:chain(getType(), { color = ColorChristmas })
  Rocket:new{ aligned = 2 }:chain(getType(), { color = ColorChristmas })
  Rocket:new{ aligned = 2 }:chain(getType(), { color = ColorChristmas })
  yield(4)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  GlowingRocket:new{}
    :chain(Explosion, { size = 0.6, color = ColorChristmas })
    :chain(Explosion, { size = 1, color = ColorChristmas })
    :chain(Explosion, { size = 1.4, color = ColorChristmas })
    :chain(MassiveSpark, SpawnExplosion, { count = 40, tiltUp = 0.5, speed = 30 })
    :chain(Explosion, { size = 0.1 })
  yield(3)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  Rocket:new{}
    :chain(Explosion, SpawnBurst, { color = ColorChristmas })
  yield(5)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  Rocket:new{ aligned = 20, flyTo = 40 }:chain(LastingExplosion, { color = rgb(0, 1, 0), density = 4, size = 0.5 })
  Rocket:new{ aligned = 20, flyTo = 60 }:chain(LastingExplosion, { color = rgb(0, 1, 0), density = 4, size = 0.35 })
  Rocket:new{ aligned = 20, flyTo = 75 }:chain(LastingExplosion, { color = rgb(0, 1, 0), density = 4, size = 0.2 })
  Rocket:new{ aligned = 20, flyTo = 85 }:chain(LastingExplosion, { color = rgb(1, 1, 0), density = 4, size = 0.05 })
  for i = 1, 10 do
    Rocket:new{ aligned = 4, flyTo = 35 + math.random() * 20, delay = i / 10 }
      :chain(LastingExplosion, { color = rgb(1, 0, 0), density = 4, size = 0.05 })
  end
  yield(6)
end

PyroSchemes[#PyroSchemes + 1] = function ()
  for i = 1, 5 do
    Rocket:new{}
      :chain(Explosion, { color = rgb(math.random(), math.random(), math.random()) })
    yield(0.3)
  end
end

PyroSchemes[#PyroSchemes + 1] = function ()
  if math.random() > 0.02 then 
    return PyroSchemes[1 + math.floor((#PyroSchemes - 1) * math.random())]()
  end

  local l = 5 + 10 * math.random()
  for i = 1, l do
    local type = math.random() > 0.5 and FastExplosion
      or math.random() > 0.5 and Rocket
      or math.random() > 0.5 and Explosion
      or ArcingRocket
      type:new{ delay = math.sqrt(math.random()), offset = vec3(math.random() - 0.5, 0, math.random() - 0.5) * 10 }
  end
  yield(25)
end
