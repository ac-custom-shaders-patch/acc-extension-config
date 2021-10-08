__source 'lua/api_numlut.cpp'

ffi.cdef [[ 
typedef struct {
  uint columns;
  float* calculated;
} numlut;
]]

ac.LutCpp = function (data, hsvRows)
  local hsvRowsData = ''
  for i = 1, #hsvRows do
    hsvRowsData = i > 1 and (hsvRowsData .. ',' .. (hsvRows[i] - 1)) or (hsvRowsData .. (hsvRows[i] - 1))
  end
  local created = ffi.C.lj_numlut_new(data and tostring(data) or "", hsvRowsData)
  return ffi.gc(created, ffi.C.lj_numlut_gc)
end

ffi.metatype('numlut', { __index = {
  calculate = function (s, input)
    ffi.C.lj_numlut_calculate(s, input)
    local ret = {}
    for i = 1, s.columns do
      ret[i] = s.calculated[i - 1]
    end
    return ret
  end,
  calculateTo = function (s, output, input)
    ffi.C.lj_numlut_calculate(s, input)
    for i = 1, s.columns do
      output[i] = s.calculated[i - 1]
    end
    return output
  end
} })
ac.Lut = ac.LutCpp

local LuaJit_rgb = rgb()
local LuaJit_hsv = hsv()
local function LuaJit_rgbToHsv(data, i)
  LuaJit_rgb.r = data[i]
  LuaJit_rgb.g = data[i + 1]
  LuaJit_rgb.b = data[i + 2]
  data[i] = LuaJit_rgb:hue()
  data[i + 1] = LuaJit_rgb:saturation()
  data[i + 2] = LuaJit_rgb:value()
end
local function LuaJit_hsvToRgb(data, i)
  LuaJit_hsv.h = data[i]
  LuaJit_hsv.s = data[i + 1]
  LuaJit_hsv.v = data[i + 2]
  local r = LuaJit_hsv:rgb()
  data[i] = r.r
  data[i + 1] = r.g
  data[i + 2] = r.b
end
local function LuaJit_prepareData(data, rows, hsvRows)
  local hsvCount = #hsvRows
  for i = 1, rows do
    for j = 1, hsvCount do
      LuaJit_hsvToRgb(data[i].output, hsvRows[j])
    end
  end
end
local function LutJit_findLeft(rows, count_base, input)
  local count_search = count_base;
  local index = 0
  while count_search > 0 do
    local step = math.floor(count_search / 2)
    if rows[index + step + 1].input > input then
      count_search = step;
    else
      index = index + step + 1;
      count_search = count_search - step + 1;
    end
  end
  return rows[index > 0 and index or 1], rows[index < count_base and index + 1 or index]
end
local function LutJit_distanceToDiv(next, previous)
  return math.max(next.input - previous.input, 0.0000001)
end
local function LutJit_finalize(self, data)
  local hsvCount = #self.hsvRows
  for i = 1, hsvCount do
    LuaJit_rgbToHsv(data, self.hsvRows[i])
  end
end
local function LutJit_setSingle(self, output, item)
  local columns = self.columns
  for i = 1, columns do
    output[i] = item.output[i]
  end
  LutJit_finalize(self, output)
end
local function LutJit_setLerp(self, output, a, b, interpolation)
  local columns = self.columns
  for i = 1, columns do
    output[i] = math.lerp(a.output[i], b.output[i], interpolation)
  end
  LutJit_finalize(self, output)
end

ac.LutJit = {}
function ac.LutJit:new(o, data, hsvRows)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.data = o.data or data
  o.hsvRows = o.hsvRows or hsvRows or {}
  o.rows = #o.data
  o.columns = o.rows > 0 and #o.data[1].output or 0
  LuaJit_prepareData(o.data, o.rows, o.hsvRows)
  return o
end
function ac.LutJit:calculate(input)
  local ret = {}
  self:calculateTo(ret, input)
  return ret
end
function ac.LutJit:calculateTo(output, input)
  if self.rows == 0 then return {} end

  local previous, next = LutJit_findLeft(self.data, self.rows, input);
  if next.input == previous.input then
    LutJit_setSingle(self, output, next)
  else
    local interpolation = math.max(input - previous.input, 0) / LutJit_distanceToDiv(next, previous);
    LutJit_setLerp(self, output, previous, next, math.saturate(interpolation));
  end
  return output
end
