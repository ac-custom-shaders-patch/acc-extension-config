ffi.cdef [[
  typedef struct { float x, y; } vec2;
  typedef struct { float x, y, z; } vec3;
  typedef struct { float x, y, z, w; } vec4;
  typedef struct { float r, g, b; } rgb;
  typedef struct { float h, s, v; } hsv;
  typedef struct { union { struct { float r, g, b; }; struct { rgb rgb; }; }; float mult; } rgbm;
  typedef struct { float x, y, z, w; } quat;
]]

local _vec2 = require './ac_primitive_vec2'
local _vec3 = require './ac_primitive_vec3'
local _vec4 = require './ac_primitive_vec4'
local _rgb = require './ac_primitive_rgb'
local _hsv = require './ac_primitive_hsv'
local _rgbm = require './ac_primitive_rgbm'
local _quat = require './ac_primitive_quat'

vec2 = ffi.metatype('vec2', _vec2.type)
vec3 = ffi.metatype('vec3', _vec3.type)
vec4 = ffi.metatype('vec4', _vec4.type)
rgb = ffi.metatype('rgb', _rgb.type)
hsv = ffi.metatype('hsv', _hsv.type)
rgbm = ffi.metatype('rgbm', _rgbm.type)
quat = ffi.metatype('quat', _quat.type)
smoothing = require './ac_smoothing'

_vec2.init()
_vec3.init()
_vec4.init()
_rgb.init()
_hsv.init()
_rgbm.init()
_quat.init()