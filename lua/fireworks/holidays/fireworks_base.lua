piecesList = {}
currentSource = { pos = vec3(), index = nil }

-- Group: groups pieces or groups together

Group = {
  destroyed = false,
  spawnAllAtOnce = false,
  delay = 0,
  timeout = 0,
  velocity = vec3(),
  items = {}
}

function Group:new(p1, p2)
  if #piecesList > 1000 then error('Too much') end
  o = {}
  setmetatable(o, self)
  self.__index = self
  fillProps(o, p1)
  fillProps(o, p2)
  o.items = {}
  o.chained = {}
  o.pos = (o.pos and o.pos or currentSource.pos) + (o.offset or vec3())
  o.velocity = o.velocity:clone()
  o.sourceIndex = currentSource.index
  self.initBase(o)
  return o
end

function Group:inheritChain(chained)
  if chained ~= nil then
    for i = 2, #chained do
      o.chained[#o.chained + 1] = chained[i]
    end
  end
end

function Group:chain(o, chained)
  Piece.chain(self, o, chained)
end

function Group:newType()
  self.__index = self
  return setmetatable({ parentClass = self }, self)
end

function Group:initBase()
  piecesList[#piecesList + 1] = self
  self:init(self.items, { pos = self.pos, velocity = self.velocity, child = true })
end

function Group:init(P, o)
end

function Group:spawn(P)
  currentSource.index = self.sourceIndex
  if spawnAllAtOnce then
    for i = 1, #self.chained do
      self.chained[i](self, P, {})
    end
  else
    if #self.chained > 0 then
      self.chained[1](self, P, self.chained)
    end
  end
end

function Group:destroy()
  self.destroyed = true
  for k, v in pairs(self.items) do
    v:destroy()
  end
end

function Group:updateBase(dt)
  if self.destroyed then
    return false
  end

  if self.delay > 0 then
    self.delay = self.delay - dt
  else
    local anyWorking = false
    local runs = 0
    for k, v in pairs(self.items) do
      anyWorking = v:updateBase(dt) or anyWorking
      runs = runs + 1
    end
  
    if not anyWorking or not self:update(self.items, dt) then
      self:spawn(self.ptr)
      self:destroy()
    end
  end

  return true
end

function Group:update(P, dt)
  if self.timeout ~= nil and self.timeout > 0 then
    self.timeout = self.timeout - dt
    return true
  end
  return self.timeout >= 0
end

function Group:setTimeout(timeout)
  self.timeout = timeout == 0 and 0.00001 or timeout
end

-- Piece: directly linked to a certain emitter

Piece = { 
  ptr = nil, 
  destroyed = false,
  spawnAllAtOnce = false,
  ptrAdded = false,
  delay = 0,
  timeout = 0,
  velocity = vec3() 
}

function Piece:new(p1, p2)
  if #piecesList > 1000 then error('Too much') end
  o = {}
  setmetatable(o, self)
  self.__index = self
  fillProps(o, p1)
  fillProps(o, p2)
  o.chained = {}
  o.pos = (o.pos and o.pos or currentSource.pos) + (o.offset or vec3())
  o.velocity = o.velocity:clone()
  o.sourceIndex = currentSource.index
  self.initBase(o)
  return o
end

function Piece:inheritChain(chained)
  if chained ~= nil then
    for i = 2, #chained do
      o.chained[#o.chained + 1] = chained[i]
    end
  end
end

function Piece:chain(arg, spawnFunc, params)
  if type(arg) == 'table' then
    local typeToCreate = arg
    if type(spawnFunc) ~= 'function' then
      params = spawnFunc
      spawnFunc = nil
    end
    if spawnFunc == nil then
      spawnFunc = function (s, o, P, cb)
        cb{ pos = P.pos, velocity = P.velocity }
      end
    end
    arg = function(o, P, chained) 
      if params == nil then params = {} end
      spawnFunc(o, params, P, function (p)
        typeToCreate:new(p, params):inheritChain(chained)
      end)
    end
  end
  self.chained[#self.chained + 1] = arg
  return self
end

function Piece:newType()
  self.__index = self
  return setmetatable({ parentClass = self }, self)
end

function Piece:initBase()
  self.ptr = ac.Firework()
  self.ptr.pos = self.pos
  self.ptr.velocity = self.velocity
  if not self.child then
    piecesList[#piecesList + 1] = self
  end
  self:setSmokingColor()
  self:setColor()
  self:init(self.ptr)
end

function Piece:init(P)
  P.sparkingIntensity = 10
  P.sparkingLifespan = 1
  P.sparkingSize = 1
  P.sparkingStretch = 1
  P.sparkingSpeedMin = 1
  P.sparkingSpeedMax = 10
  P.sparkingDir = vec3(0, 1, 0)
  P.sparkingDirSpreadXZ = 10
  P.sparkingDirSpreadY = 1
  P.sparkingColorA = rgb(1, 0, 0)
  P.sparkingColorB = rgb(1, 1, 0)
end

function Piece:spawn(P)
  currentSource.index = self.sourceIndex
  if spawnAllAtOnce then
    for i = 1, #self.chained do
      self.chained[i](self, P, {})
    end
  else
    if #self.chained > 0 then
      self.chained[1](self, P, self.chained)
    end
  end
end

function Piece:destroy()
  self.destroyed = true
  ac.fireworks:erase(self.ptr) 
end

function Piece:updateBase(dt)
  if self.destroyed then
    return false
  end

  if self.delay > 0 then
    self.delay = self.delay - dt
  else
    if not self.audioSet then
      self.audioSet = true
      self:audio(self.ptr)
    end

    if self.nextLightColor ~= nil then
      ac.addFireworkFlash(self.sourceIndex, self.nextLightPos, self.nextLightColor, self.nextLightDuration)
      self.nextLightColor = nil
    end

    if not self.ptrAdded then 
      ac.fireworks:pushWhereFits(self.ptr)
      self.ptrAdded = true
    end
  
    if self.timeout ~= 0.00001 then
      self.ptr.pushingForce = 0
    end
    if not self:update(self.ptr, dt) then
      self:spawn(self.ptr)
      self:destroy()
    end
  end

  return true
end

function Piece:update(P, dt)
  P.pos:add(P.velocity * dt)
  if self.timeout ~= nil and self.timeout > 0 then
    self.timeout = self.timeout - dt
    return true
  end
  return self.timeout >= 0
end

function Piece:setColor()
  local colorA, colorB = GetColors(self.color)
  self.color = (colorA + colorB) / 2
  self.colorA = colorA
  self.colorB = colorB
  self:setSparkingColor(colorA, colorB)
end

function Piece:addLight(duration, color, pos)
  if self.sourceIndex == nil then return end
  
  color = color or self.color
  duration = duration or 0.03

  local chance = math.min(duration, 0.95)
  if not self.lightAdded then
    self.lightAdded = true
  elseif chance > math.random() then 
    return 
  end

  color = color / 3
  pos = pos or self.ptr.pos

  if not self.ptrAdded then
    self.nextLightColor = color
    self.nextLightPos = pos
    self.nextLightDuration = duration
  else
    ac.addFireworkFlash(self.sourceIndex, pos, color, duration)
  end
end

function Piece:setTimeout(timeout)
  self.timeout = timeout == 0 and 0.00001 or timeout
end

function Piece:audio(P)
end

function Piece:setSparking(intensity, lifespan)
  self.ptr.sparkingIntensity = intensity
  self.ptr.sparkingLifespan = lifespan
  self.ptr.sparkingSpreadFlags = 0
end

function Piece:setSmoking(intensity, lifespan, size)
  self.ptr.smokingIntensity = intensity or 1
  self.ptr.smokingLifespan = lifespan or 1
  self.ptr.smokingSize = size or 3
end

function Piece:setSmokingColor(opacity, color)
  self.ptr.smokingOpacity = opacity or 0.5
  self.ptr.smokingColor = rgb(0.1, 0.1, 0.1)
end

function Piece:setBurst(count, lifespan, mode)
  self.ptr.sparkingIntensityShot = count
  self.ptr.sparkingLifespan = lifespan or 2
  self.ptr.sparkingSpreadFlags = mode or 0
end

function Piece:setSmokingBurst(count, lifespan, size)
  self.ptr.smokingIntensityShot = count or 10
  self.ptr.smokingLifespan = lifespan or 6
  self.ptr.smokingSize = size or 6
end

function Piece:setSmokingSpeed(speed, speedSpread)
  self.ptr.smokingSpeedRandomMin = speed * (1 - speedSpread)
  self.ptr.smokingSpeedRandomMax = speed * (1 + speedSpread)
end

function Piece:setSparkingSpread(posSpread, lifespanSpread, sizeSpread)
  self.ptr.sparkingPosSpread = posSpread
  self.ptr.sparkingLifespanSpread = lifespanSpread
  self.ptr.sparkingSizeSpread = sizeSpread
end

function Piece:setSmokingSpread(posSpread)
  self.ptr.smokingPosSpread = 0
end

function Piece:setSparkingDir(dir, spreadXZ, spreadY)
  self.ptr.sparkingDir = dir
  self.ptr.sparkingDirSpreadXZ = spreadXZ
  self.ptr.sparkingDirSpreadY = spreadY
end

function Piece:setSmokingVelocity(vel)
  self.ptr.smokingVelocityOffset = vel
end

function Piece:setSparkingSpeed(speed, speedSpread)
  self.ptr.sparkingSpeedMin = speed * (1 - speedSpread)
  self.ptr.sparkingSpeedMax = speed * (1 + speedSpread)
end

function Piece:setSparkingColor(colorA, colorB, size)
  self.ptr.sparkingColorA = colorA
  self.ptr.sparkingColorB = colorB or colorA
  self.ptr.sparkingSize = size or 0.1
end