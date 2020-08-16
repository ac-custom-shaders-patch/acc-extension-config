ac.SHADOWS_ON = 1
ac.SHADOWS_OFF = 0

ac.setSkySunSize = function (v) end
ac.setSunAngle = function (v) end
ac.setCustomSunDirection = function (v) end

ac.setSkyExtraGradient = function(id, gradient) 
  if id < 0 or id >= 32 then error('id should be within 0-31 range') end
  ac.skyExtraGradients:set(id + 1, gradient) 
end

ac.removeSkyExtraGradient = function(id) 
  if id < 0 or id >= 32 then error('id should be within 0-31 range') end
  ac.skyExtraGradients:set(id + 1, nil) 
end

ac.addSkyExtraGradients = ac.addSkyExtraGradient