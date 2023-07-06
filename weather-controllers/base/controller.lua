--------
-- Basic controller for static weather, uses selected weather ID to get weather type.
--------

local weatherUtils = require('shared/sim/weather')
local weatherType = ac.getInputWeatherType()    -- if weather doesn’t have type set, value will be guessed based on weather ID
local temperatures = ac.getInputTemperatures()  -- { ambient = 23, road = 15 }
local windParams = ac.getInputWind()            -- { direction = 300, speedFrom = 10, speedTo = 15 }
local trackState = ac.getInputTrackState()      -- { sessionStart = 95, sessionTransfer = 90, randomness = 2, lapGain = 132 }
local startingDate = ac.getInputDate()          -- seconds from 1970 etc.

local result = ac.ConditionsSet()
result.currentType = weatherType
result.upcomingType = weatherType
result.transition = 0.0
result.variableA = 0.0
result.variableB = 0.0
result.variableC = 0.0
result.temperatures = temperatures
result.wind = windParams
result.humidity = ac.getInputHumidity()
result.pressure = ac.getInputPressure()
result.trackState = trackState
weatherUtils.setRainIntensity(result, true)
ac.setConditionsSet2(result)

local overrideSet = false
function script.update(dt)
  if weatherUtils.debugAware(result) then
    ac.setConditionsSet2(result)
    overrideSet = true
  elseif overrideSet then
    overrideSet = false
    result.currentType = weatherType
    result.upcomingType = weatherType
    ac.setConditionsSet2(result)
  end
end
