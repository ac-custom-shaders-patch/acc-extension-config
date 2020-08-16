local forward
local vtmp1
local vtmp2
local qtmp1

ffi.cdef [[
  typedef struct { float x, y; } vec2;
  typedef struct { float x, y, z; } vec3;
  typedef struct { float x, y, z, w; } vec4;
  typedef struct { float r, g, b; } rgb;
  typedef struct { float h, s, v; } hsv;
  typedef struct { union { struct { float r, g, b; }; struct { rgb rgb; }; }; float mult; } rgbm;
  typedef struct { float x, y, z, w; } quat;
]]

vec2 = ffi.metatype('vec2', require './ac_primitive_vec2')
vec3 = ffi.metatype('vec3', require './ac_primitive_vec3')
vec4 = ffi.metatype('vec4', require './ac_primitive_vec4')
rgb = ffi.metatype('rgb', require './ac_primitive_rgb')
hsv = ffi.metatype('hsv', require './ac_primitive_hsv')
rgbm = ffi.metatype('rgbm', require './ac_primitive_rgbm')
quat = ffi.metatype('quat', require './ac_primitive_quat')
smoothing = require './ac_smoothing'

local forward = vec3(0, 0, -1)
local vtmp1 = vec3()
local vtmp2 = vec3()
local qtmp1 = quat()
