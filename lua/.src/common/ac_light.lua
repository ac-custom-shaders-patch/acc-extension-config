-- __source 'lua/api_light.cpp'
-- __allow 'light'

-- require './ac_render'

-- ac.LightType = __enum({ cpp = 'light_type' }, {
--   Point = 0,
--   Spot = 1,
--   Line = 2 
-- })

-- ffi.cdef [[ 
-- typedef struct {
--   void* host_;
--   void* nativeLight_;

--   light_type lightType;
--   vec3 position;
--   rgb color;
--   float specularMultiplier;
--   float diffuseConcentration;
--   float singleFrequency;
--   float range;
--   float rangeGradientOffset;
--   float fadeAt;
--   float fadeSmooth;

--   vec3 direction;
--   float spot;
--   float spotSharpness;
  
--   vec3 linePos;
--   rgb lineColor;
  
--   bool volumetricLight;
--   bool skipLightMap;
--   bool affectsCars;
--   bool showInReflections;
--   float longSpecular;
  
--   bool shadows;
--   bool shadowsStatic;
--   bool shadowsHalfResolution;
  
--   float shadowsSpot;
--   float shadowsRange;
--   float shadowsBoost;
--   float shadowsExponentialFactor;
--   float shadowsClipPlane;
--   float shadowsClipSphere;
--   AC::CullMode shadowsCullMode;
--   vec3 shadowsOffset;
-- } lightsource;
-- ]]

-- ac.LightSource = function (name, lightType, pos) 
--   local created = ffi.C.lj_lightsource_new(tostring(s), pos)
--   created.lightType = lightType 
--   return ffi.gc(created, ffi.C.lj_lightsource_gc) 
-- end

-- __audioEventKeepAlive = {}

-- ffi.metatype('lightsource', {
--   __index = function(self, key) 
--     if key == 'dispose' then return ffi.C.lj_lightsource_dispose end
--     error('LightSource has no member called \'' .. key .. '\'')
--   end,
--   __newindex = function(self, key, value) 
--     error('LightSource has no member called \'' .. key .. '\'')
--   end,
-- })