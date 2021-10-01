__source 'lua/api_light.cpp'

require './ac_render'

ac.LightType = __enum({ cpp = 'light_type' }, {
  Regular = 1,
  Line = 2
})

ffi.cdef [[ 
typedef struct {
  void* host_;
  void* nativeLight0_;
  void* nativeLight1_;

  light_type lightType;
  vec3 position;
  rgb color;
  float specularMultiplier;
  float diffuseConcentration;
  float singleFrequency;
  float range;
  float rangeGradientOffset;
  float fadeAt;
  float fadeSmooth;

  vec3 direction;
  float spot;
  float spotSharpness;
  
  vec3 linePos;
  rgb lineColor;
  
  bool volumetricLight;
  bool skipLightMap;
  bool affectsCars;
  bool showInReflections;
  float longSpecular;
  
  bool shadows;
  bool shadowsStatic;
  bool shadowsHalfResolution;
  
  float shadowsSpot;
  float shadowsRange;
  float shadowsBoost;
  float shadowsExponentialFactor;
  float shadowsClipPlane;
  float shadowsClipSphere;
  AC::CullMode shadowsCullMode;
  vec3 shadowsOffset;
} lightsource;
]] 

local __lightSourceKeepAlive = {}

ac.LightSource = function (lightType, position)
  local created = ffi.C.lj_lightsource_new()
  created.lightType = lightType or ac.LightType.Regular
  if position ~= nil then created.position:set(lightType) end
  __lightSourceKeepAlive[#__lightSourceKeepAlive + 1] = created
  return ffi.gc(created, ffi.C.lj_lightsource_gc)
end

ffi.metatype('lightsource', {
  __index = function(self, key) 
    if key == 'keepAlive' then return function () end end
    if key == 'dispose' then return function (s) table.removeItem(__lightSourceKeepAlive, s) ffi.C.lj_lightsource_dispose(s) end end
    error('LightSource has no member called \'' .. key .. '\'')
  end,
  __newindex = function(self, key, value) 
    error('LightSource has no member called \'' .. key .. '\'')
  end,
})