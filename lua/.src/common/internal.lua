-- Helper module for internal use, please do not use it in your code. Mainly meant
-- for ensure types are correct when being passed to C++.

__util = {}

function __util.cast_vec2(ret, arg)
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to vec2')
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
  end
  return ret
end

function __util.cast_vec3(ret, arg)
  if type(arg) == 'cdata' then
    if ffi.istype('rgb', arg) then
      ret.x = arg.r
      ret.y = arg.g
      ret.z = arg.b
    elseif ffi.istype('rgbm', arg) then
      ret.x = arg.r * arg.mult
      ret.y = arg.g * arg.mult
      ret.z = arg.b * arg.mult
    else
      error('Cannot convert '..tostring(arg)..' to vec3')
    end
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
    ret.z = num
  end
  return ret
end

function __util.cast_vec4(ret, arg)
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to vec4')
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
    ret.z = num
    ret.w = num
  end
  return ret
end

function __util.cast_rgb(ret, arg)
  if type(arg) == 'cdata' then
    if ffi.istype('rgbm', arg) then
      ret.r = arg.r * arg.mult
      ret.g = arg.g * arg.mult
      ret.b = arg.b * arg.mult
    elseif ffi.istype('vec3', arg) then
      ret.r = arg.x
      ret.g = arg.y
      ret.b = arg.z
    else
      error('Cannot convert '..tostring(arg)..' to rgb')
    end
  else
    local num = tonumber(arg) or 0
    ret.r = num 
    ret.g = num
    ret.b = num
  end
  return ret
end

function __util.cast_rgbm(ret, arg)
  if type(arg) == 'cdata' then
    if ffi.istype('rgb', arg) then
      ret.r = arg.r
      ret.g = arg.g
      ret.b = arg.b
      ret.mult = 1
    elseif ffi.istype('vec3', arg) then
      ret.r = arg.x
      ret.g = arg.y
      ret.b = arg.z
      ret.mult = 1
    else
      error('Cannot convert '..tostring(arg)..' to rgbm')
    end
  else
    local num = tonumber(arg) or 0
    ret.r = num 
    ret.g = num
    ret.b = num
    ret.mult = 1
  end
  return ret
end

function __util.num_or(v, f)
  if type(v) ~= 'number' then return f end
  return v
end