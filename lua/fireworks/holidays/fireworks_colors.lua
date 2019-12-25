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