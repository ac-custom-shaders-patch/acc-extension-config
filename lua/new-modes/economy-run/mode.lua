-- Just a simplest example of a possible event, not really functional since in AC
-- it seems that fuel isn’t spent without pressed throttle, so you can just idle
-- forever.

-- This one in particular would need for scripts to be able to control the scene. But
-- first, there needs to be a system to ensure it couldn’t be used for cheating of any
-- kind. Still planning that one.

-- Event configuration:
local startingFuel = 1

-- Event doesn’t start right away, instead, here’s a message to show before the start:
ac.setStartMessage('Go to pits and set fuel to 1 liter')

-- This function is called before event activates. Once it returns true, it’ll run:
function prepare(dt)
  local state = ac.getCarState(1)
  return state.fuel > startingFuel - 0.01 and state.fuel <= startingFuel and state.speedKmh < 10
end

-- Event state:
local metersDriven = 0
local startingFuel = 0

function calculateScore()
  local state = ac.getCarState(1)
  local litersSpent = startingFuel - state.fuel
  if litersSpent < 0.01 or metersDriven < 0.01 then
    return '--.- MPG (--.- L/100km)'
  end
  local scoreMpg = (metersDriven / 1609) / (litersSpent / 3.785) 
  local scoreL100k = litersSpent / (metersDriven / 100e3)
  return (math.ceil(scoreMpg * 10)/10)..' MPG ('..(math.ceil(scoreL100k * 10)/10)..' L/100km)'
end

function update(dt)
  local state = ac.getCarState(1)

  if metersDriven == 0 then
    ac.setSystemMessage('Economy Run', 'Drive as far from here as possible')
    startingFuel = state.fuel
  end

  metersDriven = metersDriven + state.speedKmh * dt / 3.6

  if state.engineLifeLeft < 1 then
    ac.endSession('You broke the car', false)
  elseif state.fuel < 0.01 and state.speedKmh < 10 then
    ac.endSession('Economy score: '..calculateScore())
  end
end


local speedWarning = 0
function drawUI()
  local uiState = ac.getUiState()

  ui.beginTransparentWindow('economyScore', vec2(uiState.windowSize.x * 0.5 - 100, 100), vec2(300, 400))
  ui.beginOutline()
  ui.pushFont(ui.Font.Main)
  ui.text('Economy score:')
  ui.popFont()
  ui.pushFont(ui.Font.Title)
  ui.text(calculateScore())
  ui.popFont()
  ui.endOutline(rgbm(0, 0, 0, 0.3))
  ui.endTransparentWindow()
end