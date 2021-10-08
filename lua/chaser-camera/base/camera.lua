--------
-- Simple camera script, using velocity to rotate camera.
--------

-- Options for two different cameras (all distances are in meters):
local maximumCameraAngle = { 54, 68 }  -- degress

-- This thing will smooth car velocity to reduce wobbling with replays or in online:
local carVelocity = smoothing(vec3(), 40)

-- Alternative for ac.getCarVelocity(), possibly smoother:
local calculateVelocityHere = true
local lastCarPos = vec3()

-- Extra thing for looking around:
local lookDirection = smoothing(0, 10)

-- Will be called each frame:
-- Note: `dt` is time passed since last frame, `cameraIndex` is 1 or 2, depending on which camera is
-- chosen.
function update(dt, cameraIndex)

  smoothing.setDT(dt)

  -- Get AC camera parameters with some corrections to be somewhat compatible:
  local cameraParameters = ac.getCameraParameters(cameraIndex)
  local distance = cameraParameters.distance + 0.8
  local height = cameraParameters.height 
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

  -- ac.debug('carVelocity', carVelocity)

  -- Normalize car velocity:
  local carVelocityDir = math.normalize(carVelocity.val + carDir * 0.01)

  -- Get rotation coefficient, from -1 to 1, based on X-component of local velocity (that’s what dot is for)
  -- and taking absolute speed into account as well:
  local velocityX = math.clamp(math.dot(carRight, carVelocityDir) * math.pow(#carVelocity.val, 0.5) / 10, -1, 1)

  -- Camera angle for given coefficient:
  local cameraAngle = -velocityX * math.radians(maximumCameraAngle[cameraIndex])

  -- Extra thing for joystick support:
  local joystickLook = ac.getJoystickLook()
  lookDirection:update(
    (ac.looksLeft() and ac.looksRight() or ac.looksBehind()) and math.sign(lookDirection.val) or
    ac.looksLeft() and 0.5 or
    ac.looksRight() and -0.5 or
    joystickLook ~= nil and joystickLook.x or 0)
  cameraAngle = cameraAngle + lookDirection.val * math.pi

  -- Sine and cosine for camera angle
  local sin, cos = math.sin(cameraAngle), math.cos(cameraAngle)

  -- Up direction for camera (could be used for horizon lock):
  local cameraUp = (carUp + vec3(0, 3, 0)):normalize()

  -- Set camera position:
  ac.Camera.position = carPos 
    + (carRight * sin - carDir * cos) * distance
    + vec3(0, height, 0)

  -- Find camera look
  local cameraLookPosOffset = carDir + carUp * (1 - math.abs(lookDirection.val ))
  local cameraLook = (carPos + cameraLookPosOffset - ac.Camera.position):normalize()

  -- Use for `pitchAngle`:
  cameraLook:rotate(quat.fromAngleAxis(math.radians(pitchAngle), carRight))

  -- Set camera look:
  ac.Camera.direction = cameraLook

  -- Set other parameters:
  ac.Camera.up = (carUp + vec3(0, 3, 0)):normalize()
  ac.Camera.fov = 60

end