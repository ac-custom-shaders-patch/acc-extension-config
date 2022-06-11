-- Tried to recreate that old mission: https://www.youtube.com/watch?v=XFXc_37BafI, thanks to
-- starblind94 for creating a track for it: https://www.racedepartment.com/downloads/driver-the-interview.38965/.
-- Also works with: https://assettocorsamods.net/resources/the-parking-interview.58/.
-- As for car, you can, for example, google for “buick gsx assetto corsa”. And you can even try it in original
-- game too now: https://www.retrogames.cc/psx-games/driver-you-are-the-wheelman.html.

-- Here’s a dark blue skin if needed: https://files.acstuff.ru/shared/OCEs/driver-0-20210509-162556.zip

-- All the tasks seem to work here, definitely passable with that Buick, not sure about other cars. But I’m not 
-- sure if it can all be done in a minute though.

-- Helper functions:
local function createSlalomPaths(columnRows, targetRadius)
  local function createPath(row, flipSide, flipDirection)
    local function pointAt(index)
      return row[flipDirection and #row - (index - 1) or index]
    end
    local dir = (row[#row] - row[1]):normalize() * (flipDirection and -1 or 1)
    local side = vec3.cross(vec3(0, 1, 0), dir):normalize() * (flipSide and -1 or 1)
    local path = {}
    path[#path + 1] = pointAt(1) - dir * targetRadius
    for j = 1, #row do
      path[#path + 1] = pointAt(j) + side * targetRadius
      side = -side
    end
    path[#path + 1] = pointAt(#row) + dir * targetRadius
    for j = #row, 1, -1 do
      path[#path + 1] = pointAt(j) + side * targetRadius
      side = -side
    end
    path[#path + 1] = pointAt(1) - dir * targetRadius
    return path
  end
  local ret = {}
  for i = 1, #columnRows do
    ret[#ret + 1] = createPath(columnRows[i], false, false)
    ret[#ret + 1] = createPath(columnRows[i], true, false)
    ret[#ret + 1] = createPath(columnRows[i], false, true)
    ret[#ret + 1] = createPath(columnRows[i], true, true)
  end
  return ret
end

-- Tasks to complete:
local tasks = {
  { 
    name = 'Burnout', 
    test = function(self, car, dt) 
      if car.wheels[2].angularSpeed > 60 and car.wheels[3].angularSpeed > 60 
        and car.wheels[0].angularSpeed < 10 and car.wheels[1].angularSpeed < 10
        and math.abs(car.localAngularVelocity.y) < 0.5 then
        self.counter = self.counter + dt
        if self.counter > 1 then
          return true
        end
      else
        self.counter = 0
      end
      return false
    end,
    cross = vec2(45, 170),
    counter = 0
  },
  { 
    name = 'Handbrake', 
    test = function(self, car) return math.abs(math.dot(car.velocity, car.side)) > 5 and car.handbrake > 0.8 and car.gear > 0 end,
    cross = vec2(40, 200)
  },
  { 
    name = 'Slalom', 
    test = function(self, car) 
      for i = 1, #self.paths do
        local path = self.paths[i]
        local nextPoint = 0
        for j = 1, #path do
          ac.debug('Slalom: path #'..i..', p'..j..', state', path[j])
          if path[j] ~= true then
            if car.pos:closerToThan(path[j], self.triggerRadius) then
              path[j] = true
            end
            nextPoint = j
            break
          end
        end
        ac.debug('Slalom: path #'..i..', next point', nextPoint)
        if nextPoint == 0 then 
          return true
        end
      end
      return false
    end,
    cross = vec2(65, 140),
    triggerRadius = ac.getTrackID() == 'driver' and 8 or 12,
    paths = ac.getTrackID() == 'driver' 
      and createSlalomPaths({
        { vec3(-15.5, 0, 22.25), vec3(-15.5, 0, 7.75), vec3(-15.5, 0, -7.25), vec3(-15.5, 0, -22.25) },
        { vec3(15.5, 0, 22.25), vec3(15.5, 0, 7.75), vec3(15.5, 0, -7.25), vec3(15.5, 0, -22.25) }
      }, 8) 
      or createSlalomPaths({
        { vec3(32.2, 5.07, 20.8), vec3(10.7, 5.15, 20.8), vec3(-10.7, 5.13, 20.8), vec3(-32.2, 5.12, 20.8) },
        { vec3(32.2, 5.07, -20.8), vec3(10.7, 5.15, -20.8), vec3(-10.7, 5.13, -20.8), vec3(-32.2, 5.12, -20.8) }
      }, 10)
  },
  { 
    name = '180', 
    test = function(self, car, dt) 
      if self.failedCooldown > 0 then
        self.failedCooldown = self.failedCooldown - dt
        return false
      end
      if self.firstPhaseComplete ~= nil then
        local dot = math.dot(car.look, self.firstPhaseComplete)
        local relativeSpeed = math.dot(car.velocity, self.firstPhaseComplete) * 3.6
        if dot > 0.5 and relativeSpeed > 10 and math.abs(car.localAngularVelocity.y) < 0.5 then
          return true
        elseif dot < 0 or relativeSpeed < -20 or car.gear == 0 then
          self.firstPhaseComplete = nil
          self.directions = {}
          self.directionsCursor = 1
          self.failedCooldown = 3
        end
        ac.debug('180: first phase dot', dot)
        ac.debug('180: first phase relative speed', relativeSpeed)
      else 
        if self.directionsDelay > 0 then
          self.directionsDelay = self.directionsDelay - dt
        else
          self.directions[self.directionsCursor] = car.look:clone()
          self.directionsCursor = self.directionsCursor + 1
          if self.directionsCursor > 10 then self.directionsCursor = 1 end
          self.directionsDelay = 0.2
        end
        local minDir = 1
        for i = 1, #self.directions do
          minDir = math.min(minDir, math.dot(car.look, self.directions[i]))
        end
        if minDir < -0.9 then
          self.firstPhaseComplete = car.look:clone()
        end
        ac.debug('180: biggest turn', minDir)
      end
      ac.debug('180: first phase ready', self.firstPhaseComplete ~= nil)
      return false
    end,
    cross = vec2(55, 125),
    directions = {},
    directionsCursor = 1,
    directionsDelay = 0,
    firstPhaseComplete = nil,
    failedCooldown = 0
  },
  { 
    name = '360', 
    test = function(self, car, dt) 
      if self.firstPhaseReadyFor > 0 then
        self.firstPhaseReadyFor = self.firstPhaseReadyFor - dt
      end
      if self.directionsDelay > 0 then
        self.directionsDelay = self.directionsDelay - dt
      else
        self.directions[self.directionsCursor] = car.look:clone()
        self.directionsCursor = self.directionsCursor + 1
        if self.directionsCursor > 10 then self.directionsCursor = 1 end
        self.directionsDelay = 0.2
      end
      local minDir = 1
      for i = 1, #self.directions do
        minDir = math.min(minDir, math.dot(car.look, self.directions[i]))
      end
      if minDir < -0.9 then
        if self.firstPhaseReadyFor > 0 then
          return true
        end
        self.firstPhaseReadyFor = 3
        self.directions = {}
        self.directionsCursor = 1
      end
      ac.debug('360: biggest turn', minDir)
      ac.debug('360: first phase ready for', self.firstPhaseReadyFor)
      return false
    end,
    cross = vec2(50, 120),
    directions = {},
    directionsCursor = 1,
    directionsDelay = 0,
    firstPhaseReadyFor = 0
  },
  { 
    name = 'Reverse 180', 
    test = function(self, car, dt) 
      local signedSpeed = math.dot(car.velocity, car.look) * 3.6
      if not self.inProcess and signedSpeed < -10 then 
        self.inProcess = true
        self.initialDirection = car.look:clone()
        self.facingWrongWay = 0
      end

      if self.inProcess then
        if car.speedKmh < 10 then
          self.inProcess = false
        end

        local dirDot = math.dot(self.initialDirection, car.look)
        if dirDot < 0.5 and dirDot > -0.5 then
          self.facingWrongWay = self.facingWrongWay + dt
          if self.facingWrongWay > 2 then
            self.inProcess = false
          end
        end
        if signedSpeed > 10 and dirDot < -0.6 then
          return true
        end
      end

      ac.debug('Reverse 180: in process', self.inProcess)
      ac.debug('Reverse 180: wrong way', self.facingWrongWay)
      return false
    end,
    cross = vec2(44, 240),
    inProcess = false,
    initialDirection = nil,
    facingWrongWay = 0
  },
  { 
    name = 'Speed', 
    test = function(self, car) return car.speedKmh > 60 end,
    cross = vec2(55, 160)
  },
  { 
    name = 'Brake Test', 
    test = function(self, car, dt) 
      if car.speedKmh > 50 then
        self.enoughSpeed = true
        self.brakeReleased = 0
        self.wheelsLocked = 0
      end
      if self.enoughSpeed then
        if car.speedKmh < 10 then
          return true
        else
          if car.collisionDepth > 0 then
            self.enoughSpeed = false
          end
          if car.brake < 0.05 then
            self.brakeReleased = self.brakeReleased + dt
            if self.brakeReleased > 0.1 then
              self.enoughSpeed = false
            end
          end
          if math.abs(car.wheels[0].angularSpeed) < 0.1 and math.abs(car.wheels[1].angularSpeed) < 0.1 then
            self.wheelsLocked = self.wheelsLocked + dt
            if self.wheelsLocked > 5 then 
              -- originally locking brakes for more than half a second would fail the attempt, but now threshold is 
              -- increased to 5 seconds to disable that condition. lock-free braking is not quite in the spirit of the task
              self.enoughSpeed = false
            end
          end
        end
      end
      ac.debug('Brake test: enough speed', self.enoughSpeed)
      ac.debug('Brake test: brake released', self.brakeReleased)
      ac.debug('Brake test: wheels locked', self.wheelsLocked)
      return false
    end,
    cross = vec2(58, 230),
    enoughSpeed = false,
    brakeReleased = 0,
    wheelsLocked = 0
  },
  { 
    name = 'Lap', 
    test = function(self, car) 
      local leftToPass = 0
      if car.pos:closerToThan(self.exclusionAreaCenter, self.exclusionAreaRadius) then
        self.pointsPassed = { false, false, false, false }
      end
      for i = 1, #self.points do
        if self.pointsPassed[i] ~= true then
          if car.pos:closerToThan(self.points[i], self.triggerRadius) then
            self.pointsPassed[i] = true
          else
            leftToPass = leftToPass + 1
          end
        end
      end
      ac.debug('Lap: left to pass', leftToPass)
      return leftToPass == 0
    end,
    cross = vec2(65, 140),
    points = ac.getTrackID() == 'driver' 
      and { vec3(25, 0, -25), vec3(-25, 0, -25), vec3(25, 0, 25), vec3(-25, 0, 25) }
      or { vec3(35, 5, -30), vec3(-35, 5, -30), vec3(35, 5, 30), vec3(-35, 5, 30) },
    pointsPassed = { false, false, false, false },
    triggerRadius = 10,
    exclusionAreaCenter = ac.getTrackID() == 'driver' and vec3(0, 0, 0) or vec3(0, 5, 0),
    exclusionAreaRadius = ac.getTrackID() == 'driver' and 16 or 22,
  },
}

-- Event state:
local timePassed = 0
local carHits = 0
local hitCooldown = 0
local messageToShow = nil
local messageCooldown = 0
local messageAlpha = 0
local available = ac.getTrackID() == 'driver' or ac.getTrackID() == 'acm_parking_interview'

local function showMessage(message)
  messageToShow = message
  messageCooldown = 2
end

function script.update(dt)
  ac.debug('available', available)
  if not available then return end

  messageAlpha = math.applyLag(messageAlpha, messageCooldown > 0 and 1 or 0, 0.7, dt)
  if messageCooldown > 0 then
    messageCooldown = messageCooldown - dt
  end

  local car = ac.getCarState(1)
  if timePassed == 0 then
    showMessage('Show us what you can do...')
    if car.gas == 0 or car.speedKmh < 1 then
      return
    end
  end

  timePassed = timePassed + dt

  local notFinished = 0
  for i = 1, #tasks do
    local task = tasks[i]
    if task.complete ~= nil then 
      task.complete = task.complete + dt
    elseif tasks[i]:test(car, dt) then
      task.complete = 0.01
      showMessage(task.name)
    else 
      notFinished = notFinished + 1
    end
  end

  if hitCooldown > 0 then
    hitCooldown = hitCooldown - dt
  elseif car.collisionDepth > 0 then
    hitCooldown = 3
    carHits = carHits + 1
    showMessage('Watch the paint job!')
  end

  if carHits == 4 then
    -- Might seem a bit rude, but I’m just copying messages from original game
    ac.endSession('The car’s wrecked. Get out of my sight.', false)
  end

  if timePassed > 60 then
    ac.endSession('You ran out of time!', false)
  end

  if notFinished == 0 then
    ac.endSession('That’s it, you get the job. Your time: '..(math.floor(timePassed * 10) / 10)..'s')
  end
end

local flashingRed = 0
function script.drawUI()
  if not available then return end

  local uiState = ac.getUI()
  flashingRed = flashingRed + uiState.dt

  local needlePos = vec2(97, 172)
  local needleAngle = math.pi * 2 * timePassed / 60
  local flashing = timePassed > 45 and 0.6 + 0.4 * math.sin(flashingRed * 9) or 1
  ui.beginTransparentWindow('driverStopwatch', vec2(80, 80), vec2(250, 300))
  ui.drawImage('stopwatch.png', vec2(), vec2(191, 259), rgbm(1, flashing, flashing, 1))
  ui.drawLine(needlePos, needlePos + 60 * vec2(math.sin(needleAngle), -math.cos(needleAngle)), rgbm(0, 0, 0, 1), 1)
  ui.endTransparentWindow()

  local penColor = rgbm(0.5, 0, 0, 1)
  local penThickness = 2
  ui.beginTransparentWindow('driverList', vec2(uiState.windowSize.x - 300 - 80, 80), vec2(300, 300))
  ui.drawImage('tasks.png', vec2(), vec2(284, 267))
  for i = 1, #tasks do
    local task = tasks[i]
    if task.complete ~= nil then
      local animation = math.saturate(task.complete * 2)
      ui.drawLine(vec2(task.cross.x, 30 + i * 23.3), 
        vec2(math.lerp(task.cross.x, task.cross.y, animation), 30 + i * 23.3 + (task.cross.y - task.cross.x) * animation * 0.02), 
        penColor, penThickness)
    end
  end
  for i = 1, carHits do
    local pivot = vec2(50 * i, 15)
    ui.drawLine(pivot, pivot + vec2(18, 22), penColor, penThickness)
    ui.drawLine(pivot + vec2(0, 21), pivot + vec2(20, 2), penColor, penThickness)
  end
  ui.endTransparentWindow()

  if messageAlpha > 0 then
    ui.pushStyleVar(ui.StyleVar.Alpha, messageAlpha)
    ui.beginTransparentWindow('driverMessage', vec2(uiState.windowSize.x * 0.5 - 400, uiState.windowSize.y * 0.65), vec2(800, 400))
    ui.beginOutline()    
    ui.pushFont(ui.Font.Huge)
    ui.textAligned(messageToShow, vec2(0.5), vec2(800, 0))
    ui.popFont()
    ui.endOutline(rgbm(0, 0, 0, 1))
    ui.endTransparentWindow()
    ui.popStyleVar()
  end
end

function script.draw3D()
  -- local car = ac.getCarState(1)
  -- local slalom = tasks[3]
  -- local path = slalom.paths[1]
  -- for j = 1, #path do
  --   if path[j] ~= true then
  --     local closeEnough = car.pos:closerToThan(path[j], 8)
  --     render.debugSphere(path[j], slalom.triggerRadius, rgbm(3, 0, closeEnough and 5 or 0, 1))
  --   end
  -- end

  -- local lap = tasks[#tasks]
  -- render.debugSphere(lap.exclusionAreaCenter, lap.exclusionAreaRadius)
  -- for j = 1, #lap.points do
  --   if lap.pointsPassed[j] ~= true then
  --     render.debugSphere(lap.points[j], lap.triggerRadius)
  --   end
  -- end
end