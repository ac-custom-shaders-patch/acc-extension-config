ac = {}

function __sane(x)
  if type(x) == 'number' then 
    if not (x > -math.huge and x < math.huge) then
      error('finite value is required, got: '..x)
    end
  elseif vec2.isvec2(x) then
    __sane(x.x) __sane(x.y)
  elseif vec3.isvec3(x) then
    __sane(x.x) __sane(x.y) __sane(x.z)
  elseif vec4.isvec4(x) then
    __sane(x.x) __sane(x.y) __sane(x.z) __sane(x.w)
  elseif rgb.isrgb(x) then
    __sane(x.r) __sane(x.g) __sane(x.b)
  end
  return x
end

ac.__sane = __sane
ac.__sane_rgb = function(x)
  if type(x) == 'number' then
    __sane(x)
    return rgb(x, x, x)
  elseif rgb.isrgb(x) then
    __sane(x.r) __sane(x.g) __sane(x.b)
    return x
  else
    return rgb.new(x)
  end
end

ac.skipSaneChecks = function()
  ac.__sane = function(x) return x end
  ac.__sane_rgb = function(x) 
    if type(x) == 'number' then
      return rgb(x, x, x)
    elseif rgb.isrgb(x) then
      return x
    else
      return rgb.new(x)
    end
  end
end

function __num_fallback(v, f)
  if type(v) ~= 'number' then return f end
  return v
end

require 'ffi'
require './common/ac_primitive'
require './common/vector'
require './common/ac_enums'
require './common/math'
require './common/ac_audio'

ffi.cdef [[
DEFINITIONS
]]
SANE
EXPORT
