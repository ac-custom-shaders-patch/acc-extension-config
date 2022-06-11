
function SpawnExplosion(s, o, P, cb)
  local size = o.size or 1
  local count = o.count or (10 * size)
  for i = 1, count do
    local offset = randomVec3()
    cb{ 
      pos = P.pos,
      velocity = (offset + vec3(0, o.tiltUp or 0.5, 0)) * (o.speed or 20),
      delay = math.random() * 0.1
    }
  end
end

function SpawnDelayedExplosion(s, o, P, cb)
  local size = o.spawnSize or s.size or 1
  local count = o.count or (10 * size)
  for i = 1, count do
    local offset = randomVec3()
    cb{ 
      pos = P.pos + offset * (40 * size),
      delay = (o.delay or 1) + math.random() * 0.2
    }
  end
end

function SpawnBurst(s, o, P, cb)
  local size = o.spawnSize or s.size or 1
  local count = o.count or (5 * size)
  for i = 1, count do
    local offset = randomVec3()
    cb{ 
      pos = P.pos + offset * (5 * size),
      delay = i * 0.5
    }
  end
end