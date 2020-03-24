local function __clamp(x, min, max)
  return math.min(math.max(x, min), max)
end

math.clampN = __clamp
math.saturateN = function(x) 
  return math.min(math.max(x, 0), 1)
end
math.clampV = function(x, min, max) return x:clone():clamp(min, max) end
math.saturateV = function(x, min, max) return x:clone():saturate() end

math.clamp = function (x, min, max)
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

math.sign = function (x) if x > 0 then return 1 elseif x < 0 then return -1 else return 0 end end
math.lerp = function (x, y, s) return x * (1 - s) + y * s end
math.lerpInvSat = function (s, min, max) return math.saturate((s - min) / (max - min)) end
math.saturate = function (x) return math.clamp(x, 0, 1) end
math.smoothstep = function (x) return x * x * (3 - 2 * x) end
math.smootherstep = function (x) return x * x * x * (x * (x * 6 - 15) + 10) end

math.normalize = function (x) return x:clone():normalize() end
math.cross = function (x, y) return x:clone():cross(y) end
math.dot = function (x, y) return x:dot(y) end
math.angle = function (x, y) return x:angle(y) end
math.distance = function (x, y) return x:distance(y) end
math.project = function (x, y) return x:clone():project(y) end
math.radians = function (x) return x * math.pi / 180 end
math.degress = function (x) return x * 180 / math.pi end

math.lagMult = function (lag, dt)
  return math.saturate((1.0 - lag) * dt * 60);
end

math.applyLag = function (v, target, lag, dt) 
  if lag <= 0 then return target end
  return v + (target - v) * math.lagMult(lag, dt)
end

local poissonData = __bound_array(ffi.typeof('vec2'), nil)
math.poissonSamplerCircle = function (size)
  ffi.C.lj_poissonsampler_circle(poissonData, size)
  local result = {}
  for i = 1, #poissonData do
    result[i] = poissonData:get(i)
  end
  poissonData:clear()
  return result
end