--[[
  Limit FFB by 200%. Just a test for direct drive wheels.
]]

local limitUntil = 0

-- If you need to deal with DirectDrive devices and output FFB above 100% and above incoming value,
-- uncomment this line (but be super careful with it!)
ac.unlockFFBLimits(true)

function script.update(ffbValue, ffbDamper, steerInput, steerInputSpeed)
  local now = os.preciseClock()
  if now < limitUntil then
    return 0, 1
  end
  if car.acceleration:lengthSquared() > 4 then
    limitUntil = now + 1
  end
  if car.collisionDepth > 0 and car.collisionPosition.y > 0.1 then
    limitUntil = now + 1
  end
  return ffbValue, ffbDamper
end
