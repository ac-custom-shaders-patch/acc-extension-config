local scriptSettings = ac.INIConfig.scriptSettings()
local cfg = scriptSettings:mapSection('SETTINGS', {
  SLIDE_FOLLOWING = 1,
  SLIDING_LOOK_MULT = 0.8,
  TRACK_FOLLOWING = 1,
  TRACK_FOLLOWING_MULT = 0.85,
  STEERING_MULT = 0.8,
  LOOKAHEAD_DISTANCE = 20,
  FIRST_LAUNCH = true
})

local innerCfg = ac.storage({ firstLaunch = true })
if innerCfg.firstLaunch then
  innerCfg.firstLaunch = false
  local neckCfg = ac.INIConfig.load(ac.getFolder(ac.FolderID.ExtCfgUser)..'/neck.ini')
  if (neckCfg.sections.LOOKAHEAD or neckCfg.sections.ALIGNMENT_BASE or neckCfg.sections.ALIGNMENT_VR)
      and not next(scriptSettings.sections)
      and not neckCfg.sections.SCRIPT then
    neckCfg:setAndSave('SCRIPT', 'ENABLED', false)
  end
end

local turnHead = 0
local driftState = 1
local angleMult = 0

local steerSmooth = 0
local targetAngle = 0
local lastAngle = 0
local steerSpeed = 1

local gForceX = 0
local gForceZ = 0
local headForceZ = 0
local posSmoothZ = 0
local headForceX = 0
local posSmoothX = 0
local gForceY = 0
local headForceY = 0

local lookAheadX = 0
local lookAheadY = 0
local lookAheadBlend = 0

local INVALID_SPLINE_POINT = vec3(-1, -1, -1)

function script.update(dt, mode, turnMix)
  --Sliding--
  local sliding = car.localVelocity.x / math.max(3, car.speedMs)
  local slidingMult = math.abs(sliding) * cfg.SLIDING_LOOK_MULT
  driftState = slidingMult > 0.2 and driftState - dt/2 or driftState + dt/4
  driftState = math.saturate(driftState + (1 - cfg.SLIDE_FOLLOWING))
  angleMult = math.applyLag(angleMult, slidingMult * 0.5, 0.99, dt)
  local thMult = math.max(slidingMult - 0.2 * driftState, 0) * math.sign(sliding)
  local thSpeed = 0.964 + angleMult / 50
  turnHead = math.applyLag(turnHead, thMult, thSpeed, dt)
  local powDriftState = math.pow(driftState, 2)

  --Steering--
  local tyre = car.wheels[car.steer > 0 and 0 or 1]
  local steering = -(math.acos(math.dot(tyre.transform.look, car.side)) - math.pi/2) * 2 * math.saturate(car.speedMs/10 - 0.1)
  steering = math.max(math.abs(steering) - 0.05, 0) * math.sign(steering)
  local slipAngle = math.sin(math.abs(math.angle(tyre.transform.side, tyre.velocity) - math.pi/2))
  targetAngle = math.applyLag(targetAngle, steering / (1 + slipAngle), 0.97, dt)
  steerSpeed = math.min(math.pow(math.abs(lastAngle - steering), 1.5) * 0.15, 0.15)
  lastAngle = targetAngle
  steerSmooth = math.applyLag(steerSmooth, targetAngle * powDriftState, 0.85 - steerSpeed, dt)

  --Track Following--
  local splinePoint = ac.trackProgressToWorldCoordinate(car.splinePosition)
  local splineDistance = splinePoint:distance(car.position)
  local targetPoint = ac.trackProgressToWorldCoordinate((car.splinePosition + cfg.LOOKAHEAD_DISTANCE / sim.trackLengthM) % 1)
  local lookAheadDelta = targetPoint:sub(splinePoint):normalize()
  local facingForward = math.pow(math.saturate(math.dot(lookAheadDelta, car.look)), 0.5)
  local blendNow = math.lerpInvSat(splineDistance, 15, 8) * facingForward
  lookAheadBlend = math.applyLag(lookAheadBlend, blendNow, 0.99, dt)
  lookAheadX = math.applyLag(lookAheadX, math.dot(lookAheadDelta * powDriftState * math.saturate(car.speedMs/10 - 0.1) * cfg.TRACK_FOLLOWING_MULT, car.side) * lookAheadBlend, 0.95, dt)
  local lookAheadYMult = math.dot(lookAheadDelta * 0.7, car.groundNormal) * lookAheadBlend
  lookAheadYMult = lookAheadYMult < 0 and lookAheadYMult / 2 or lookAheadYMult
  lookAheadY = math.applyLag(lookAheadY, lookAheadYMult, 0.98, dt)
  ----
  local trackFollowing = targetPoint == INVALID_SPLINE_POINT and 0 or cfg.TRACK_FOLLOWING
  local mainTurn = turnHead * cfg.SLIDE_FOLLOWING + math.lerp(steerSmooth * cfg.STEERING_MULT, lookAheadX, trackFollowing)

  --Forces--
  gForceZ = math.applyLag(gForceZ, -car.acceleration.z, 0.96, dt)
  headForceZ = math.applyLag(headForceZ, gForceZ, 0.98, dt)
  local posMultZ = math.clamp((gForceZ - headForceZ) * 0.02 / (1 + math.abs(mainTurn)), -0.02, 0.2)
  posSmoothZ = math.applyLag(posSmoothZ, posMultZ, 0.9, dt)
  headForceZ = math.applyLag(headForceZ, 0, 0.99, dt)

  gForceX = math.applyLag(gForceX, -car.acceleration.x, 0.96, dt)
  headForceX = math.applyLag(headForceX, gForceX, 0.98, dt)
  posSmoothX = math.applyLag(posSmoothX, (gForceX - headForceX) * 0.01 / (2 - 1 * powDriftState + math.abs(mainTurn)), 0.9, dt)
  headForceX = math.applyLag(headForceX, 0, 0.99, dt)

  gForceY = math.applyLag(gForceY, (math.pow(math.abs(car.acceleration.y) + 1, 0.5) - 1) * math.sign(car.acceleration.y) * 0.02, 0.952, dt)
  headForceY = math.applyLag(headForceY, gForceY, 0.98, dt)
  local gfYFinal = math.clamp(gForceY, -0.01, 0.01) / (1 + headForceY * 2)
  headForceY = math.applyLag(headForceY, 0, 0.99, dt)

  --Reset--
  if car.justJumped or car.speedMs < 3 then
    posSmoothX = 0
    posSmoothZ = 0
    gForceY = 0
    gForceZ = 0
    gForceX = 0
    headForceZ = 0
    headForceX = 0
  end

  --Apply to look--
  neck.look:addScaled(car.side, (mainTurn - posSmoothX/2) * turnMix)
  neck.look:addScaled(car.up, -(posSmoothZ / (2 + math.abs(headForceZ) * 2)) - gfYFinal / 3)
  neck.look:addScaled(car.groundNormal, lookAheadY * turnMix * trackFollowing)
  neck.up:addScaled(car.side, posSmoothX)
  neck.position:addScaled(car.side, posSmoothX)
  neck.position:addScaled(car.look, posSmoothZ)
  neck.position:addScaled(car.up, -(posSmoothZ + math.abs(posSmoothX)) * 0.1)
  neck.position:addScaled(car.up, gfYFinal)
end
