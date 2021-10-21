local offsetSmooth = 0

function update(dt)
  local car = ac.getCarState(1)
  local data = ac.getJoypadState()

  -- Printing out debug values to monitor state
  ac.debug('data.steer', data.steer)
  ac.debug('data.localSpeedX', data.localSpeedX)
  ac.debug('data.mzForce', data.mzForce)
  ac.debug('data.ffb', data.ffb)

  -- Calculating offset value
  local offsetTarget = -data.ffb -- taking negative FFB value
    * 0.02 -- scaling it
    * (0.3 + 0.7 * math.saturate(1 - math.abs(data.steerStick * 2))) -- reducing offset with user steering
    * math.saturate(data.speedKmh / 10 - 1) -- reducing offset for slow cars

  -- Smoothing out offset value greatly to avoid jittering
  offsetSmooth = offsetSmooth + (offsetTarget - offsetSmooth) / 40
  
  -- Applying smoothed out steering offset
  data.steer = data.steer + offsetSmooth
end
