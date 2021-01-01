local vtmp1
local vtmp2
local qtmp1
local qtmp2
local forward

return {
  init = function()
    vtmp1 = vec3()
    vtmp2 = vec3()
    qtmp1 = quat()
    qtmp2 = quat()
    forward = vec3(0, 0, -1)
  end,
  type = {
    __call = function(_, x, y, z, w)
      return setmetatable({ x = x, y = y, z = z, w = w }, quat)
    end,

    __tostring = function(q)
      return string.format('(%f, %f, %f, %f)', q.x, q.y, q.z, q.w)
    end,

    __add = function(q, r) return q:add(r, quat()) end,
    __sub = function(q, r) return q:sub(r, quat()) end,
    __mul = function(q, r)
      if quat.isquat(r) then return q:mul(r, quat())
      elseif vec3.isvec3(r) then return r:rotate(q, vec3())
      else error('quats can only be multiplied by quats and vec3s') end
    end,
    __unm = function(q) return q:scale(-1) end,
    __len = function(q) return q:length() end,

    __index = {
      type = function(x) return quat end,
      isquat = function(x) return ffi and ffi.istype('quat', x) or getmetatable(x) == quat end,
      tmp = function() return qtmp2 end,

      clone = function(q)
        return quat(q.x, q.y, q.z, q.w)
      end,

      unpack = function(q)
        return q.x, q.y, q.z, q.w
      end,

      set = function(q, x, y, z, w)
        if quat.isquat(x) then x, y, z, w = x.x, x.y, x.z, x.w end
        q.x = x
        q.y = y
        q.z = z
        q.w = w
        return q
      end,

      fromAngleAxis = function(angle, x, y, z)
        return quat():setAngleAxis(angle, x, y, z)
      end,

      setAngleAxis = function(q, angle, x, y, z)
        if vec3.isvec3(x) then x, y, z = x.x, x.y, x.z end
        local s = math.sin(angle * .5)
        local c = math.cos(angle * .5)
        q.x = x * s
        q.y = y * s
        q.z = z * s
        q.w = c
        return q
      end,

      getAngleAxis = function(q)
        if q.w > 1 or q.w < -1 then q:normalize() end
        local s = math.sqrt(1 - q.w * q.w)
        s = s < .0001 and 1 or 1 / s
        return 2 * math.acos(q.w), q.x * s, q.y * s, q.z * s
      end,

      between = function(u, v)
        return quat():setBetween(u, v)
      end,

      setBetween = function(q, u, v)
        local dot = u:dot(v)
        if dot > .99999 then
          q.x, q.y, q.z, q.w = 0, 0, 0, 1
          return q
        elseif dot < -.99999 then
          vtmp1.x, vtmp1.y, vtmp1.z = 1, 0, 0
          vtmp1:cross(u)
          if #vtmp1 < .00001 then
            vtmp1.x, vtmp1.y, vtmp1.z = 0, 1, 0
            vtmp1:cross(u)
          end
          vtmp1:normalize()
          return q:setAngleAxis(math.pi, vtmp1)
        end

        q.x, q.y, q.z = u.x, u.y, u.z
        vec3.cross(q, v)
        q.w = 1 + dot
        return q:normalize()
      end,

      fromDirection = function(x, y, z)
        return quat():setDirection(x, y, z)
      end,

      setDirection = function(q, x, y, z)
        if vec3.isvec3(x) then x, y, z = x.x, x.y, x.z end
        vtmp2.x, vtmp2.y, vtmp2.z = x, y, z
        return q:setBetween(forward, vtmp2)
      end,

      add = function(q, r, out)
        out = out or q
        out.x = q.x + r.x
        out.y = q.y + r.y
        out.z = q.z + r.z
        out.w = q.w + r.w
        return out
      end,

      sub = function(q, r, out)
        out = out or q
        out.x = q.x - r.x
        out.y = q.y - r.y
        out.z = q.z - r.z
        out.w = q.w - r.w
        return out
      end,

      mul = function(q, r, out)
        out = out or q
        local qx, qy, qz, qw = q:unpack()
        local rx, ry, rz, rw = r:unpack()
        out.x = qx * rw + qw * rx + qy * rz - qz * ry
        out.y = qy * rw + qw * ry + qz * rx - qx * rz
        out.z = qz * rw + qw * rz + qx * ry - qy * rx
        out.w = qw * rw - qx * rx - qy * ry - qz * rz
        return out
      end,

      scale = function(q, s, out)
        out = out or q
        out.x = q.x * s
        out.y = q.y * s
        out.z = q.z * s
        out.w = q.w * s
        return out
      end,

      length = function(q)
        return math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)
      end,

      normalize = function(q, out)
        out = out or q
        local len = q:length()
        return len == 0 and q or q:scale(1 / len, out)
      end,

      lerp = function(q, r, t, out)
        out = out or q
        r:scale(t, qtmp1)
        q:scale(1 - t, out)
        return out:add(qtmp1)
      end,

      slerp = function(q, r, t, out)
        out = out or q

        local dot = q.x * r.x + q.y * r.y + q.z * r.z + q.w * r.w
        if dot < 0 then
          dot = -dot
          r:scale(-1)
        end

        if 1 - dot < .0001 then
          return q:lerp(r, t, out)
        end

        local theta = math.acos(dot)
        q:scale(math.sin((1 - t) * theta), out)
        r:scale(math.sin(t * theta), qtmp1)
        return out:add(qtmp1):scale(1 / math.sin(theta))
      end
    }
  }
}