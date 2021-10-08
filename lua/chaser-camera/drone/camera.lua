--------
-- Experimental camera script, with extra features, not really working properly at the moment.
--------

-- Options for two different cameras (all distances are in meters):
local maximumCameraAngle = { 30, 30 }  -- degress

-- This thing will smooth car velocity to reduce wobbling with replays or in online:
local carVelocity = smoothing(vec3(), 50)

-- Alternative for ac.getCarVelocity(), possibly smoother:
local calculateVelocityHere = true
local lastCarPos = vec3()

-- Extra thing for looking around:
local lookDirection = smoothing(0, 40)

-- Smooth parameters:
local smoothHeight = smoothing(1, 100)
local smoothDistance = smoothing(5, 90)
local smoothLookPosOffset = smoothing(1, 80)

-- Extras:
local burnoutTimer = 3
local donutTimer = 3

-- Will be called each frame:
-- Note: `dt` is time passed since last frame, `cameraIndex` is 1 or 2, depending on which camera is
-- chosen.
function update(dt, cameraIndex)

  smoothing.setDT(dt)

  -- Get AC camera parameters with some corrections to be somewhat compatible:
  local carForces = ac.getCarGForces()
  local cameraParameters = ac.getCameraParameters(cameraIndex)
  local distance = cameraParameters.distance + 2.50 + math.clamp(carForces.z / 2, -0.5, 5)
  local height = cameraParameters.height + math.clamp(-carForces.y / 1.2, 0.2, 1)
  local pitchAngle = -cameraParameters.pitch

  -- Get car position and vectors:
  local carPos = ac.getCarPosition()
  local carDir = ac.getCarDirection()
  local carUp = ac.getCarUp()
  local carRight = math.cross(carDir, carUp):normalize()

  if calculateVelocityHere then
    -- Altenative approach, using coordinates and time delta
    if lastCarPos ~= carPos then
      if lastCarPos ~= vec3() then
        local delta = lastCarPos - carPos
        local deltaLength = #delta
        if deltaLength > 5 then delta = delta / deltaLength * 5 end
        carVelocity:update(-delta / dt)
      end
      lastCarPos = carPos
    end
  else
    -- Update smoothing thing with velocity:
    -- Note: method `updateIfNew` would change value only if parameter is different from the one used last 
    -- time. This way, in replays camera will freeze.
    carVelocity:updateIfNew(ac.getCarVelocity())
  end

  -- Normalize car velocity:
  local carVelocityDir = math.normalize(carVelocity.val + carDir * 0.01)

  -- Get rotation coefficient, from -1 to 1, based on X-component of local velocity (that’s what dot is for)
  -- and taking absolute speed into account as well:
  local velocityX = math.clamp(math.dot(carRight, carVelocityDir) * math.pow(#carVelocity.val, 0.7) / 7, -2, 1)

  -- Camera angle for given coefficient:
  local cameraAngle = -velocityX * math.radians(maximumCameraAngle[cameraIndex])

  -- Extra stuff:
  local forceLook = nil
  local slipRatio = math.saturate(ac.getTyreSlipRatio(3) * ac.getTyreSlipRatio(4) * 2)
  if slipRatio == 1 and #ac.getCarVelocity() < 0.5 then
    if burnoutTimer >= 1 then
      forceLook = -0.3
      smoothLookPosOffset:update(-0.5)
      smoothDistance:update(0)
      smoothHeight:update(1)
      burnoutTimer = 1
    else
      burnoutTimer = burnoutTimer + dt
    end
  elseif burnoutTimer > 0 then
    burnoutTimer = burnoutTimer - dt * 10
  else
    smoothLookPosOffset:update(4)
    smoothDistance:update(distance)
    smoothHeight:update(height)
    burnoutTimer = 0
  end

  if burnoutTimer == 0 and slipRatio == 1 and #ac.getCarVelocity() < 4 and math.abs(ac.getSteer()) > 300 then
    if donutTimer >= 1 then
      forceLook = 0.3 * math.sign(ac.getSteer())
      smoothLookPosOffset:update(-0.5)
      smoothDistance:update(8)
      smoothHeight:update(4)
      donutTimer = 1
    else
      donutTimer = donutTimer + dt
    end
  elseif donutTimer > 0 then
    donutTimer = donutTimer - dt * 4
  else
    smoothLookPosOffset:update(1)
    smoothDistance:update(distance)
    smoothHeight:update(height)
    donutTimer = 0
  end

  -- Extra thing for joystick support:
  local joystickLook = ac.getJoystickLook()
  lookDirection:update(
    forceLook or
    (ac.looksLeft() and ac.looksRight() or ac.looksBehind()) and math.sign(lookDirection.val) or
    ac.looksLeft() and 0.5 or
    ac.looksRight() and -0.5 or
    joystickLook ~= nil and joystickLook.x or 0)
  cameraAngle = cameraAngle + lookDirection.val * math.pi

  -- Sine and cosine for camera angle
  local sin, cos = math.sin(cameraAngle), math.cos(cameraAngle)

  -- Up direction for camera (could be used for horizon lock):
  local cameraUp = (carUp + vec3(0.4, 0, 0)):normalize()

  -- Set camera position:
  ac.Camera.position = carPos 
    + (carRight * sin - carDir * cos) * smoothDistance.val
    + vec3(0.4, smoothHeight.val, 0)

  -- Find camera look
  local cameraLookPosOffset = carDir * smoothLookPosOffset.val + carUp * (1 - math.abs(lookDirection.val))
  local cameraLook = (carPos + cameraLookPosOffset - ac.Camera.position):normalize()

  -- Use for `pitchAngle`:
  cameraLook:rotate(quat.fromAngleAxis(math.radians(pitchAngle), carRight))

  -- Set camera look:
  ac.Camera.direction = cameraLook

  -- Set other parameters:
  ac.Camera.up = (carUp + vec3(0.1, 1, -0.1)):normalize()
  ac.Camera.fov = 31 + (#carVelocity.val*0.18)
end