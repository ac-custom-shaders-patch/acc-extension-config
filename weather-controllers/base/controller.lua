--------
-- Basic controller for static weather, uses selected weather ID to get weather type.
--------

local function buildRainIntensityMap()
  local ret = {}
  ret[ac.WeatherType.Clear] =             0
  ret[ac.WeatherType.FewClouds] =         0
  ret[ac.WeatherType.ScatteredClouds] =   0
  ret[ac.WeatherType.BrokenClouds] =      0
  ret[ac.WeatherType.OvercastClouds] =    0
  ret[ac.WeatherType.Windy] =             0
  ret[ac.WeatherType.Fog] =               0
  ret[ac.WeatherType.Mist] =              0
  ret[ac.WeatherType.Haze] =              0
  ret[ac.WeatherType.Dust] =              0
  ret[ac.WeatherType.Smoke] =             0
  ret[ac.WeatherType.Sand] =              0
  ret[ac.WeatherType.LightDrizzle] =      0.1
  ret[ac.WeatherType.Drizzle] =           0.2
  ret[ac.WeatherType.HeavyDrizzle] =      0.3
  ret[ac.WeatherType.LightRain] =         0.4
  ret[ac.WeatherType.Rain] =              0.5
  ret[ac.WeatherType.HeavyRain] =         0.6
  ret[ac.WeatherType.LightThunderstorm] = 0.7
  ret[ac.WeatherType.Thunderstorm] =      0.8
  ret[ac.WeatherType.HeavyThunderstorm] = 0.9
  ret[ac.WeatherType.Squalls] =           0
  ret[ac.WeatherType.Tornado] =           1.0
  ret[ac.WeatherType.Hurricane] =         1.0
  ret[ac.WeatherType.LightSnow] =         0
  ret[ac.WeatherType.Snow] =              0
  ret[ac.WeatherType.HeavySnow] =         0
  ret[ac.WeatherType.LightSleet] =        0
  ret[ac.WeatherType.Sleet] =             0.1
  ret[ac.WeatherType.HeavySleet] =        0.2
  ret[ac.WeatherType.Hail] =              0.3
  return ret
end

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
result.trackState = trackState

result.rainIntensity = buildRainIntensityMap()[weatherType] or 0
result.rainWetness = result.rainIntensity > 0 and 1 or 0
result.rainWater = result.rainIntensity

ac.setConditionsSet(result)

function script.update(dt)
  -- ac.setConditionsSet(result)
end