--[[
  Alternative custom lock (testing playground to find a good logic before moving it to C++). Also, an example of how to make
  a custom FFB post-processing script.

  Few tips:
  • Be extremely careful with DirectDrive wheels!
  • API is pretty limited, script gets called very often so it should be lightweight;
  • Use `os.preciseClock()` to compute delta time if needed;
  • `setInterval`/`setTimeout` and other callbacks won’t work here;
  • AC skips frames based on “FFB skip steps” setting, make sure to test script with different values;
  • First and second parameters are input FFB and damper, third is wheel angle, fourth is steering speed;
  • Should return two values, one for FFB and another for damper;
  • Use `car` to get the state of associated car;
  • State of `ac.getCar()` only updates with each graphics frame.
]]

-- Disable soft lock: this script will do it itself
ac.disableSoftLock(true)

-- If you need to deal with DirectDrive devices and output FFB above 100% and above incoming value,
-- uncomment this line (but be super careful with it!)
-- ac.unlockFFBLimits(true)

local settings = ac.INIConfig.cspModule(ac.CSPModuleID.FFBTweaks)
local steerLock = car.steerLock
local pad = settings:get('CUSTOM_SOFT_LOCK', 'PADDING', 10) / steerLock
local forceFactor = settings:get('CUSTOM_SOFT_LOCK', 'FORCE_FACTOR', 1)
local speedFactor = settings:get('CUSTOM_SOFT_LOCK', 'SPEED_FACTOR', 1)
local lockDamper = settings:get('CUSTOM_SOFT_LOCK', 'DAMPER', 0)

function script.update(ffbValue, ffbDamper, steerInput, steerInputSpeed, dt)
  local lock = math.lerpInvSat(math.abs(steerInput) - 1, -pad, pad)
  if lock ~= 0 then
    if math.sign(ffbValue) ~= math.sign(steerInput) then
      ffbValue = math.lerp(ffbValue, 0, math.min(lock * 2, 1))
    end
    local speedAware = math.lerpInvSat(math.abs(steerInput) - 1, pad * 2, 0)
    ffbValue = math.lerp(ffbValue, math.clampN(math.sign(steerInput) * forceFactor + steerInputSpeed * speedAware * speedFactor, -1, 1), lock)
    ffbDamper = math.lerp(ffbDamper, lockDamper, lock)
  end
  return ffbValue, ffbDamper
end
