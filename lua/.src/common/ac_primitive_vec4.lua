local vtmp1
local vtmp2
return {
  init = function()
    vtmp1 = vec4()
    vtmp2 = vec4()
  end,
  type = {
    __call = function(_, x, y, z, w)
      return setmetatable({ x = x or 0, y = y or 0, z = z or 0, w = w or 0 }, vec4)
    end,

    __tostring = function(v)
      return string.format('(%f, %f, %f, %f)', v.x, v.y, v.z, v.w)
    end,

    __add = function(v, u) if type(v) == 'number' then return vec4(v, v, v, v):add(u, vec4()) end return v:add(u, vec4()) end,
    __sub = function(v, u) if type(v) == 'number' then return vec4(v, v, v, v):sub(u, vec4()) end return v:sub(u, vec4()) end,
    __mul = function(v, u)
      if type(v) == 'number' then return vec4(v, v, v, v) * u end 
      if vec4.isvec4(u) then return v:mul(u, vec4())
      elseif type(u) == 'number' then return v:scale(u, vec4())
      else error('vec4s can only be multiplied by vec4s and numbers') end
    end,
    __div = function(v, u)
      if type(v) == 'number' then return vec4(v, v, v, v) / u end 
      if vec4.isvec4(u) then return v:div(u, vec4())
      elseif type(u) == 'number' then return v:scale(1 / u, vec4())
      else error('vec4s can only be divided by vec4s and numbers') end
    end,
    __pow = function(v, u)
      if type(v) == 'number' then return vec4(v, v, v, v) ^ u end 
      if vec4.isvec4(u) then return v:pow(u, vec4())
      elseif type(u) == 'number' then return vec4(v.x ^ u, v.y ^ u, v.z ^ u, v.w ^ u)
      else error('vec4s can only be raised to power of vec4s and numbers') end
    end,
    __unm = function(v) return vec4(-v.x, -v.y, -v.z, -v.w) end,
    __len = function(v) return v:length() end,
    __eq = function(v, o) return o ~= nil and v.x == o.x and v.y == o.y and v.z == o.z and v.w == o.w end,
    __index = {
      new = function(x, y, z, w) 
        if vec3.isvec3(x) then return vec4(x.x, x.y, x.z, w or 0) end
        if vec3.isvec3(y) then return vec4(x or 0, y.x, y.y, y.z) end
        if type(x) ~= 'number' then x = 0 end
        if type(y) ~= 'number' then y = x end
        if type(z) ~= 'number' then z = y end
        if type(w) ~= 'number' then w = z end
        return vec4(x, y, z, w) 
      end,

      isvec4 = function(x) return ffi.istype('vec4', x) end,
      tmp = function() return vtmp2 end,
      type = function(x) return vec4 end,
      clone = function(v) return vec4(v.x, v.y, v.z, v.w) end,
      unpack = function(v) return v.x, v.y, v.z, v.w end,

      set = function(v, x, y, z, w)
        if vec4.isvec4(x) then x, y, z, w = x.x, x.y, x.z, x.w
        elseif y == nil then y = x z = x w = x end
        v.x = x
        v.y = y
        v.z = z
        v.w = w
        return v
      end,

      setLerp = function(v, a, b, k)
        v.x = math.lerp(a.x, b.x, k)
        v.y = math.lerp(a.y, b.y, k)
        v.z = math.lerp(a.z, b.z, k)
        v.w = math.lerp(a.w, b.w, k)
        return v
      end,

      add = function(v, u, out)
        out = out or v
        if vec4.isvec4(u) then 
          out.x = v.x + u.x
          out.y = v.y + u.y
          out.z = v.z + u.z
          out.w = v.w + u.w
        else
          out.x = v.x + u
          out.y = v.y + u
          out.z = v.z + u
          out.w = v.w + u
        end
        return out
      end,

      sub = function(v, u, out)
        out = out or v
        if vec4.isvec4(u) then 
          out.x = v.x - u.x
          out.y = v.y - u.y
          out.z = v.z - u.z
          out.w = v.w - u.w
        else
          out.x = v.x - u
          out.y = v.y - u
          out.z = v.z - u
          out.w = v.w - u
        end
        return out
      end,

      mul = function(v, u, out)
        out = out or v
        out.x = v.x * u.x
        out.y = v.y * u.y
        out.z = v.z * u.z
        out.w = v.w * u.w
        return out
      end,

      div = function(v, u, out)
        out = out or v
        out.x = v.x / u.x
        out.y = v.y / u.y
        out.z = v.z / u.z
        out.w = v.w / u.w
        return out
      end,

      pow = function(v, u, out)
        out = out or v
        if type(u) == 'number' then
          out.x = v.x ^ u
          out.y = v.y ^ u
          out.z = v.z ^ u
          out.w = v.w ^ u
        else
          out.x = v.x ^ u.x
          out.y = v.y ^ u.y
          out.z = v.z ^ u.z
          out.w = v.w ^ u.w
        end
        return out
      end,

      scale = function(v, s, out)
        out = out or v
        out.x = v.x * s
        out.y = v.y * s
        out.z = v.z * s
        out.w = v.w * s
        return out
      end,

      saturate = function(v, out)
        out = out or v
        out.x = math.saturateN(v.x)
        out.y = math.saturateN(v.y)
        out.z = math.saturateN(v.z)
        out.w = math.saturateN(v.w)
        return out
      end,

      clamp = function(v, min, max, out)
        out = out or v
        out.x = math.clampN(v.x, min.x, max.x)
        out.y = math.clampN(v.y, min.y, max.y)
        out.z = math.clampN(v.z, min.z, max.z)
        out.w = math.clampN(v.w, min.w, max.w)
        return out
      end,

      length = function(v) return math.sqrt(v:lengthSquared()) end,
      lengthSquared = function(v) return v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w end,
      distance = function(v, u) return vec4.sub(v, u, vtmp1):length() end,
      distanceSquared = function(v, u) return vec4.sub(v, u, vtmp1):lengthSquared() end,
      closerToThan = function(v, u, d) return v:distanceSquared(u) < d * d end,
      angle = function(v, u) return math.acos(v:dot(u) / (v:length() + u:length())) end,
      dot = function(v, u) return v.x * u.x + v.y * u.y + v.z * u.z + v.w * u.w end,

      normalize = function(v, out)
        out = out or v
        local len = v:length()
        return len == 0 and v or v:scale(1 / len, out)
      end,

      lerp = function(v, u, t, out)
        out = out or v
        out.x = v.x + (u.x - v.x) * t
        out.y = v.y + (u.y - v.y) * t
        out.z = v.z + (u.z - v.z) * t
        out.w = v.w + (u.w - v.w) * t
        return out
      end,

      project = function(v, u, out)
        out = out or v
        local unorm = vtmp1
        u:normalize(unorm)
        local dot = v:dot(unorm)
        out.x = unorm.x * dot
        out.y = unorm.y * dot
        out.z = unorm.z * dot
        out.w = unorm.w * dot
        return out
      end
    }
  }
}