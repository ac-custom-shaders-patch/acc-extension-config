require 'fireworks_schemes'

Pyro = {
  pos = vec3()
}

function Pyro:new(p1)
  o = {}
  setmetatable(o, self)
  self.__index = self
  fillProps(o, p1)
  o.spawnDelay = math.random()
  o.firstUpdate = false
  return o
end

function Pyro:spawnNext(intensity, holidayType)
  if self.scheme == nil then
    local list = PyroSchemes[holidayType] or PyroSchemes[ac.HolidayType.None]
    self.scheme = coroutine.create(PyroSchemesDev or list[1 + math.floor(#list * math.random())])
  end

  local ran, timeout = coroutine.resume(self.scheme)
  if not ran or type(timeout) == 'string' then 
    self.scheme = nil
    return
  end

  self.spawnDelay = math.max(0.1, timeout or self.spawnDelay)
  if coroutine.status(self.scheme) == 'dead' then
    self.scheme = nil
    if math.random() > intensity * 1.01 then
      self.spawnDelay = self.spawnDelay + (10 + math.random() * 20 + math.pow(math.random(), 4) * 60) * (1 - intensity)
    end
  end
end

function Pyro:update(dt, allowToSpawn, intensity, holidayType)
  if self.spawnDelay > 0 then 
    self.spawnDelay = self.spawnDelay - dt
    return
  end

  if self.firstUpdate then
    self.firstUpdate = false
    self.spawnDelay = (10 + math.random() * 20 + math.pow(math.random(), 4) * 60) * (1 - intensity)
  end

  self.spawnDelay = 0.3
  if not allowToSpawn then
    return
  end

  local posC = self.pos - ac.getCameraPosition()
  local distanceToCamera = #posC
  local pyroInFront = math.dot(posC / distanceToCamera, -ac.getCameraDirection())
  if distanceToCamera < 50 or distanceToCamera > 1000 + 500 * pyroInFront then
    self.spawnDelay = 1
    return
  end

  currentSource.pos = self.pos
  currentSource.index = self.sourceIndex
  self:spawnNext(intensity, holidayType)
end
