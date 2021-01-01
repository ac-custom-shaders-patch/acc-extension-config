local vtmp1
local vtmp2
return {
  init = function()
    vtmp1 = vec2()
    vtmp2 = vec2()
  end,
  type = {
    __call = function(_, x, y)
      return setmetatable({ x = x or 0, y = y or 0 }, vec2)
    end,

    __tostring = function(v)
      return string.format('(%f, %f)', v.x, v.y)
    end,

    __add = function(v, u) if type(v) == 'number' then return vec2(v, v):add(u, vec2()) end return v:add(u, vec2()) end,
    __sub = function(v, u) if type(v) == 'number' then return vec2(v, v):sub(u, vec2()) end return v:sub(u, vec2()) end,
    __mul = function(v, u)
      if type(v) == 'number' then return vec2(v, v) * u end 
      if vec2.isvec2(u) then return v:mul(u, vec2())
      elseif type(u) == 'number' then return v:scale(u, vec2())
      else error('vec2s can only be multiplied by vec2s and numbers') end
    end,
    __div = function(v, u)
      if type(v) == 'number' then return vec2(v, v) / u end 
      if vec2.isvec2(u) then return v:div(u, vec2())
      elseif type(u) == 'number' then return v:scale(1 / u, vec2())
      else error('vec2s can only be divided by vec2s and numbers') end
    end,
    __pow = function(v, u)
      if type(v) == 'number' then return vec2(v, v) ^ u end 
      if vec2.isvec2(u) then return v:pow(u, vec2())
      elseif type(u) == 'number' then return vec2(v.x ^ u, v.y ^ u)
      else error('vec2s can only be raised to power of vec2s and numbers') end
    end,
    __unm = function(v) return vec2(-v.x, -v.y) end,
    __len = function(v) return v:length() end,
    __eq = function(v, o) return o ~= nil and v.x == o.x and v.y == o.y end,
    __index = {
      new = function(x, y) 
        if type(x) ~= 'number' then x = 0 end
        if type(y) ~= 'number' then y = x end
        return vec2(x, y)
      end,

      isvec2 = function(x) return ffi.istype('vec2', x) end,
      tmp = function() return vtmp2 end,
      type = function(x) return vec2 end,
      clone = function(v) return vec2(v.x, v.y) end,
      unpack = function(v) return v.x, v.y end,

      set = function(v, x, y)
        if vec2.isvec2(x) then x, y = x.x, x.y
        elseif y == nil then y = x end
        v.x = x
        v.y = y
        return v
      end,

      setLerp = function(v, a, b, k)
        v.x = math.lerp(a.x, b.x, k)
        v.y = math.lerp(a.y, b.y, k)
        return v
      end,

      add = function(v, u, out)
        out = out or v
        if vec2.isvec2(u) then 
          out.x = v.x + u.x
          out.y = v.y + u.y
        else
          out.x = v.x + u
          out.y = v.y + u
        end
        return out
      end,

      sub = function(v, u, out)
        out = out or v
        if vec2.isvec2(u) then 
          out.x = v.x - u.x
          out.y = v.y - u.y
        else
          out.x = v.x - u
          out.y = v.y - u
        end
        return out
      end,

      mul = function(v, u, out)
        out = out or v
        out.x = v.x * u.x
        out.y = v.y * u.y
        return out
      end,

      div = function(v, u, out)
        out = out or v
        out.x = v.x / u.x
        out.y = v.y / u.y
        return out
      end,

      pow = function(v, u, out)
        out = out or v
        if type(u) == 'number' then
          out.x = v.x ^ u
          out.y = v.y ^ u
        else
          out.x = v.x ^ u.x
          out.y = v.y ^ u.y
        end
        return out
      end,

      scale = function(v, s, out)
        out = out or v
        out.x = v.x * s
        out.y = v.y * s
        return out
      end,

      saturate = function(v, out)
        out = out or v
        out.x = math.saturateN(v.x)
        out.y = math.saturateN(v.y)
        return out
      end,

      clamp = function(v, min, max, out)
        out = out or v
        out.x = math.clampN(v.x, min.x, max.x)
        out.y = math.clampN(v.y, min.y, max.y)
        return out
      end,

      length = function(v) return math.sqrt(v:lengthSquared()) end,
      lengthSquared = function(v) return v.x * v.x + v.y * v.y end,
      distance = function(v, u) return vec2.sub(v, u, vtmp1):length() end,
      distanceSquared = function(v, u) return vec2.sub(v, u, vtmp1):lengthSquared() end,
      closerToThan = function(v, u, d) return v:distanceSquared(u) < d * d end,
      angle = function(v, u) return math.acos(v:dot(u) / (v:length() + u:length())) end,
      dot = function(v, u) return v.x * u.x + v.y * u.y end,

      normalize = function(v, out)
        out = out or v
        local len = v:length()
        return len == 0 and v or v:scale(1 / len, out)
      end,

      lerp = function(v, u, t, out)
        out = out or v
        out.x = v.x + (u.x - v.x) * t
        out.y = v.y + (u.y - v.y) * t
        return out
      end,

      project = function(v, u, out)
        out = out or v
        local unorm = vtmp1
        u:normalize(unorm)
        local dot = v:dot(unorm)
        out.x = unorm.x * dot
        out.y = unorm.y * dot
        return out
      end
    }
  }
}