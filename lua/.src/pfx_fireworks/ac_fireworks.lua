ffi.cdef [[ 
typedef struct {
  int __id;
  vec3 pos;
  vec3 velocity;

  float sparkingIntensity;
  float sparkingIntensityShot;
  float sparkingLifespan;
  float sparkingSize;
  float sparkingStretch;
  float sparkingSpeedMin;
  float sparkingSpeedMax;
  vec3 sparkingDir;
  float sparkingDirSpreadXZ;
  float sparkingDirSpreadY;
  rgb sparkingColorA;
  rgb sparkingColorB;
  float sparkingPosSpread;
  int sparkingSpreadFlags;
  float sparkingLifespanSpread;
  float sparkingSizeSpread;
  float sparkingBrightness;

  vec3 glowOffset;
  float glowBrightness;
  float glowSize;
  rgb glowColor;

  vec3 smokingPosOffset;
  float smokingIntensity;
  float smokingIntensityShot;
  float smokingLifespan;
  float smokingSize;
  float smokingOpacity;
  float smokingSpeedRandomMin;
  float smokingSpeedRandomMax;
  rgb smokingColor;
  float smokingPosSpread;
  vec3 smokingVelocityOffset;

  float pushingForce;
} firework;
]]

ffi.metatype('firework', { 
  __index = {}
})
ac.Firework = function (t) 
  local created = ffi.C.lj_firework_new()
  return ffi.gc(created, ffi.C.lj_firework_gc)
end