-- Helper module for internal use, please do not use it in your code. Mainly meant
-- for ensure types are correct when being passed to C++.

ffi.cdef[[
typedef struct {
  union {
    char ins[16];
    const char* buf;
  };
  uint64_t p1;
  uint64_t p2;
} lua_string_ref;

typedef struct {
  int key;
  int phase;
  lua_string_ref data;
  uint64_t data_hash;
} lua_string_cached_ref;
]]

__util = {}

function __util.strref(value)
  if value == nil then return nil end
  local ref = value[0]
  return ffi.string(ref.p2 >= 0x10 and ref.buf or ref.ins, ref.p1)
end

local __mtstrcref = {
  __index = {
    get = function(self, value)
      if value == nil then return nil end
      local r = value[0]
      local c = self.cache[r.key]
      if c ~= nil and c.phase == r.phase then return c.str end
      local s = ffi.string(r.data.p2 >= 0x10 and r.data.buf or r.data.ins, r.data.p1)
      if c ~= nil then
        c.phase = r.phase
        c.str = s
      else
        self.cache[r.key] = { phase = r.phase, str = s }
      end
      return s
    end
  }
}

function __util.strcref()
  return setmetatable({ cache = {} }, __mtstrcref)
end

function __util.str(value)
  return value ~= nil and tostring(value) or ""
end

function __util.str_opt(value)
  if value ~= nil then return tostring(value) end
  return nil
end

function __util.cast_enum(value, min, max, def)
  if value == nil then return def end
  local i = math.floor(tonumber(value))
  if i < min or i > max then return def end
  return i
end

function __util.cast_vec2(ret, arg, def)
  if ffi.istype('vec2', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to vec2')
  else
    local num = tonumber(arg) or 0
    ret.x = num 
    ret.y = num
  end
  return ret
end

function __util.cast_vec3(ret, arg, def)
  if ffi.istype('vec3', arg) then return arg end
  if arg == nil then return def end
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

function __util.cast_vec4(ret, arg, def)
  if ffi.istype('vec4', arg) then return arg end
  if arg == nil then return def end
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

function __util.cast_rgb(ret, arg, def)
  if ffi.istype('rgb', arg) then return arg end
  if arg == nil then return def end
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

function __util.cast_rgbm(ret, arg, def)
  if ffi.istype('rgbm', arg) then return arg end
  if arg == nil then return def end
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

function __util.cast_mat3x3(ret, arg, def)
  if ffi.istype('mat3x3', arg) then return arg end
  if arg == nil then return def end
  if type(arg) == 'cdata' then
    error('Cannot convert '..tostring(arg)..' to mat3x3')
  else
    local num = tonumber(arg) or 0
    ret.row1:set(num, num, num)
    ret.row2:set(num, num, num)
    ret.row3:set(num, num, num)
  end
  return ret
end

function __util.num_or(v, f)
  if type(v) ~= 'number' then return f end
  return v
end

function __util.secure_refbool(arg, def)
  if ffi.istype('refbool', arg) then return arg end
  def.value = arg and true or false
  return def
end

function __util.secure_refnumber(arg, def)
  if ffi.istype('refnumber', arg) then return arg end
  def.value = arg and true or false
  return def
end

local __u_def_vec2 = vec2()
function __util.ensure_vec2(arg)
  return ffi.istype('vec2', arg) and arg or __u_def_vec2
end

local __u_def_vec3 = vec3()
function __util.ensure_vec3(arg)
  return ffi.istype('vec3', arg) and arg or __u_def_vec3
end

local __u_def_vec4 = vec4()
function __util.ensure_vec4(arg)
  return ffi.istype('vec4', arg) and arg or __u_def_vec4
end

local __u_def_rgb = rgb()
function __util.ensure_rgb(arg)
  return ffi.istype('rgb', arg) and arg or __u_def_rgb
end

local __u_def_rgbm = rgbm()
function __util.ensure_rgbm(arg)
  return ffi.istype('rgbm', arg) and arg or __u_def_rgbm
end

-- a cheap way to get simple replies from asynchronous calls
local __replyListeners = {}
local __lastReplyID = 0
function __util.expectReply(callback)
  if not callback then return 0 end
  local replyID = __lastReplyID + 1
  __lastReplyID = replyID
  table.insert(__replyListeners, { replyID = replyID, callback = callback })
  return replyID
end
function __processMessage(replyID, ...)
  for i = #__replyListeners, 1, -1 do
    local l = __replyListeners[i]
    if l.replyID == replyID then
      l.callback(...)
      table.remove(__replyListeners, i)
    end
  end
end
