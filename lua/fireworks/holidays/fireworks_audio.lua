Audio = {}

function Audio:new(p1)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  fillProps(o, p1)
  o.event = nil
  o.timeout = 0.0
  o.delay = -1.0
  return o
end

function Audio:set(pos, event, timeout, distanceToCamera, volumeMult)
  if self.timeout > 0 
      -- and (self.delay < 0 or distanceToCamera < self.nextDistance) 
      then 
    return 
  end
  
  if self.event == nil then
    self.event = ac.AudioEvent(event, true)
    self.event.cameraInteriorMultiplier = 1
    self.event.cameraExteriorMultiplier = 1
    self.event.cameraTrackMultiplier = 1
  end

  -- self.delay = math.min(1, distanceToCamera / 343)
  self.delay = 0.001
  self.nextDistance = distanceToCamera
  self.event.volume = volumeMult * math.pow(1 - math.saturate(distanceToCamera / 800), 2)
  self.nextPos = pos
  self.timeout = timeout + self.delay
end

function Audio:update(dt)
  self.timeout = self.timeout - dt
  if self.progress ~= nil and self.progress < 1 then
    self.progress = self.progress + dt / 0.5
    self.event:setParam('time', math.saturate(self.progress))
  end
  if self.delay > 0 then
    self.delay = self.delay - dt
    if self.delay <= 0 then
      if self.customTimeMode then
        if not self.event:isPlaying() then
          self.event:start()
        end
        self.event:setParam('time', 0)
        self.progress = 0
      else
        self.event:stop()
        self.event:start()
      end
      self.event:setPosition(self.nextPos)
    end
  end
end

ac.loadSoundbank('extra_fireworks.bank')

function AudioPool(audioPoolSize, event, timeout, customTimeMode)
  local audioPool = {}
  for i = 1, audioPoolSize do 
    audioPool[#audioPool + 1] = Audio:new{ 
      customTimeMode = customTimeMode or false,
      duration = timeout
    } 
  end
  local audioNext = 1

  return {
    prepare = function (dt)
      audioNext = 1
      for i = 1, audioPoolSize do
        audioPool[i]:update(dt)
      end
    end,
    run = function (pos, distanceToCamera, volumeMult)
      if audioNext > audioPoolSize then
        return nil
      end
      audioNext = audioNext + 1
      audioPool[audioNext - 1]:set(pos, event, timeout, distanceToCamera, volumeMult)
    end
  }
end

local poolExplosions = nil
local poolHiss = nil

function audioPoolPrepare(dt)
  if poolExplosions ~= nil then poolExplosions.prepare(dt) end
  if poolHiss ~= nil then poolHiss.prepare(dt) end
end

function audioSetExplosion(pos, volumeMult)
  local distanceToCamera = #(ac.getCameraPosition() - pos)
  if distanceToCamera > 800 then return end
  if poolExplosions == nil then
    poolExplosions = AudioPool(6, '/extra_fireworks/firework', 0.1, true)
  end
  poolExplosions.run(pos, distanceToCamera, (volumeMult or 1) * 0.5)
end

function audioSetHiss(pos, volumeMult)
  local distanceToCamera = #(ac.getCameraPosition() - pos)
  if distanceToCamera > 400 then return end
  if poolHiss == nil then
    poolHiss = AudioPool(4, '/extra_fireworks/hiss', 4)
  end
  poolHiss.run(pos, distanceToCamera, (volumeMult or 1) * 0.3)
end