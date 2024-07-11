--------
-- Basic controller for static weather, uses selected weather ID to get weather type.
--------

local weatherUtils = require('shared/sim/weather')
local humidityPresent = refbool(false)
local pressurePresent = refbool(false)
local fakeHumidityOrPressure = false

local function getInputConditions()
  -- if weather doesn’t have type set, value will be guessed based on weather ID
  local weatherType = ac.getInputWeatherType()
  local result = ac.ConditionsSet()
  result.currentType = weatherType
  result.upcomingType = weatherType
  result.transition = 0.0
  result.variableA = 0.0
  result.variableB = 0.0
  result.variableC = 0.0
  result.temperatures = ac.getInputTemperatures()
  result.wind = ac.getInputWind()
  result.humidity = ac.getInputHumidity(humidityPresent)
  result.pressure = ac.getInputPressure(pressurePresent)
  result.trackState = ac.getInputTrackState()
  weatherUtils.setRainIntensity(result, true)
  -- fakeHumidityOrPressure = not humidityPresent.value or not pressurePresent.value
  fakeHumidityOrPressure = false
  return result
end

local conditions = getInputConditions()
ac.setConditionsSet2(conditions)

local overrideSet = false
local sim = ac.getSim()
function script.update(dt)
  if weatherUtils.debugAware(conditions, 1) then
    ac.setConditionsSet2(conditions)
    overrideSet = true
  elseif overrideSet then
    overrideSet = false
    conditions = getInputConditions()
    ac.setConditionsSet2(conditions)
  elseif fakeHumidityOrPressure then
    local altState0 = math.perlin(sim.timestamp / 3.12e5, 3)
    local altState1 = math.perlin(sim.timestamp / 3.17e5, 3)
    if not humidityPresent.value then
      conditions.humidity = math.saturateN(0.5 + 0.4 * altState0)
    end
    if not pressurePresent.value then
      conditions.pressure = 101325 + 1e3 * altState1
    end
    ac.setConditionsSet2(conditions)
  end
end
