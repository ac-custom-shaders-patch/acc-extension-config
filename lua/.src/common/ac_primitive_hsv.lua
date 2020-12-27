local function hsvToRgb(t)
  local v = t.v 
  if t.s <= 0 then return rgb(v, v, v) end

  local e = t.h
  if e >= 360 then e = 0 end

  e = e / 60
  local i = math.floor(e)
  local u = e - i
  local p = v * (1 - t.s)
  local q = v * (1 - t.s * u)
  local t = v * (1 - t.s * (1 - u))

  if i == 0 then return rgb(v, t, p) end
  if i == 1 then return rgb(q, v, p) end
  if i == 2 then return rgb(p, v, t) end
  if i == 3 then return rgb(p, q, v) end
  if i == 4 then return rgb(t, p, v) end
  return rgb(v, p, q)
end

local vtmp1

return {
  init = function()
    vtmp1 = hsv()
  end,
  type = {
    __call = function(_, h, s, v)
      return setmetatable({ h = h or 0, s = s or 0, v = v or 0 }, hsv)
    end,

    __tostring = function(v)
      return string.format('(H=%f, S=%f, V=%f)', v.h, v.s, v.v)
    end,

    __eq = function(v, o) return o ~= nil and v.h == o.h and v.s == o.s and v.v == o.v end,
    __index = {
      new = function(h, s, v) 
        if type(h) ~= 'number' then h = 0 end
        if type(s) ~= 'number' then s = h end
        if type(v) ~= 'number' then v = s end
        return hsv(h, s, v) 
      end,

      ishsv = function(h) return ffi.istype('hsv', h) end,
      tmp = function() return vtmp1 end,
      type = function(x) return hsv end,
      clone = function(v) return hsv(v.h, v.s, v.v) end,
      unpack = function(v) return v.h, v.s, v.v end,

      set = function(v, h, s, v)
        if hsv.ishsv(h) then h, s, v = h.h, h.s, h.v end
        v.h = h
        v.s = s
        v.v = v
        return v
      end,

      rgb = hsvToRgb,
      toRgb = hsvToRgb,
    }
  }
}