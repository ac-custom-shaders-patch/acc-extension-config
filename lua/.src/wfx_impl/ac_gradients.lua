ffi.cdef [[ 
typedef struct {
  vec3 direction;
  float sizeFull, sizeStart;
  bool isAdditive;
  bool isIncludedInCalculate;

  struct {
    rgb color;
    float exponent;
  };
} extra_gradient;
]]
ffi.metatype('extra_gradient', { __index = {} })
ac.SkyExtraGradient = function (t) 
  local r = ffi.C.lj_extragradient_new__impl() 
  -- r.temperature = type(t) == 'table' and t['temperature'] or __util.num_or(t, 6500.0)
  -- r.luminance = type(t) == 'table' and t['luminance'] or 0.0
  return ffi.gc(r, ffi.C.lj_extragradient_gc__impl) 
end