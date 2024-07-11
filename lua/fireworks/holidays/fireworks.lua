require 'utils'
require 'fireworks_base'
require 'fireworks_spawn'
require 'fireworks_colors'
require 'fireworks_audio'
require 'fireworks_types'
require 'fireworks_pyro'

local pyros = {}
for i = 1, ac.getFireworksSpotCount() do
  pyros[#pyros + 1] = Pyro:new{ pos = ac.getFireworksSpot(i - 1), sourceIndex = i - 1 }
end
local pyrosSize = #pyros

local customPyros = {}
ac.onSharedEvent('csp.fireworksCustomEmit', function (data, senderName) 
  if type(data) == 'table' then
    local u = senderName..'/'..(data.key or '')
    if vec3.isvec3(data.pos) then
      if customPyros[u] then
        customPyros[u].pos = data.pos
      else
        pyros[#pyros + 1] = Pyro:new{ pos = data.pos, sourceIndex = #pyros }
        customPyros[u] = pyros[#pyros]
        pyrosSize = pyrosSize + 1
      end
      customPyros[u].intensityOverride = data.intensity
      customPyros[u].holidayTypeOverride = data.holidayType
    elseif customPyros[u] then
      table.removeItem(pyros, customPyros[u])
      customPyros[u] = nil
      pyrosSize = pyrosSize - 1
    end
  end
end, true)

function script.update(dt, intensity, holidayType)
  audioPoolPrepare(dt)
  
  local piecesSize = #piecesList
  for i = piecesSize, 1, -1 do
    if not piecesList[i]:updateBase(dt) then
      table.remove(piecesList, i)
    end
  end

  local allowToSpawnBase = piecesSize < 150
  local allowToSpawn = intensity > 0 and allowToSpawnBase
  for i = 1, pyrosSize do
    local p = pyros[i]
    if p.intensityOverride then
      p:update(dt, allowToSpawnBase, p.intensityOverride, p.holidayTypeOverride)
    else
      p:update(dt, allowToSpawn, intensity, holidayType)
    end
  end

  if holidayType == ac.HolidayType.Halloween then
    intensity = math.min(intensity, 0.05)
  end

  -- ac.debug('items', piecesSize)
  -- ac.debug('holiday', holidayType)
  -- ac.debug('intensity', intensity)
  -- runGC()
end
