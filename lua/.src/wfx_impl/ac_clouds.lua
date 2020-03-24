ffi.cdef [[
  typedef struct {     
    rgb ambientColor;
    float frontlitMultiplier;

    float frontlitDiffuseConcentration;
    float backlitExponent;
    float backlitOpacityExponent;
    float backlitOpacityMultiplier;

    float backlitMultiplier;
    float specularPower;
    float specularExponent;
    float fogMultiplier;

    rgb baseColor;
    rgb extraDownlit;
    float lightSaturation;
    float ambientConcentration;
    float contourExponent;
    float contourIntensity;
    bool useSceneAmbient;
  } cloud_material;

  typedef struct { 
    struct {
      int __id;
      vec3 position;
      vec2 size;
      rgb color;
      float opacity;
      float cutoff;
      float horizontalHeading;
      bool horizontal;
      bool flipHorizontal;
      bool flipVertical;
      bool customOrientation;
      bool noTilt;
      vec3 up;
      vec3 side;
    };
    
    vec2 noiseOffset;
    float shadowOpacity;
    bool useNoise;
    bool occludeGodrays;
    bool useCustomLightColor;
    bool useCustomLightDirection;
    uint8_t version;

    cloud_material* __material;
    rgb extraDownlit;
    rgb customLightColor;
    vec3 customLightDirection;

    vec2 procMap;
    vec2 procScale;
    vec2 procNormalScale;
    float procShapeShifting;
    float procSharpnessMult;

    vec2 texStart;
    vec2 texSize;
    float orderBy;
    float fogMultiplier;
  } cloud;

  typedef struct {
    float _pad;
		float perlinFrequency;
		int perlinOctaves;
		float worleyFrequency;
		float shapeMult;
		float shapeExp;
		float shape0Mip;
		float shape0Contribution;
		float shape1Mip;
		float shape1Contribution;
		float shape2Mip;
		float shape2Contribution;
  } cloud_map_settings;

  cloud* lj_cloud_new();
  void lj_cloud_set_texture(cloud* self, const char*);
  void lj_cloud_set_noise_texture(cloud* self, const char*);
  void lj_cloud_gc(cloud*);

  cloud_material* lj_cloudmaterial_new();
  void lj_cloudmaterial_gc(cloud_material*);
  
  void lj_set_clouds__impl(void*);
  void lj_set_corrections__impl(void*);
]]

-- ac.SkyCloudMaterial, simple thing
ffi.metatype('cloud_material', {
  __index = {}
})
ac.SkyCloudMaterial = function () return ffi.gc(ffi.C.lj_cloudmaterial_new__impl(), ffi.C.lj_cloudmaterial_gc__impl) end

-- ac.SkyCloud, keeps .material reference in Lua table to save it from GC
local __cloudMaterialKeepAlive = {}
local __cloudExtraData = {}
ffi.metatype('cloud', {
  __index = function(self, key) 
    if key == 'setTexture' then return ffi.C.lj_cloud_set_texture__impl end
    if key == 'setNoiseTexture' then return ffi.C.lj_cloud_set_noise_texture__impl end
    if key == 'material' then return self.__material end
    if key == 'extras' then 
      if __cloudExtraData[self.__id] == nil then __cloudExtraData[self.__id] = {} end
      return __cloudExtraData[self.__id] 
    end
    error('cloud has no member called \'' .. key .. '\'')
  end,
  __newindex = function(self, key, value) 
    if key == 'material' then 
      if value == nil then error('cloud material cannot be nil') end
      self.__material = value
      __cloudMaterialKeepAlive[self.__id] = value
      return
    end
    error('cloud has no member called \'' .. key .. '\'')
  end,
})
ac.SkyCloud = function () 
  local created = ffi.C.lj_cloud_new__impl()
  created.material = ac.SkyCloudMaterial()
  return ffi.gc(created, function (self)
    table.remove(__cloudMaterialKeepAlive, self.__id)
    table.remove(__cloudExtraData, self.__id)
    ffi.C.lj_cloud_gc__impl(self)
  end)
end
ac.SkyCloudV2 = function ()
  local ret = ac.SkyCloud()
  ret.version = 2
  return ret
end

-- ac.SkyCloudMapParams, noise for v2 clouds
ac.SkyCloudMapParams = ffi.metatype('cloud_map_settings', {
  __index = {
    new = function(x, y) 
      local ret = ac.SkyCloudMapParams()
      ret.perlinFrequency = 4.0
      ret.perlinOctaves = 7
      ret.worleyFrequency = 4.0
      ret.shapeMult = 20.0
      ret.shapeExp = 0.5
      ret.shape0Mip = 0.0
      ret.shape0Contribution = 0.3
      ret.shape1Mip = 2.2
      ret.shape1Contribution = 0.5
      ret.shape2Mip = 4.5
      ret.shape2Contribution = 1.0
      return ret
    end
  }
})