__source 'extensions/car_instruments/scriptable_display.cpp'
__allow 'carscriptabledisplay'

require './common/ac_ui'
require './common/ac_audio'

-- automatically generated entries go here:
__definitions()

-- extra additions:
car = nil
sim = nil
function __init__()
  car = ac.getCarState(__carindex__)
  sim = ac.getSimState()
end

display = {}

function display.rect(params)
  local pos = params.pos      -- rect position
  local size = params.size    -- rect size
  local color = params.color  -- rect color
  ui.drawRectFilled(pos, pos + size, color)
end

function display.image(params)
  local image = params.image      -- image source
  local pos = params.pos          -- image position
  local size = params.size        -- image size
  local color = params.color      -- image tint
	local uvStart = params.uvStart  -- UV for upper left corner, optional
	local uvEnd = params.uvEnd      -- UV for bottom right corner, optional
  ui.drawImage(image, pos, pos + size, color, uvStart, uvEnd)
end

function display.mirror(params)
  local pos = params.pos          -- rect position
  local size = params.size        -- rect size
  local color = params.color      -- rect color
	local uvStart = params.uvStart  -- UV for upper left corner, optional
	local uvEnd = params.uvEnd      -- UV for bottom right corner, optional
  local mirrorIndex = params.mirrorIndex -- mirror index (for real mirrors)

  local uv = ac.getRealMirrorUV(mirrorIndex == nil and 1 or mirrorIndex)
  if uv.x ~= -1 then
    uvStart = vec2(uv.x, uv.y)
    uvEnd = vec2(uv.z, uv.w)
  end
  ui.drawImage("dynamic::mirror", pos, pos + size, color, uvStart, uvEnd)
end

function display.text(params)
  local text = tostring(params.text)   -- text to draw
  local pos = params.pos               -- text position, optional
  local letter = params.letter         -- size of each letter
  local font = params.font             -- name of font, optional
  local color = params.color           -- color, optional
  local width = params.width or 0      -- width, optional
  local alignment = params.alignment   -- alignment, optional (0.5 for center, 1 for right)
  local spacing = params.spacing or 0  -- extra spacing between letters

  local textLen = #text
  if textLen == 0 then return end
  
  local actualWidth = letter.x * textLen + (textLen > 0 and spacing * (textLen - 1) or 0)
  if width > actualWidth then
    pos.x = pos.x + (width - actualWidth) * alignment
  end

  if font ~= nil then ui.pushACFont(font) end
  if pos ~= nil then ui.setCursor(pos) end  
  ui.acText(text, letter, spacing, color)
  if font ~= nil then ui.popACFont() end
end

function display.interactiveMesh(params)
  local meshName = params.mesh
  local resolution = params.resolution
  return {
    clicked = function(texStart, texSize, repeatIntervalSeconds)
      local uv1 = texStart / resolution
      local uv2 = texSize / resolution
      if repeatIntervalSeconds == nil then
        return function() return ac.isMeshClicked(meshName, uv1, uv2) end
      end

      local timeToRepeat = 0
      return function()
        if ac.isMeshClicked(meshName, uv1, uv2) then
          timeToRepeat = repeatIntervalSeconds
          return true
        elseif timeToRepeat > 0 and ac.isMeshPressed(meshName, uv1, uv2) then
          timeToRepeat = timeToRepeat - ac.getSimState().dt
          if timeToRepeat <= 0 then 
            timeToRepeat = repeatIntervalSeconds
            return true
          end
        else
          timeToRepeat = 0
          return false
        end
      end
    end,
    pressed = function(texStart, texSize)
      local uv1 = texStart / resolution
      local uv2 = texSize / resolution
      return function()
        return ac.isMeshPressed(meshName, uv1, uv2)
      end
    end
  }
end

function display.horizontalBar(params)
  local pos = params.pos      -- bar position
  local size = params.size    -- bar size
  local delta = params.delta  -- distance between elements
  local activeColor = params.activeColor -- active color
  local inactiveColor = params.inactiveColor -- inactive color
  local total = params.total
  local active = params.active
  local itemSize = (size.x - delta * (total - 1)) / total
  for i = 1, total do
    ui.drawRectFilled(pos, pos + vec2(itemSize, size.y), i <= active and activeColor or inactiveColor)
    pos = pos + vec2(itemSize + delta, 0)
  end
end

