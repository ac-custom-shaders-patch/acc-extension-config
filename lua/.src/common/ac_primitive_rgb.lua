local function rgbValue(v) return math.max(v.r, v.g, v.b) end
local function rgbLuminance(v) return 0.299 * v.r + 0.587 * v.g + 0.114 * v.b end

local function rgbHue(v)     
  if v.r == v.g and v.g == v.b then return 0 end

  local max = v.r
  local min = v.r
  if v.g > max then max = v.g end
  if v.b > max then max = v.b end
  if v.g < min then min = v.g end
  if v.b < min then min = v.b end

  local result = 0
  if v.r == max then result = (v.g - v.b) / (max - min) 
  elseif v.g == max then result = 2 + (v.b - v.r) / (max - min)
  elseif v.b == max then result = 4 + (v.r - v.g) / (max - min)
  end

  if result < 0 then result = result + 6 end
  return result * 60
end

local function rgbSaturation(v) 
  local a = math.max(v.r, v.g, v.b)
  if a <= 0 then return 0 end
  local i = math.min(v.r, v.g, v.b)
  return (a - i) / a;
end

return {
  __call = function(_, r, g, b)
    return setmetatable({ r = r or 0, g = g or 0, b = b or 0 }, rgb)
  end,

  __tostring = function(v)
    return string.format('(%f, %f, %f)', v.r, v.g, v.b)
  end,

  __add = function(v, u) if type(v) == 'number' then return rgb(v, v, v):add(u, rgb()) end return v:add(u, rgb()) end,
  __sub = function(v, u) if type(v) == 'number' then return rgb(v, v, v):sub(u, rgb()) end return v:sub(u, rgb()) end,
  __mul = function(v, u)
    if type(v) == 'number' then return rgb(v, v, v) * u end 
    if rgb.isrgb(u) then return v:mul(u, rgb())
    elseif type(u) == 'number' then return v:scale(u, rgb())
    else error('rgbs can only be multiplied by rgbs and numbers') end
  end,
  __div = function(v, u)
    if type(v) == 'number' then return rgb(v, v, v) / u end 
    if rgb.isrgb(u) then return v:div(u, rgb())
    elseif type(u) == 'number' then return v:scale(1 / u, rgb())
    else error('rgbs can only be divided by rgbs and numbers') end
  end,
  __pow = function(v, u)
    if type(v) == 'number' then return rgb(v, v, v) ^ u end 
    if rgb.isrgb(u) then return v:pow(u, rgb())
    elseif type(u) == 'number' then return rgb(v.r ^ u, v.g ^ u, v.b ^ u)
    else error('rgbs can only be raised to power of rgbs and numbers') end
  end,
  __unm = function(v) return rgb(-v.r, -v.g, -v.b) end,
  __len = function(v) return v:value() end,
  __eq = function(v, o) return o ~= nil and v.r == o.r and v.g == o.g and v.b == o.b end,
  __lt = function(v, o) return v:value() < o:value() end,
  __le = function(v, o) return v:value() <= o:value() end,
  __index = {
    new = function(r, g, b) 
      if rgb.isrgb(r) then return r end
      if rgbm.isrgbm(r) then return r:color() end
      if hsv.ishsv(r) then return r:rgb() end
      if vec3.isvec3(r) then return rgb(r.x, r.y, r.z) end
      if vec4.isvec4(r) then return rgb(r.x * r.w, r.y * r.w, r.z * r.w) end
      if type(r) ~= 'number' then r = 0 end
      if type(g) ~= 'number' then g = r end
      if type(b) ~= 'number' then b = g end
      return rgb(r, g, b) 
    end,

    from0255 = function(r, g, b) 
      if type(r) ~= 'number' then r = 0 end
      if type(g) ~= 'number' then g = r end
      if type(b) ~= 'number' then b = g end
      return rgb(r / 255, g / 255, b / 255) 
    end,

    isrgb = function(r) return ffi.istype('rgb', r) end,
    type = function(x) return rgb end,
    clone = function(v) return rgb(v.r, v.g, v.b) end,
    unpack = function(v) return v.r, v.g, v.b end,

    set = function(v, r, g, b)
      if rgb.isrgb(r) then 
        r, g, b = r.r, r.g, r.b
      else
        if g == nil then g = r end
        if b == nil then b = g end
      end
      v.r = r
      v.g = g
      v.b = b
      return v
    end,

    setLerp = function(v, a, b, k)
      v.r = math.lerp(a.r, b.r, k)
      v.g = math.lerp(a.g, b.g, k)
      v.b = math.lerp(a.b, b.b, k)
      return v
    end,

    add = function(v, u, out)
      out = out or v
      if rgb.isrgb(u) then 
        out.r = v.r + u.r
        out.g = v.g + u.g
        out.b = v.b + u.b
      else
        out.r = v.r + u
        out.g = v.g + u
        out.b = v.b + u
      end
      return out
    end,

    sub = function(v, u, out)
      out = out or v
      if rgb.isrgb(u) then 
        out.r = v.r - u.r
        out.g = v.g - u.g
        out.b = v.b - u.b
      else
        out.r = v.r - u
        out.g = v.g - u
        out.b = v.b - u
      end
      return out
    end,

    mul = function(v, u, out)
      out = out or v
      out.r = v.r * u.r
      out.g = v.g * u.g
      out.b = v.b * u.b
      return out
    end,

    div = function(v, u, out)
      out = out or v
      out.r = v.r / u.r
      out.g = v.g / u.g
      out.b = v.b / u.b
      return out
    end,

    pow = function(v, u, out)
      out = out or v
      if type(u) == 'number' then
        out.r = v.r ^ u
        out.g = v.g ^ u
        out.b = v.b ^ u
      else
        out.r = v.r ^ u.r
        out.g = v.g ^ u.g
        out.b = v.b ^ u.b
      end
      return out
    end,

    scale = function(v, s, out)
      out = out or v
      out.r = v.r * s
      out.g = v.g * s
      out.b = v.b * s
      return out
    end,

    saturate = function(v, out)
      out = out or v
      out.r = math.saturateN(v.r)
      out.g = math.saturateN(v.g)
      out.b = math.saturateN(v.b)
      return out
    end,

    clamp = function(v, min, max, out)
      out = out or v
      out.r = math.clampN(v.r, min.r, max.r)
      out.g = math.clampN(v.g, min.g, max.g)
      out.b = math.clampN(v.b, min.b, max.b)
      return out
    end,

    normalize = function(v)
      local m = v:value()
      if m > 1 then return v / m end
      return v
    end,

    adjustSaturation = function(v, sat, out)
      out = out or v
      local avg = (v.r + v.g + v.b) / 3
      out.r = math.max(math.lerp(avg, out.r, sat), 0)
      out.g = math.max(math.lerp(avg, out.g, sat), 0)
      out.b = math.max(math.lerp(avg, out.b, sat), 0)
      return out
    end,

    value = rgbValue,
    getValue = rgbValue,
    hue = rgbHue,
    getHue = rgbHue,
    hue = rgbHue,
    getSaturation = rgbSaturation,
    saturation = rgbSaturation,
    luminance = rgbLuminance,
    getLuminance = rgbLuminance,

    hsv = function(v) return hsv(v:hue(), v:saturation(), v:value()) end,
    toHsv = function(v) return hsv(v:hue(), v:saturation(), v:value()) end,
    rgbm = function(v, m) return rgbm(v.r, v.g, v.b, __num_fallback(m, 1)) end,
    toRgbm = function(v, m) return rgbm(v.r, v.g, v.b, __num_fallback(m, 1)) end,
    vec3 = function(v) return vec3(v.r, v.g, v.b) end,
    toVec3 = function(v) return vec3(v.r, v.g, v.b) end,
  }
}