-- Basic rocket

Rocket = Piece:newType()
function Rocket:init(P)
  self.dir = self.dir or vec3(math.random() - 0.5, self.aligned or 3, math.random() - 0.5)
  self.dir = math.normalize(self.dir)
  self.flyTo = self.pos.y + (self.flyTo or (50 * (0.7 + 0.6 * math.random())))
  self.force = (self.force or 1) * 200
  self:setSparking(10, 0.5)
  self:setSparkingSpread(0.5, 0.5, 0.5)
  self:setSparkingDir(-self.dir, 0.1, 0)
  self:setSparkingSpeed(self.force * 0.15, 0.5)  

  self:setSmoking(1, 2)
  self:setSmokingSpread(0)
  self:setSmokingVelocity(-self.dir * (self.force * 0.15))
end
function Rocket:audio(P)
  audioSetHiss(P.pos, 1, 2)
end
function Rocket:update(P, dt)
  P.pos = P.pos + P.velocity * dt
  P.velocity = math.applyLag(P.velocity, vec3(), 0.985, dt)
  P.velocity.y = P.velocity.y - 30 * dt
  P.sparkingLifespan = 0.5 * math.saturate(P.velocity.y / 40)
  P.smokingLifespan = 2 * math.saturate(P.velocity.y / 40)
  if P.pos.y > self.flyTo then
    P.sparkingIntensity = math.applyLag(P.sparkingIntensity, 0, 0.95, dt)
    P.smokingIntensity = math.applyLag(P.smokingIntensity, 0, 0.9, dt)
  else
    P.velocity = P.velocity + self.force * self.dir * dt
  end
  self:addLight()
  return P.velocity.y > 0 and (P.pos.y < self.flyTo or P.velocity.y > 10)
end

-- Arcing double trail rocket

ArcingRocket = Piece:newType()
function ArcingRocket:init(P, o)
  self.dir = (self.dir or vec3(math.random() - 0.5, self.aligned or 3, math.random() - 0.5))
  self.dir = math.normalize(self.dir)
  self.force = (self.force or 1) * 200
  self:setSparking(30, 1)
  self:setSparkingSpread(0.5, 0.5, 0.5)
  self:setSparkingDir(-self.dir, 0.1, 0)
  self:setSparkingSpeed(self.force * 0.15, 0.5)  

  self:setSmoking(1, 2)
  self:setSmokingSpread(0)
  self:setSmokingColor(1)
  self:setSmokingVelocity(-self.dir * (self.force * 0.15))
  P.velocity = self.dir
end
function ArcingRocket:audio(P)
  audioSetHiss(P.pos, 0.5, 1.5)
end
function ArcingRocket:update(P, dt)
  P.pos = P.pos + P.velocity * dt
  P.velocity.y = P.velocity.y - 20 * dt

  local dir = math.normalize(P.velocity)
  P.velocity = P.velocity + (self.force * dt) * dir
  P.velocity = P.velocity + randomVec3() * dt * 10

  dir.y = dir.y + 0.5
  dir:normalize()

  self.force = math.applyLag(self.force, 0, 0.95, dt)
  P.sparkingIntensity = math.applyLag(P.sparkingIntensity, 0, 0.985, dt)
  P.smokingIntensity = math.applyLag(P.smokingIntensity, 0, 0.99, dt)

  self:setSparkingDir(-dir, 0.1, 0)
  self:setSmokingVelocity(-dir * (self.force * 0.15))
  self:addLight()
  return P.velocity.y > 0 or P.sparkingIntensity > 0.2
end

-- Glowing rocket

GlowingRocket = Piece:newType()
function GlowingRocket:init(P)
  self.dir = self.dir or vec3(math.random() - 0.5, self.aligned or 3, math.random() - 0.5)
  self.dir = math.normalize(self.dir)
  self.flyTo = self.pos.y + (self.flyTo or (50 * (0.7 + 0.6 * math.random())))
  self.force = (self.force or 1) * 200
  
  -- glowOffset
  P.glowBrightness = 0
  P.glowSize = 0.35
  P.glowColor = rgb(1, 0, 0)

  self:setSmoking(1, 2, 4)
  self:setSmokingColor(1)
  self:setSmokingSpread(0)
  self:setSmokingVelocity(-self.dir * (self.force * 0.15))
end
function GlowingRocket:audio(P)
  audioSetHiss(P.pos, 0.5, 1.5)
end
function GlowingRocket:update(P, dt)
  P.pos = P.pos + P.velocity * dt
  P.velocity = math.applyLag(P.velocity, vec3(), 0.985, dt)
  P.velocity.y = P.velocity.y - 30 * dt
  -- P.sparkingLifespan = 0.5 * math.saturate(P.velocity.y / 40)
  self:setBurst(1, 0.1)
  P.smokingLifespan = 2 * math.saturate(P.velocity.y / 40)
  if P.pos.y > self.flyTo then
    P.sparkingIntensity = math.applyLag(P.sparkingIntensity, 0, 0.95, dt)
    P.smokingIntensity = math.applyLag(P.smokingIntensity, 0, 0.9, dt)
    P.glowBrightness = math.applyLag(P.glowBrightness, 0, 0.95, dt)
  else
    P.velocity = P.velocity + self.force * self.dir * dt
    P.glowBrightness = math.applyLag(P.glowBrightness, 3, 0.9, dt)
  end
  self:addLight(0.03, rgb(1, 0, 0) * P.glowBrightness)
  
  -- local audio = audioPoolGet()
  -- if audio ~= nil then audio:set(P.pos, false) end

  return P.velocity.y > 0 and (P.pos.y < self.flyTo or P.velocity.y > 10)
end

-- Random spawning rocket

function RandomRocket()
  local r = math.random()
  return r > 0.5 and Rocket
    or GlowingRocket
end

-- Series of rockets

RocketsGroup = Group:newType()
function RocketsGroup:init(P, o)
  for i = 1, self.count or 10 do
    P[#P + 1] = Rocket:new({ aligned = 6 }, o)
  end
end

-- Sparking fountain

Fountain = Piece:newType()
function Fountain:init(P)
  P.velocity = vec3()
  self:setSparking(4, 2)
  self:setSparkingSpread(1, 0.5, 0)
  self:setSparkingDir(vec3(0, 1, 0), 0.01, 0.01)
  self:setSparkingSpeed(80, 0.7)
  self:setSmoking(0.5, 1, 3)
  self:setSmokingSpeed(30, 0.5)
  audioSetHiss(P.pos)
  self.time = 0
end
function Fountain:audio(P)
  audioSetHiss(P.pos, 1, 2)
end
function Fountain:update(P, dt)
  self.time = self.time + dt * 3
  self:setSparkingDir(vec3(math.sin(self.time) * 0.1, 1, math.cos(self.time * 1.3) * 0.1), 0.1, 1)
  self:addLight(0.5)
  return self.time < 3
end

-- Explosion

Explosion = Piece:newType()
function Explosion:init(P)
  P.velocity = vec3()  
  self.size = self.size or 1
  self:setBurst(400 * self.size, 2, 0)
  self:setSmokingBurst(10 * self.size, 6, 9 * self.size)
  self:setSmokingSpeed(30 * self.size, 0.5)
  self:setSparkingSpread(0, 0.5, 0)
  self:setSparkingDir(vec3(), 1, 1)
  self:setSparkingSpeed(60 * self.size, 0)
  self:setTimeout(0)
  self:addLight(0.5)
  P.pushingForce = 10 * self.size
end
function Explosion:audio(P)
  audioSetExplosion(P.pos, self.size)
end

-- Long-lasting explosion

LastingExplosion = Piece:newType()
function LastingExplosion:init(P)
  P.velocity = vec3()  
  self.size = self.size or 1
  self.density = self.density or 1
  self:setBurst(400 * self.density * self.size, 5, self.ordered and 1 or 0)
  self:setSmokingBurst(10 * self.size, 9, 12 * self.size)
  self:setSmokingSpeed(30 * self.size, 0.5)
  self:setSparkingSpread(0, 0.5, 0)
  self:setSparkingDir(vec3(), 1, 1)
  self:setSparkingSpeed(60 * self.size, 0)
  self:setTimeout(0)
  self:addLight(1)
  P.pushingForce = 10 * self.size
end
function LastingExplosion:audio(P)
  audioSetExplosion(P.pos, self.size)
end

-- Fast explosion

FastExplosion = Piece:newType()
function FastExplosion:init(P)
  P.velocity = vec3()
  self.size = self.size or 1
  self:setBurst(400 * self.size, 0.8, 0)
  self:setSparkingSpread(0, 0.5, 0)
  self:setSparkingDir(vec3(), 1, 1)
  self:setSparkingSpeed(30 * self.size, 0.3)  
  self:setSmokingBurst(10 * self.size, 6, 9 * self.size)
  self:setSmokingSpeed(30 * self.size, 0.5)
  self:setTimeout(0)
  self:addLight(0.5)
  P.pushingForce = 5 * self.size
end
function FastExplosion:audio(P)
  audioSetExplosion(P.pos, self.size, 2)
end

-- Massive explosion

MassiveExplosion = Piece:newType()
function MassiveExplosion:init(P)
  P.velocity = vec3()
  self.size = self.size or 1
  self:setBurst(900 * self.size, 2.8, 0)
  self:setSparkingSpread(0, 0.5, 0)
  self:setSparkingDir(vec3(), 1, 1)
  self:setSparkingSpeed(60 * self.size, 0.5)  
  self:setSmokingBurst(10 * self.size, 6, 9 * self.size)
  self:setSmokingSpeed(30 * self.size, 0.5)
  self:setTimeout(0)
  self:addLight(0.5)
  P.pushingForce = 15 * self.size
end
function MassiveExplosion:audio(P)
  audioSetExplosion(P.pos, self.size * 1.5, 0.85)
end

-- Ordered explosion

OrderedExplosion = Piece:newType()
function OrderedExplosion:init(P)
  P.velocity = math.normalize(P.velocity) * 0.1
  self.size = self.size or 1
  self:setBurst(400 * self.size, 2, 1)
  self:setSmokingBurst(10 * self.size, 6, 9 * self.size)
  self:setSmokingSpeed(30 * self.size, 0.5)
  self:setSparkingSpread(0, 0.5, 0)
  self:setSparkingDir(vec3(), 1, 0.2)
  self:setSparkingSpeed(60 * self.size, 0)
  self:addLight(1)
  self:setTimeout(0)
  P.pushingForce = 10 * self.size
end
function OrderedExplosion:audio(P)
  audioSetExplosion(P.pos, self.size)
end

-- Massive spark for more complex explosions

MassiveSpark = Piece:newType()
function MassiveSpark:init(P)
  self.targetRadius = self.targetRadius or 7
  self.angleSpeed = self.angleSpeed or 10
  self:setSparking(0.2, 2.5)
  self:setSparkingSpread(0, 0.5, 0.5)
  self:setSparkingDir(-self.velocity, 0.2, 0.2)
  self:setSparkingSpeed(4, 0.5)  
  self:setTimeout(1.4 + 0.2 * math.random())
  self:setSmoking(1, 2)

  P.glowBrightness = 1
  P.glowSize = 0.5
  P.glowColor = rgb(0, 1, 1)
end
function MassiveSpark:audio(P)
  -- audioSetHiss(P.pos)
end
function MassiveSpark:update(P, dt)
  P.velocity.y = P.velocity.y - 10 * dt
  P.velocity:add(randomVec3():scale(dt * math.max(0, 100 - 100 * self.timeout)))
  self:setSparkingDir(-self.velocity, 0.2, 0.2)
  self:setSparkingSpeed(#P.velocity * 0.5, 0.5)  
  self:addLight(0.1, P.glowColor)
  self:addLight(1, self.color * 0.3)
  return Piece.update(self, P, dt)
end

-- Trailing spark from Hitman

TrailingSpark = Piece:newType()
function TrailingSpark:init(P)
  self.speed = self.speed or 20
  self.targetRadius = self.targetRadius or 7
  self.angleSpeed = self.angleSpeed or 10
  self:setSparking(1, 4)
  self:setSparkingSpread(0, 0.5, 0.5)
  self:setSparkingDir(-self.velocity, 0.2, 0.2)
  self:setSparkingSpeed(4, 0)  
  self:setTimeout(2.4 + 0.2 * math.random())
  self:setSmoking(2, 2, 4)

  P.glowBrightness = 1
  P.glowSize = 0.5
  P.glowColor = rgb(0, 1, 0)
end
function TrailingSpark:audio(P)
  -- audioSetHiss(P.pos)
end
function TrailingSpark:update(P, dt)
  P.velocity:add(randomVec3():scale(dt * 150))
  local speed = #P.velocity
  if speed > 20 then 
    P.velocity:scale(self.speed / speed)
  end
  self:setSparkingDir(-self.velocity, 0.0, 0.0)
  self:setSparkingSpeed(#P.velocity * 0.5, 0.1)  
  self:addLight(0.1, P.glowColor)
  self:addLight(1, self.color * 0.3)
  return Piece.update(self, P, dt)
end

-- Trailing spark from Hitman

ConeSpark = Piece:newType()
function ConeSpark:init(P)
  P.velocity = math.normalize(P.velocity) * (self.speed or 60)

  self.targetRadius = self.targetRadius or 7
  self.angleSpeed = self.angleSpeed or 10
  self:setSparking(2, 1.5)
  self:setSparkingSpread(0, 0.5, 0.5)
  self:setTimeout(2.4 + 0.2 * math.random())
  self:setSmoking(1, 1)
end
function ConeSpark:audio(P)
  -- audioSetHiss(P.pos)
end
function ConeSpark:update(P, dt)
  P.velocity.y = P.velocity.y - 5 * dt
  P.velocity:set(math.applyLag(P.velocity, vec3(), 0.98, dt))
  self:setSparkingDir(-math.normalize(P.velocity), 1, 1)
  self:setSparkingSpeed(#P.velocity * 0.5, 0.5)  
  self:addLight(0.5, self.color * 0.5)
  return Piece.update(self, P, dt)
end

-- Random spark

function RandomSpark()
  local r = math.random()
  return r > 0.67 and MassiveSpark
    or r > 0.33 and TrailingSpark
    or ConeSpark
end

-- Spiral

Spiral = Piece:newType()
function Spiral:init(P)
  self.targetRadius = self.targetRadius or 7
  self.angleSpeed = self.angleSpeed or 10
  self:setSparking(10, 0.5)
  self:setSparkingSpread(0.5, 0.5, 0.5)
  self:setSparkingDir(vec3(), 0.2, 0.2)
  self:setSparkingSpeed(40, 0.5)  
  self:setTimeout(5 + math.random())
  self.angle = 0
  self.radius = 0.1
  self.randomXZ = vec3(math.random() - 0.5, 0, math.random() - 0.5):normalize()
  self.randomXZSpeed = vec3(math.random() - 0.5, 0, math.random() - 0.5) * 10
  self:setSmoking(1, 2, 5)
  self:setSmokingColor(1)
end
function Spiral:audio(P)
  audioSetHiss(P.pos, 2, 3)
end
function Spiral:update(P, dt)
  local newPos = self.pos 
    + math.sin(self.angle) * self.radius * vec3(0, 1, 0)
    + math.cos(self.angle) * self.radius * self.randomXZ
  self.randomXZ = self.randomXZ + self.randomXZSpeed * dt
  self.randomXZSpeed.x = self.randomXZSpeed.x + (math.random() - 0.5)
  self.randomXZSpeed.z = self.randomXZSpeed.z + (math.random() - 0.5)
  self.randomXZ:normalize()
  local deltaPos = newPos - P.pos
  P.pos = newPos
  P.velocity = deltaPos / math.max(dt, 0.01)
  self.angle = self.angle + dt * self.angleSpeed
  self.radius = math.applyLag(self.radius, self.targetRadius, 0.97, dt)
  deltaPos = -deltaPos:normalize()
  self:setSparkingDir(deltaPos, 0.2, 0.2)
  self:setSmokingVelocity(deltaPos * 20)
  P.sparkingIntensity = 10 * math.saturate(self.timeout * 5)
  self:addLight(0.03)
  return Piece.update(self, P, dt)
end

-- Twirl

Twirl = Piece:newType()
function Twirl:init(P)
  P.velocity = math.normalize(P.velocity + vec3(0, 1, 0)) * 0.1
  self.targetRadius = self.targetRadius or 7
  self.angleSpeed = self.angleSpeed or 10
  self:setSparking(10, 0.5)
  self:setSparkingSpread(0.5, 0.5, 0.5)
  self:setSparkingDir(vec3(), 0.2, 0.2)
  self:setSparkingSpeed(40, 0.5)  
  self:setTimeout(5 + math.random())
  self.angle = 0
  self.radius = 0.1
  self:setSmoking(1, 1)
  self:setSmokingColor(1)
end
function Twirl:audio(P)
  audioSetHiss(P.pos, 2, 3)
end
function Twirl:update(P, dt)
  local sideA = self.sideA or math.normalize(math.cross(P.velocity, vec3(0, 0, 1)))
  local sideB = self.sideB or math.normalize(math.cross(P.velocity, sideA))
  self.sideAPrev = sideA
  self.sideBPrev = sideB
  P.velocity = math.normalize(P.velocity + randomVec3() * dt * 0.5) * 0.1

  self.angle = self.angle + dt * self.angleSpeed
  self.radius = math.applyLag(self.radius, self.targetRadius, 0.97, dt)

  local deltaPos = sideA * math.sin(self.angle) + sideB * math.cos(self.angle)
  self:setSparkingDir(deltaPos, 0.2, 0.2)
  self:setSmokingVelocity(deltaPos * 40)
  P.sparkingIntensity = 10 * math.saturate(self.timeout * 5)
  self:addLight(0.03)
  return Piece.update(self, P, dt)
end

-- Double twirl

DoubleTwirl = Group:newType()
function DoubleTwirl:init(P, o)
  local c = ColorSame(self.color)
  P[1] = Twirl:new(o, { color = c })
  P[2] = Twirl:new(o, { color = c })
end
function DoubleTwirl:update(P, dt)
  P[2].sideA = -P[1].sideAPrev
  P[2].sideB = -P[1].sideBPrev
  return Group.update(self, P, dt)
end

function RandomContinuousEffect()
  local r = math.random()
  if r > 0.67 then return DoubleTwirl end
  if r > 0.33 then return Twirl end
  return Spiral
end