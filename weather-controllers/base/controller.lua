--------
-- Basic controller, uses selected weather ID to get weather type.
--------

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
ac.setConditionsSet(result)

function update(dt)
end