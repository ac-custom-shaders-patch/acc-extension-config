function ColorGeneric()
  function randomColor()
    local r = math.random()
    if r > 0.9 then return rgb(1, 0, 0) end
    if r > 0.8 then return rgb(1, 0.5, 0) end
    if r > 0.7 then return rgb(1, 1, 0) end
    if r > 0.6 then return rgb(0, 1, 0) end
    if r > 0.5 then return rgb(0, 1, 1) end
    if r > 0.4 then return rgb(0, 0, 1) end
    if r > 0.3 then return rgb(1, 0, 1) end
    if r > 0.2 then return rgb(0.5, 0, 1) end
    if r > 0.1 then return rgb(0, 0, 0.5) end
    return rgb(1, 1, 1)
  end

  if math.random() > 0.2 then return { randomColor(), randomColor() } end
  return randomColor()
end

function ColorChristmas()
  function randomColor()
    return math.random() > 0.95
      and (math.random() > 0.5 
        and rgb(0, 1, 0) 
        or rgb(1, 0, 0) )
      or (math.random() > 0.5 
        and rgb(1, 1, 1) 
        or math.random() > 0.5 
          and rgb(1, 1, 0) 
          or rgb(0, 0.5, 1))
  end

  if math.random() > 0 then return { randomColor(), randomColor() } end
  return randomColor()
end

function ColorVictoryDay()
  function randomColor()
    local r = math.random()
    if r > 0.99 then return rgb(0, 0.5, 1) end
    if r > 0.98 then return rgb(0, 1, 0.5) end
    if r > 0.6 then return rgb(1, 0.5, 0) end
    if r > 0.5 then return rgb(1, 1, 0) end
    if r > 0.4 then return rgb(1, 0, 1) end
    return rgb(1, 0, 0)
  end

  -- if math.random() > 0 then return { randomColor(), randomColor() } end
  return randomColor()
end

function ColorIndependenceDay()
  function randomColor()
    local r = math.random()
    if r > 0.6 then return rgb(1, 1, 1) end
    if r > 0.4 then return rgb(1, 0, 0) end
    if r > 0.2 then return rgb(0, 0.5, 1) end
    return rgb(1, 0.5, 0)
  end

  if math.random() > 0.2 then return { randomColor(), randomColor() } end
  return randomColor()
end

function ColorCanadaDay()
  function randomColor()
    local r = math.random()
    if r > 0.95 then return rgb(1, 0, 1) end
    if r > 0.85 then return rgb(1, 0.5, 0) end
    if r > 0.4 then return rgb(1, 1, 1) end
    return rgb(1, 0, 0)
  end

  if math.random() > 0.2 then return { randomColor(), randomColor() } end
  return randomColor()
end

function ColorSame(fn)
  local ret = fn and fn() or rgb(1, 1, 0) 
  return function ()
    return ret
  end
end

function GetColors(fn)
  if rgb.isrgb(fn) then return fn, fn end
  local color = type(fn) == 'function' and fn() or { rgb(1, 0.5, 0.5), rgb(1, 1, 0.5) }
  local colorA = rgb.isrgb(color) and color or color[1]
  local colorB = rgb.isrgb(color) and color or color[2] or color[1]
  return colorA, colorB
end