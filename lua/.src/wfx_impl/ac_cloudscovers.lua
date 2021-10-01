ffi.cdef [[
typedef struct {
  rgb colorMultiplier;
  float opacityMultiplier;

  rgb colorExponent;
  float opacityExponent;

  float opacityCutoff;
  float opacityFade;
  float texOffsetX;
  float texRemapY;

  float fogMultZenith;
  float fogMultDelta;
  float fogRangeInv;
  float fogMultExponent;

  float shadowRadius;
  float shadowOpacityMultiplier;
} cloudscover;
]]

-- ac.SkyCloudsCover, thing to draw clouds panoramas onto sky
ffi.metatype('cloudscover', {
  __index = function(self, key)
    if key == 'setTexture' then return ffi.C.lj_cloudscover_set_texture__impl end
    if key == 'getTextureState' then return ffi.C.lj_cloudscover_get_texture_state__impl end
    if key == 'setFogParams' then return function (s, fogHorizon, fogZenith, fogExponent, fogRangeMult)
      s.fogMultZenith = tonumber(fogZenith) or 1
      s.fogMultDelta = (tonumber(fogHorizon) or 1) - s.fogMultZenith
      s.fogRangeInv = 1 / math.max(0.01, tonumber(fogRangeMult) or 1)
      s.fogMultExponent = tonumber(fogExponent) or 1
    end end
    error('SkyCloudsCover has no member called \'' .. key .. '\'')
  end,
  __newindex = function(self, key, value)
    error('SkyCloudsCover has no member called \'' .. key .. '\'')
  end,
})
ac.SkyCloudsCover = function () return ffi.gc(ffi.C.lj_cloudscover_new__impl(), ffi.C.lj_cloudscover_gc__impl) end
