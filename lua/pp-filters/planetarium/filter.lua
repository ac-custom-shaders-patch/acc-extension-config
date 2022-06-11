local function showInfo(dir, distance, color, name, description)
  if dir.y < 0.1 then return end

  local size = math.lerp(20, 200, math.lerpInvSat(ac.getCameraFOV(), 16, 2))
  local sunPos = ui.projectPoint(ac.getCameraPosition():addScaled(dir, 1e6))
  ui.drawRect(sunPos - size, sunPos + size, color, 4, ui.CornerFlags.All, 2)
  ui.pushFont(ui.Font.Title)
  ui.drawText(name, sunPos + vec2(-16, size + 8), color)
  ui.popFont()

  if distance > 1e6 then
    distance = string.format('%.1f million', distance / 1e6)
  elseif distance > 1e3 then
    distance = string.format('%.1f thousand', distance / 1e3)
  else
    distance = string.format('%.1f', distance)
  end

  ui.drawText(string.format(description, distance), sunPos + vec2(-16, size + 32), color)
end

local function showFeatureInfo(id, color, name, description)
  local num = refnumber(0)
  local dir = ac.getSkyFeatureDirection(id, num)
  showInfo(dir, num.value, color, name, description)
end

function script.update()
  ui.setShadingOffset(1, 0, 0, 1)
  ui.drawImage('dynamic::screen', vec2(), ui.windowSize())

  showFeatureInfo(ac.SkyFeature.Sun, rgbm.colors.gray, 
    'Sun', 'Distance: %s km\nAge: 4.6 billion years\nSurface temperature: 5505 °C')

  showFeatureInfo(ac.SkyFeature.Moon, rgbm.colors.gray, 
    'Moon', string.format('Distance: %%s km\nAge: 4.5 million years\nSurface temperature: %.0f °C', math.lerp(-173, 127, ac.getMoonFraction())))

  showFeatureInfo(ac.SkyFeature.Venus, rgbm(0.6, 0.4, 0.4, 1), 
    'Venus', 'Distance: %s km\nAge: 4.5 billion years\nSurface temperature: 475 °C')

  showFeatureInfo(ac.SkyFeature.Mars, rgbm(0.7, 0.3, 0.3, 1), 
    'Mars', 'Distance: %s km\nAge: 4.6 billion years\nSurface temperature: -60 °C')

  showFeatureInfo(ac.SkyFeature.Saturn, rgbm(0.6, 0.6, 0.4, 1), 
    'Saturn', 'Distance: %s km\nAge: 4.5 billion years\nSurface temperature: -178 °C')

  showFeatureInfo(ac.SkyFeature.Jupiter, rgbm(0.6, 0.5, 0.4, 1), 
    'Jupiter', 'Distance: %s km\nAge: 4.6 billion years\nSurface temperature: -145 °C')

  local issAge = (ac.getSim().timestamp - 911509200) / (365.25 * 24 * 60 * 60)
  showFeatureInfo(ac.SkyFeature.ISS, rgbm.colors.gray, 
    'International Space Station', string.format('Distance: %%s km\nAge: %.1f years\nSurface temperature: -157 °C', issAge))

  if ac.getSkyFeatureDirection(ac.SkyFeature.Sun).y > 0 then return end

  showInfo(ac.getSkyStarDirection(math.rad(89.25), 2.683333 / 12 * math.pi), 0, rgbm(0.4, 0.4, 0.6, 1),
    'Polaris', 'Distance: 433 light-years\nAge: 70 million years\nSurface temperature: 5742 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(61.75), 11.062131 / 12 * math.pi), 0, rgbm(0.5, 0.5, 0.6, 1),
    'Alpha Ursa Major', 'Distance: 123 light-years\nAge: 280 million years\nSurface temperature: 4739 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(-16.7), 6.752472 / 12 * math.pi), 0, rgbm(0.4, 0.4, 0.6, 1),
    'Sirius', 'Distance: 8.7 light-years\nAge: 242/228 million years\nSurface temperature: 9670/24700 °C\nBinary star')
    
  showInfo(ac.getSkyStarDirection(math.rad(7.407), 5.919528 / 12 * math.pi), 0, rgbm(0.6, 0.4, 0.4, 1),
    'Betelgeuse', 'Distance: 548 light-years\nAge: 8.2 million years\nSurface temperature: 3400 °C')    

  showInfo(ac.getSkyStarDirection(math.rad(-60.833889), 14.66 / 12 * math.pi), 0, rgbm(0.4, 0.4, 0.6, 1),
    'Alpha Centauri A', 'Distance: 4.37 light-years\nAge: 5.3 billion years\nSurface temperature: 5520 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(-60.8375), 14.659722 / 12 * math.pi), 0, rgbm(0.4, 0.4, 0.6, 1),
    'Alpha Centauri B', 'Distance: 4.37 light-years\nAge: 5.3 billion years\nSurface temperature: 4990 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(-8.201389), 5.242222 / 12 * math.pi), 0, rgbm(0.5, 0.5, 0.6, 1),
    'Rigel', 'Distance: 863 light-years\nAge: 8 million years\nSurface temperature: 11800 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(38.783611), 18.615556 / 12 * math.pi), 0, rgbm(0.4, 0.5, 0.6, 1),
    'Vega', 'Distance: 25 light-years\nAge: 455 million years\nSurface temperature: 9320 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(24.116667), 3.79 / 12 * math.pi), 0, rgbm(0.4, 0.5, 0.6, 1),
    'Pleiades', 'Distance: 444 light-years\nOpen star cluster')
    
  showInfo(ac.getSkyStarDirection(math.rad(-26.431944), 16.49 / 12 * math.pi), 0, rgbm(0.6, 0.4, 0.4, 1),
    'Antares', 'Distance: 550 light-years\nAge: 15 million years\nSurface temperature: 18200 °C')
    
  showInfo(ac.getSkyStarDirection(math.rad(-52.695556), 6.399167 / 12 * math.pi), 0, rgbm(0.4, 0.5, 0.6, 1),
    'Canopus', 'Distance: 310 light-years\nAge: 25.1 million years\nSurface temperature: 7100 °C')
end
