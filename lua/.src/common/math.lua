-- To make things simpler, Lua’s math module is extended here

local function __clamp(x, min, max)
  return math.min(math.max(x, min), max)
end

-- Takes value with even 0…1 distribution and remaps it to recreate a distribution
-- similar to Gaussian’s one (with k≈0.52, default value). Lower to make bell more
-- compact, use a value above 1 to get some sort of inverse distibution.
function math.gaussianAdjustment(x, k)
  -- https://jsfiddle.net/9g03fkxm/
  k = k or 0.52
  local i = 1 - math.abs(x * 2 - 1)
  if i <= 0 then return x end
  return math.lerp((1 - math.pow(i, k)) * math.sign(x - 0.5), x * 2 - 1, math.log(i) * k * 0.5) * 0.5 + 0.5
end

-- Builds a list of points (vec2) arranged in a circle with poisson distribution.
local poissonData = __bound_array(ffi.typeof('vec2'), nil)
function math.poissonSamplerCircle(size)
  ffi.C.lj_poissonsampler_circle(poissonData, size)
  local result = {}
  for i = 1, #poissonData do
    result[i] = poissonData:get(i)
  end
  poissonData:clear()
  return result
end

-- …N functions are meant to work with numbers only, slightly faster
math.clampN = __clamp
function math.saturateN(x) return math.min(math.max(x, 0), 1) end

-- …V functions are meant to work with vectors only, slightly faster
function math.clampV(x, min, max) return x:clone():clamp(min, max) end
function math.saturateV(x, min, max) return x:clone():saturate() end

-- Universal version
function math.clamp(x, min, max)
  if type(x) == 'number' then
    return __clamp(x, min, max)
  end

  local bn = type(min) == 'number'
  local bt = type(max) == 'number'
  if bn and bt then
    if vec3.isvec3(x) then 
      return vec3(__clamp(x.x, min, max), __clamp(x.y, min, max), __clamp(x.z, min, max)) 
    end  
    if vec2.isvec2(x) then 
      return vec2(__clamp(x.x, min, max), __clamp(x.y, min, max)) 
    end  
    if vec4.isvec4(x) then 
      return vec4(__clamp(x.x, min, max), __clamp(x.y, min, max), __clamp(x.z, min, max), __clamp(x.w, min, max)) 
    end  
    if rgb.isrgb(x) then 
      return rgb(__clamp(x.r, min, max), __clamp(x.g, min, max), __clamp(x.b, min, max)) 
    end  
    if rgbm.isrgbm(x) then 
      return rgbm(__clamp(x.r, min, max), __clamp(x.g, min, max), __clamp(x.b, min, max), __clamp(x.mult, min, max)) 
    end
  end

  local b = bn and min or x:type().new(min) 
  local t = bt and max or x:type().new(max) 

  if vec3.isvec3(x) then 
    return vec3(__clamp(x.x, b.x, t.x), __clamp(x.y, b.y, t.y), __clamp(x.z, b.z, t.z)) 
  end
  if vec2.isvec2(x) then 
    return vec2(__clamp(x.x, b.x, t.x), __clamp(x.y, b.y, t.y)) 
  end
  if vec4.isvec4(x) then 
    return vec4(__clamp(x.x, b.x, t.x), __clamp(x.y, b.y, t.y), __clamp(x.z, b.z, t.z), __clamp(x.w, b.w, t.w)) 
  end
  if rgb.isrgb(x) then 
    return rgb(__clamp(x.r, b.r, t.r), __clamp(x.g, b.g, t.g), __clamp(x.b, b.b, t.b)) 
  end
  if rgbm.isrgbm(x) then 
    return rgbm(__clamp(x.r, b.r, t.r), __clamp(x.g, b.g, t.g), __clamp(x.b, b.b, t.b), __clamp(x.mult, b.mult, t.mult)) 
  end

  return __clamp(x, min, max)
end

function math.sign(x) if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end end
function math.lerp(x, y, s) return x * (1 - s) + y * s end
function math.lerpInvSat(s, min, max) return math.saturate((s - min) / (max - min)) end
function math.saturate(x) return math.clamp(x, 0, 1) end
function math.smoothstep(x) return x * x * (3 - 2 * x) end
function math.smootherstep(x) return x * x * x * (x * (x * 6 - 15) + 10) end

function math.normalize(x) return x:clone():normalize() end
function math.cross(x, y) return x:clone():cross(y) end
function math.dot(x, y) return x:dot(y) end
function math.angle(x, y) return x:angle(y) end
function math.distance(x, y) return x:distance(y) end
function math.project(x, y) return x:clone():project(y) end
function math.radians(x) return x * math.pi / 180 end
function math.degress(x) return x * 180 / math.pi end
function math.isNaN(x) return x ~= x end
math.NaN = 0/0

function math.lagMult(lag, dt)
  return math.saturateN((1.0 - lag) * dt * 60);
end

function math.applyLag(v, target, lag, dt) 
  if lag <= 0 then return target end
  return v + (target - v) * math.lagMult(lag, dt)
end
