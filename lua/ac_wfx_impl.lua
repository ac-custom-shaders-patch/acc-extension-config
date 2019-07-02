	local function __ac_weatherconditions()
	ffi.cdef [[ 
typedef struct {
  float ambient, road;
} weather_conditions_temperatures;

typedef struct {
  float sessionStart, sessionTransfer, randomness, lapGain;
} weather_conditions_track;

typedef struct {
  float direction, speedFrom, speedTo;
} weather_conditions_wind;

typedef struct {
  char currentType;
  char upcomingType;
  weather_conditions_temperatures temperatures;
  weather_conditions_track trackState;
  weather_conditions_wind wind;
  float transition;
  float humidity, pressure;
  float variableA, variableB, variableC;
} weather_conditions;
]]
	ac.TrackConditions = ffi.metatype('weather_conditions_track', {
		__index = {}
	})
	ac.TemperatureParams = ffi.metatype('weather_conditions_temperatures', {
		__index = {}
	})
	ac.WindParams = ffi.metatype('weather_conditions_wind', {
		__index = {}
	})
	ac.ConditionsSet = ffi.metatype('weather_conditions', {
		__index = {}
	})
end
local function __ac_clouds()
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
    float lightSaturation;
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
    };
    
    vec2 noiseOffset;
    float shadowOpacity;
    bool useNoise;
    bool occludeGodrays;
    bool useCustomLightColor;
    bool useCustomLightDirection;

    cloud_material* __material;
    rgb extraDownlit;
    rgb customLightColor;
    vec3 customLightDirection;
  } cloud;

  cloud* lj_cloud_new();
  void lj_cloud_set_texture(cloud* self, const char*);
  void lj_cloud_set_noise_texture(cloud* self, const char*);
  void lj_cloud_gc(cloud*);

  cloud_material* lj_cloudmaterial_new();
  void lj_cloudmaterial_gc(cloud_material*);
  
  void lj_set_clouds__impl(void*);
  void lj_set_corrections__impl(void*);
]]
	ffi.metatype('cloud_material', {
		__index = {}
	})
	ac.SkyCloudMaterial = function()
		return ffi.gc(ffi.C.lj_cloudmaterial_new__impl(), ffi.C.lj_cloudmaterial_gc__impl)
	end
	local __cloudMaterialKeepAlive = {}
	local __cloudExtraData = {}
	ffi.metatype('cloud', {
		__index = function(self, key)
			if key == 'setTexture' then
				return ffi.C.lj_cloud_set_texture__impl
			end
			if key == 'setNoiseTexture' then
				return ffi.C.lj_cloud_set_noise_texture__impl
			end
			if key == 'material' then
				return self.__material
			end
			if key == 'extras' then
				if __cloudExtraData[self.__id] == nil then
					__cloudExtraData[self.__id] = {}
				end
				return __cloudExtraData[self.__id]
			end
			error('cloud has no member called \'' .. key .. '\'')
		end,
		__newindex = function(self, key, value)
			if key == 'material' then
				if value == nil then
					error('cloud material cannot be nil')
				end
				self.__material = value
				__cloudMaterialKeepAlive[self.__id] = value
				return
			end
			error('cloud has no member called \'' .. key .. '\'')
		end
	})
	ac.SkyCloud = function()
		local created = ffi.C.lj_cloud_new__impl()
		created.material = ac.SkyCloudMaterial()
		return ffi.gc(created, function(self)
			table.remove(__cloudMaterialKeepAlive, self.__id)
			table.remove(__cloudExtraData, self.__id)
			ffi.C.lj_cloud_gc__impl(self)
		end)
	end
end
local function __ac_gradients()
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
	ffi.metatype('extra_gradient', {
		__index = {}
	})
	ac.SkyExtraGradient = function(t)
		local r = ffi.C.lj_extragradient_new__impl()
		return ffi.gc(r, ffi.C.lj_extragradient_gc__impl)
	end
end
local function __ac_colorcorrections()
	ffi.cdef [[ typedef struct { void* __vfptr; } cc_grayscale; ]]
	ffi.metatype('cc_grayscale', {
		__index = {}
	})
	ac.ColorCorrectionGrayscale = function()
		return ffi.gc(ffi.C.lj_cc_grayscale_new__impl(), ffi.C.lj_cc_grayscale_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; } cc_negative; ]]
	ffi.metatype('cc_negative', {
		__index = {}
	})
	ac.ColorCorrectionNegative = function()
		return ffi.gc(ffi.C.lj_cc_negative_new__impl(), ffi.C.lj_cc_negative_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_sepia_tone; ]]
	ffi.metatype('cc_sepia_tone', {
		__index = {}
	})
	ac.ColorCorrectionSepiaTone = function(t)
		local r = ffi.C.lj_cc_sepiatone_new__impl()
		r.value = type(t) == 'table' and t['value'] or __num_fallback(t, 1)
		return ffi.gc(r, ffi.C.lj_cc_sepiatone_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_brightness; ]]
	ffi.metatype('cc_brightness', {
		__index = {}
	})
	ac.ColorCorrectionBrightness = function(t)
		local r = ffi.C.lj_cc_brightness_new__impl()
		r.value = type(t) == 'table' and t['value'] or __num_fallback(t, 1)
		return ffi.gc(r, ffi.C.lj_cc_brightness_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_saturation; ]]
	ffi.metatype('cc_saturation', {
		__index = {}
	})
	ac.ColorCorrectionSaturation = function(t)
		local r = ffi.C.lj_cc_saturation_new__impl()
		r.value = type(t) == 'table' and t['value'] or __num_fallback(t, 1)
		return ffi.gc(r, ffi.C.lj_cc_saturation_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_contrast; ]]
	ffi.metatype('cc_contrast', {
		__index = {}
	})
	ac.ColorCorrectionContrast = function(t)
		local r = ffi.C.lj_cc_contrast_new__impl()
		r.value = type(t) == 'table' and t['value'] or __num_fallback(t, 1)
		return ffi.gc(r, ffi.C.lj_cc_contrast_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_bias; ]]
	ffi.metatype('cc_bias', {
		__index = {}
	})
	ac.ColorCorrectionBias = function(t)
		local r = ffi.C.lj_cc_bias_new__impl()
		r.value = type(t) == 'table' and t['value'] or t or 0.0
		return ffi.gc(r, ffi.C.lj_cc_bias_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_modulation_rgb; ]]
	ffi.metatype('cc_modulation_rgb', {
		__index = {}
	})
	ac.ColorCorrectionModulationRgb = function(t)
		local r = ffi.C.lj_cc_modulation_rgb_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb.new(1)
		return ffi.gc(r, ffi.C.lj_cc_modulation_rgb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_saturation_rgb; ]]
	ffi.metatype('cc_saturation_rgb', {
		__index = {}
	})
	ac.ColorCorrectionSaturationRgb = function(t)
		local r = ffi.C.lj_cc_saturation_rgb_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb.new(1)
		return ffi.gc(r, ffi.C.lj_cc_saturation_rgb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_contrast_rgb; ]]
	ffi.metatype('cc_contrast_rgb', {
		__index = {}
	})
	ac.ColorCorrectionContrastRgb = function(t)
		local r = ffi.C.lj_cc_contrast_rgb_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb.new(1)
		return ffi.gc(r, ffi.C.lj_cc_contrast_rgb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_bias_rgb; ]]
	ffi.metatype('cc_bias_rgb', {
		__index = {}
	})
	ac.ColorCorrectionBiasRgb = function(t)
		local r = ffi.C.lj_cc_bias_rgb_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb()
		return ffi.gc(r, ffi.C.lj_cc_bias_rgb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float effectRatio; } cc_monotone_rgb; ]]
	ffi.metatype('cc_monotone_rgb', {
		__index = {}
	})
	ac.ColorCorrectionMonotoneRgb = function(t)
		local r = ffi.C.lj_cc_monotone_rgb_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb.new(1)
		r.effectRatio = type(t) == 'table' and t['effectRatio'] or 1
		return ffi.gc(r, ffi.C.lj_cc_monotone_rgb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float saturation; float modulation; } cc_monotone_rgb_sat_mod; ]]
	ffi.metatype('cc_monotone_rgb_sat_mod', {
		__index = {}
	})
	ac.ColorCorrectionMonotoneRgbSatMod = function(t)
		local r = ffi.C.lj_cc_monotone_rgbsatmod_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb.new(1)
		r.saturation = type(t) == 'table' and t['saturation'] or 1
		r.modulation = type(t) == 'table' and t['modulation'] or 1
		return ffi.gc(r, ffi.C.lj_cc_monotone_rgbsatmod_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float effectRatio; } cc_fade_rgb; ]]
	ffi.metatype('cc_fade_rgb', {
		__index = {}
	})
	ac.ColorCorrectionFadeRgb = function(t)
		local r = ffi.C.lj_cc_fade_rgb_new__impl()
		r.color = type(t) == 'table' and t['color'] or rgb.new(1)
		r.effectRatio = type(t) == 'table' and t['effectRatio'] or 1
		return ffi.gc(r, ffi.C.lj_cc_fade_rgb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float hue; bool keepLuminance; } cc_hue; ]]
	ffi.metatype('cc_hue', {
		__index = {}
	})
	ac.ColorCorrectionHue = function(t)
		local r = ffi.C.lj_cc_hue_new__impl()
		r.hue = type(t) == 'table' and t['hue'] or t or 0
		r.keepLuminance = type(t) == 'table' and t['keepLuminance'] or 1
		return ffi.gc(r, ffi.C.lj_cc_hue_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float hue; float saturation; float brightness; } cc_hsb; ]]
	ffi.metatype('cc_hsb', {
		__index = {}
	})
	ac.ColorCorrectionHsb = function(t)
		local r = ffi.C.lj_cc_hsb_new__impl()
		r.hue = type(t) == 'table' and t['hue'] or t or 0
		r.saturation = type(t) == 'table' and t['saturation'] or t or __num_fallback(t, 1)
		r.brightness = type(t) == 'table' and t['brightness'] or t or __num_fallback(t, 1)
		return ffi.gc(r, ffi.C.lj_cc_hsb_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float temperature; float luminance; } cc_temperature; ]]
	ffi.metatype('cc_temperature', {
		__index = {}
	})
	ac.ColorCorrectionTemperature = function(t)
		local r = ffi.C.lj_cc_temperature_new__impl()
		r.temperature = type(t) == 'table' and t['temperature'] or __num_fallback(t, 6500.0)
		r.luminance = type(t) == 'table' and t['luminance'] or 0.0
		return ffi.gc(r, ffi.C.lj_cc_temperature_gc__impl)
	end
	ffi.cdef [[ typedef struct { void* __vfptr; float whitebalance; float luminance; } cc_white_balance; ]]
	ffi.metatype('cc_white_balance', {
		__index = {}
	})
	ac.ColorCorrectionWhiteBalance = function(t)
		local r = ffi.C.lj_cc_whitebalance_new__impl()
		r.temperature = type(t) == 'table' and t['temperature'] or __num_fallback(t, 6500.0)
		r.luminance = type(t) == 'table' and t['luminance'] or 0.0
		return ffi.gc(r, ffi.C.lj_cc_whitebalance_gc__impl)
	end
end
local function __ac_particlematerials()
	ffi.cdef [[ 
typedef struct {
  float emissiveBlend, diffuse, ambient;
} particles_material;
]]
	ac.ParticlesMaterial = ffi.metatype('particles_material', {
		__index = {}
	})
end
local function __ac_lightpollution()
	ffi.cdef [[ 
typedef struct {
  vec3 position;
  float radius;
  rgb tint;
  float density;
} light_pollution;
]]
	ac.LightPollution = ffi.metatype('light_pollution', {
		__index = {},
		__tostring = function(v)
			return string.format('(position=%s, radius=%f, density=%f, tint=%s)', v.position, v.radius, v.density, v.tint)
		end
	})
end
local function __ac_audio()
	ffi.cdef [[ 
typedef struct {
  void* nativeEvent_;
  float volume;
  float cameraInteriorMultiplier;
  float cameraExteriorMultiplier;
  float cameraTrackMultiplier;
  bool inAutoLoopMode;
} audioevent;
]]
	ac.AudioEvent = function(s, reverbResponse)
		local created = ffi.C.lj_audioevent_new__impl(tostring(s), reverbResponse and true or false)
		return ffi.gc(created, ffi.C.lj_audioevent_gc__impl)
	end
	__audioEventKeepAlive = {}
	ffi.metatype('audioevent', {
		__index = function(self, key)
			if key == 'setPosition' then
				return function(s, pos, dir, up, vel)
					ffi.C.lj_audioevent_set_pos__impl(s, pos, dir or vec3.new(0, 0, 1), up or vec3.new(0, 1, 0), vel or vec3.new(0, 0, 0))
				end
			end
			if key == 'keepAlive' then
				return function(s)
					__audioEventKeepAlive[#__audioEventKeepAlive + 1] = s
				end
			end
			if key == 'setParam' then
				return ffi.C.lj_audioevent_set_param__impl
			end
			if key == 'isValid' then
				return function(s)
					return s.nativeEvent_ ~= nil
				end
			end
			if key == 'isPlaying' then
				return ffi.C.lj_audioevent_is_playing__impl
			end
			if key == 'isPaused' then
				return ffi.C.lj_audioevent_is_paused__impl
			end
			if key == 'isWithinRange' then
				return ffi.C.lj_audioevent_is_within_range__impl
			end
			if key == 'resume' then
				return ffi.C.lj_audioevent_resume__impl
			end
			if key == 'resumeIf' then
				return ffi.C.lj_audioevent_resume_if__impl
			end
			if key == 'stop' then
				return ffi.C.lj_audioevent_stop__impl
			end
			if key == 'start' then
				return ffi.C.lj_audioevent_start__impl
			end
			error('audioevent has no member called \'' .. key .. '\'')
		end,
		__newindex = function(self, key, value)
			error('audioevent has no member called \'' .. key .. '\'')
		end
	})
end
local function __ac_obsolete()
	ac.SHADOWS_ON = 1
	ac.SHADOWS_OFF = 0
	ac.setSkySunSize = function(v)
		end
	ac.setSunAngle = function(v)
		end
	ac.setCustomSunDirection = function(v)
		end
	ac.setSkyExtraGradient = function(id, gradient)
		if id < 0 or id >= 32 then
			error('id should be within 0-31 range')
		end
		ac.skyExtraGradients:set(id + 1, gradient)
	end
	ac.removeSkyExtraGradient = function(id)
		if id < 0 or id >= 32 then
			error('id should be within 0-31 range')
		end
		ac.skyExtraGradients:set(id + 1, nil)
	end
	ac.addSkyExtraGradients = ac.addSkyExtraGradient
end
local function __ac_lists()
	ac.weatherClouds = __bound_array(ffi.typeof('cloud*'), 'lj_set_clouds__impl')
	ac.skyExtraGradients = __bound_array(ffi.typeof('extra_gradient*'), 'lj_set_gradients__impl')
	ac.weatherColorCorrections = __bound_array(ffi.typeof('void*'), 'lj_set_corrections__impl')
	ac.addWeatherCloud = function(cloud)
		return ac.weatherClouds:pushWhereFits(cloud)
	end
	ac.addSkyExtraGradient = function(gradient)
		return ac.skyExtraGradients:pushWhereFits(gradient)
	end
	ac.addWeatherColorCorrection = function(cc)
		return ac.weatherColorCorrections:pushWhereFits(cc)
	end
end
require "extension/lua/ac_common"
__ac_weatherconditions()
__ac_clouds()
__ac_gradients()
__ac_colorcorrections()
__ac_particlematerials()
__ac_lightpollution()
__ac_audio()
ffi.cdef [[
double lj_getCurrentTime();
float lj_getDaySeconds();
int lj_getDayOfTheYear();
float lj_getTimeMultiplier();
vec3 lj_getSunDirection();
vec3 lj_getMoonDirection();
float lj_getAltitude();
float lj_getSunAltitude();
vec2 lj_getTrackCoordinates();
uint64_t lj_getInputDate();
float lj_getRealTrackHeadingAngle();
float lj_getTimeZoneOffset();
float lj_getTimeZoneDstOffset();
float lj_getTimeZoneBaseOffset();
weather_conditions lj_getConditionsSet();
const char* lj_getPpFilter();
void lj_debug__impl(const char* key, const char* value);
void lj_log__impl(const char* value);
void lj_warn__impl(const char* value);
void lj_error__impl(const char* value);
void lj_set_track_condition__impl(const char* key, float value);
rgb lj_getSkyAbsorption__impl(const vec3& dir);
void lj_setShadows__impl(int value);
void lj_resetShadowsResolution__impl();
void lj_setShadowsResolution__impl(int value);
void lj_resetShadowsSplits__impl();
void lj_setShadowsSplits__impl(const vec3& interior, const vec3& exterior);
void lj_setFogColor__impl(const rgb& c);
void lj_setFogBlend__impl(float blend);
void lj_setFogDistance__impl(float distance);
void lj_setFogAlgorithm__impl(int value);
void lj_setFogBacklitExponent__impl(float value);
void lj_setFogBacklitMultiplier__impl(float value);
void lj_setFogExponent__impl(float value);
void lj_setFogHeight__impl(float value);
void lj_setFogDensity__impl(float value);
void lj_setLightDirection__impl(const vec3& dir);
void lj_setLightColor__impl(const rgb& c);
void lj_setLightShadowOpacity__impl(float value);
float lj_getCloudsShadow__impl();
void lj_setAmbientColor__impl(const rgb& c);
bool lj_isRainFxActive__impl();
float lj_getRainAmount__impl();
void lj_setRainAmount__impl(float v);
void lj_setSunColor__impl(const rgb& c);
void lj_setSkyStarsMap__impl(const char* v);
void lj_setSkyMoonTexture__impl(const char* v);
void lj_setSkyColor__impl(const rgb& c);
void lj_setSkyAnisotropicIntensity__impl(float v);
void lj_setSkyZenithOffset__impl(float v);
void lj_setSkyZenithDensityExp__impl(float v);
void lj_setSkyInputYOffset__impl(float v);
void lj_setSkyMultiScatterPhase__impl(float v);
void lj_setSkyDensity__impl(float v);
void lj_setSkyBrightnessMult__impl(float v);
void lj_setSkySunBaseColor__impl(const rgb& v);
void lj_setSkySunBrightness__impl(float v);
void lj_setSkySunMieExp__impl(float v);
void lj_setSkySunMoonSizeMultiplier__impl(float v);
void lj_setSkyMoonBaseColor__impl(const rgb& v);
void lj_setSkyMoonMieExp__impl(float v);
void lj_setSkyMoonMieMultiplier__impl(float v);
void lj_setSkyMoonBrightness__impl(float v);
void lj_setSkyMoonOpacity__impl(float v);
void lj_setSkyMoonDepthSkip__impl(bool v);
void lj_setSkyStarsColor__impl(const rgb& v);
void lj_setSkyStarsBrightness__impl(float v);
void lj_setSkyStarsSaturation__impl(float v);
void lj_setSkyStarsExponent__impl(float v);
void lj_setSkyPlanetsBrightness__impl(float v);
void lj_setSkyPlanetsOpacity__impl(float v);
void lj_setSkyPlanetsSizeBase__impl(float v);
void lj_setSkyPlanetsSizeVariance__impl(float v);
void lj_setSkyPlanetsSizeMultiplier__impl(float v);
void lj_resetSpecularColor__impl();
void lj_setSpecularColor__impl(const rgb& c);
void lj_resetEmissiveMultiplier__impl();
void lj_setEmissiveMultiplier__impl(float v);
void lj_resetGodraysCustomColor__impl();
void lj_setGodraysCustomColor__impl(const rgb& c);
void lj_resetGodraysCustomDirection__impl();
void lj_setGodraysCustomDirection__impl(const vec3& v);
void lj_setGodraysLength__impl(float v);
void lj_setGodraysGlareRatio__impl(float v);
void lj_setGodraysAngleAttenuation__impl(float v);
void lj_setGodraysNoiseFrequency__impl(float v);
void lj_setGodraysNoiseMask__impl(float v);
void lj_setGodraysDepthMapThreshold__impl(float v);
void lj_setGlareThreshold__impl(float v);
void lj_setGlareBloomFilterThreshold__impl(float v);
void lj_setGlareStarFilterThreshold__impl(float v);
void lj_setPpColorTemperatureK__impl(float v);
void lj_setPpWhiteBalanceK__impl(float v);
void lj_setPpHue__impl(float v);
void lj_setPpSepia__impl(float v);
void lj_setPpSaturation__impl(float v);
void lj_setPpBrightness__impl(float v);
void lj_setPpContrast__impl(float v);
void lj_setPpTonemapFunction__impl(int v);
void lj_setPpTonemapExposure__impl(float v);
void lj_setPpTonemapGamma__impl(float v);
void lj_setPpTonemapUseHdrSpace__impl(bool v);
void lj_setPpTonemapMappingFactor__impl(float v);
void lj_setPpTonemapFilmicContrast__impl(float v);
bool lj_isPpActive__impl();
float lj_getGodraysLength__impl();
float lj_getGodraysGlareRatio__impl();
float lj_getGodraysAngleAttenuation__impl();
float lj_getGodraysNoiseFrequency__impl();
float lj_getGodraysNoiseMask__impl();
float lj_getGodraysDepthMapThreshold__impl();
float lj_getGlareThreshold__impl();
float lj_getGlareBloomFilterThreshold__impl();
float lj_getGlareStarFilterThreshold__impl();
float lj_getPpColorTemperatureK__impl();
float lj_getPpWhiteBalanceK__impl();
float lj_getPpHue__impl();
float lj_getPpSepia__impl();
float lj_getPpSaturation__impl();
float lj_getPpBrightness__impl();
float lj_getPpContrast__impl();
float lj_getPpTonemapFunction__impl();
float lj_getPpTonemapExposure__impl();
float lj_getPpTonemapGamma__impl();
float lj_getPpTonemapMappingFactor__impl();
float lj_getPpTonemapFilmicContrast__impl();
float lj_getPpTonemapUseHdrSpace__impl();
bool lj_getPpGodraysEnabled__impl();
bool lj_getPpDofEnabled__impl();
bool lj_getPpDofActive__impl();
bool lj_getPpChromaticAbberationActive__impl();
bool lj_getPpGlareGhostActive__impl();
bool lj_getPpHeatParticleActive__impl();
bool lj_getPpAirydiskEnabled__impl();
bool lj_getPpAntialiasingEnabled__impl();
bool lj_getPpAutoExposureEnabled__impl();
bool lj_getPpChromaticAbberationEnabled__impl();
bool lj_getPpFeedbackEnabled__impl();
bool lj_getPpLensDistortionEnabled__impl();
bool lj_getPpHeatParticleEnabled__impl();
bool lj_getPpGlareEnabled__impl();
bool lj_getPpGlareAnamorphicEnabled__impl();
void lj_setPpTonemapViewportScale__impl(const vec2& v);
void lj_setPpTonemapViewportOffset__impl(const vec2& v);
void lj_setHeatParticles__impl(bool v);
bool lj_isVertexAoPatchApplied__impl();
bool lj_isTrackAmbientLowerMultiplierDefined__impl();
float lj_getTrackAmbientLowerMultiplier__impl();
light_pollution lj_getTrackLightPollution__impl();
float lj_getWeatherStaticAmbientLowerMultiplier__impl();
void lj_setWeatherStaticAmbient__impl(const rgb& upper, const rgb& lower);
void lj_resetWeatherStaticAmbient__impl();
void lj_setEmissiveCameraGain__impl(float direct, float mirror);
void lj_setExtraAsphaltReflectionsMultiplier__impl(float value);
void lj_setParticlesSmokeMaterial__impl(const particles_material& material);
void lj_setParticlesGrassMaterial__impl(const particles_material& material);
void lj_setParticlesGrassPiecesMaterial__impl(const particles_material& material);
void lj_setWeatherFakeShadowOpacity__impl(float v);
void lj_setWeatherDynamicAmbientMultiplier__impl(float v);
void lj_setWeatherDynamicAmbientSaturation__impl(float v);
void lj_setWeatherDynamicAmbientGamma__impl(float v);
void lj_setWeatherDynamicAmbientBrightness__impl(float v);
void lj_setWeatherBouncedLightMultiplier__impl(const rgb& v);
void lj_setWeatherBouncedInteriorLightMultiplier__impl(const rgb& v);
void lj_setWeatherBouncedLightShDirection__impl(const vec3& v);
void lj_setWeatherBouncedLightShMultiplier__impl(float v);
void lj_setWeatherBouncedLightShSaturation__impl(float v);
float lj_getWeatherLightsMultiplier__impl();
void lj_setWeatherLightsMultiplier__impl(float value);
void lj_resetWeatherLightsMultiplier__impl();
float lj_getAutoExposure__impl();
void lj_setAutoExposureActive__impl(bool v);
void lj_setAutoExposureInfluencedByGlare__impl(bool v);
void lj_setAutoExposureTarget__impl(float v);
void lj_setAutoExposureMeasuringArea__impl(vec2 center, vec2 size);
void lj_setAutoExposureLimits__impl(float min, float max);
void lj_setSkyFogMultiplier__impl(float v);
rgb lj_calculateSkyColor__impl(const vec3& v, bool include_sky_color, bool include_moon_color);
void lj_setAiHeadlights__impl(bool v);
void lj_set_clouds__impl(const void* arr);
void lj_set_gradients__impl(const void* arr);
void lj_set_corrections__impl(const void* arr);
cloud* lj_cloud_new__impl();
void lj_cloud_gc__impl(cloud* r);
cloud_material* lj_cloudmaterial_new__impl();
void lj_cloudmaterial_gc__impl(cloud_material* r);
void lj_cloud_set_texture__impl(cloud* self, const char* value);
void lj_cloud_set_noise_texture__impl(cloud* self, const char* value);
void lj_loadSoundbank__impl(const char* soundbank, const char* guids);
audioevent* lj_audioevent_new__impl(const char* path, bool reverb_response);
void lj_audioevent_gc__impl(audioevent* r);
void lj_audioevent_set_pos__impl(audioevent* self, const vec3& pos, const vec3& dir, const vec3& up, const vec3& velocity);
void lj_audioevent_set_param__impl(audioevent* self, const char* name, float value);
bool lj_audioevent_is_playing__impl(audioevent* self);
bool lj_audioevent_is_paused__impl(audioevent* self);
bool lj_audioevent_is_within_range__impl(audioevent* self);
void lj_audioevent_resume__impl(audioevent* self);
void lj_audioevent_resume_if__impl(audioevent* self, bool c);
void lj_audioevent_stop__impl(audioevent* self);
void lj_audioevent_start__impl(audioevent* self);
extra_gradient* lj_extragradient_new__impl();
void lj_extragradient_gc__impl(extra_gradient* r);
cc_grayscale* lj_cc_grayscale_new__impl();
void lj_cc_grayscale_gc__impl(cc_grayscale* r);
cc_negative* lj_cc_negative_new__impl();
void lj_cc_negative_gc__impl(cc_negative* r);
cc_temperature* lj_cc_temperature_new__impl();
void lj_cc_temperature_gc__impl(cc_temperature* r);
cc_white_balance* lj_cc_whitebalance_new__impl();
void lj_cc_whitebalance_gc__impl(cc_white_balance* r);
cc_brightness* lj_cc_brightness_new__impl();
void lj_cc_brightness_gc__impl(cc_brightness* r);
cc_saturation* lj_cc_saturation_new__impl();
void lj_cc_saturation_gc__impl(cc_saturation* r);
cc_contrast* lj_cc_contrast_new__impl();
void lj_cc_contrast_gc__impl(cc_contrast* r);
cc_bias* lj_cc_bias_new__impl();
void lj_cc_bias_gc__impl(cc_bias* r);
cc_modulation_rgb* lj_cc_modulation_rgb_new__impl();
void lj_cc_modulation_rgb_gc__impl(cc_modulation_rgb* r);
cc_saturation_rgb* lj_cc_saturation_rgb_new__impl();
void lj_cc_saturation_rgb_gc__impl(cc_saturation_rgb* r);
cc_contrast_rgb* lj_cc_contrast_rgb_new__impl();
void lj_cc_contrast_rgb_gc__impl(cc_contrast_rgb* r);
cc_bias_rgb* lj_cc_bias_rgb_new__impl();
void lj_cc_bias_rgb_gc__impl(cc_bias_rgb* r);
cc_monotone_rgb* lj_cc_monotone_rgb_new__impl();
void lj_cc_monotone_rgb_gc__impl(cc_monotone_rgb* r);
cc_monotone_rgb_sat_mod* lj_cc_monotone_rgbsatmod_new__impl();
void lj_cc_monotone_rgbsatmod_gc__impl(cc_monotone_rgb_sat_mod* r);
cc_fade_rgb* lj_cc_fade_rgb_new__impl();
void lj_cc_fade_rgb_gc__impl(cc_fade_rgb* r);
cc_hue* lj_cc_hue_new__impl();
void lj_cc_hue_gc__impl(cc_hue* r);
cc_hsb* lj_cc_hsb_new__impl();
void lj_cc_hsb_gc__impl(cc_hsb* r);
cc_sepia_tone* lj_cc_sepiatone_new__impl();
void lj_cc_sepiatone_gc__impl(cc_sepia_tone* r);
]]
local function __sane(x)
	if type(x) == 'number' then
		if not(x > -math.huge and x < math.huge) then
			error('finite value is required, got: ' .. x)
		end
	elseif vec2.isvec2(x) then
		__sane(x.x)
		__sane(x.y)
	elseif vec3.isvec3(x) then
		__sane(x.x)
		__sane(x.y)
		__sane(x.z)
	elseif vec4.isvec4(x) then
		__sane(x.x)
		__sane(x.y)
		__sane(x.z)
		__sane(x.w)
	elseif rgb.isrgb(x) then
		__sane(x.r)
		__sane(x.g)
		__sane(x.b)
	end
	return x
end
ac.getCurrentTime = ffi.C.lj_getCurrentTime
ac.getDaySeconds = ffi.C.lj_getDaySeconds
ac.getDayOfTheYear = ffi.C.lj_getDayOfTheYear
ac.getTimeMultiplier = ffi.C.lj_getTimeMultiplier
ac.getSunDirection = ffi.C.lj_getSunDirection
ac.getMoonDirection = ffi.C.lj_getMoonDirection
ac.getAltitude = ffi.C.lj_getAltitude
ac.getSunAltitude = ffi.C.lj_getSunAltitude
ac.getTrackCoordinates = ffi.C.lj_getTrackCoordinates
ac.getInputDate = ffi.C.lj_getInputDate
ac.getRealTrackHeadingAngle = ffi.C.lj_getRealTrackHeadingAngle
ac.getTimeZoneOffset = ffi.C.lj_getTimeZoneOffset
ac.getTimeZoneDstOffset = ffi.C.lj_getTimeZoneDstOffset
ac.getTimeZoneBaseOffset = ffi.C.lj_getTimeZoneBaseOffset
ac.getConditionsSet = ffi.C.lj_getConditionsSet
ac.getPpFilter = function()
	return ffi.string(ffi.C.lj_getPpFilter())
end
ac.debug = function(key, value)
	ffi.C.lj_debug__impl(key ~= nil and tostring(key) or nil, value ~= nil and tostring(value) or nil)
end
ac.log = function(value)
	ffi.C.lj_log__impl(value ~= nil and tostring(value) or nil)
end
ac.warn = function(value)
	ffi.C.lj_warn__impl(value ~= nil and tostring(value) or nil)
end
ac.error = function(value)
	ffi.C.lj_error__impl(value ~= nil and tostring(value) or nil)
end
ac.getSkyAbsorption = function(dir)
	return ffi.C.lj_getSkyAbsorption__impl(__sane(dir))
end
ac.setShadows = function(value)
	ffi.C.lj_setShadows__impl(__sane(value))
end
ac.resetShadowsResolution = ffi.C.lj_resetShadowsResolution__impl
ac.setShadowsResolution = function(value)
	ffi.C.lj_setShadowsResolution__impl(__sane(value))
end
ac.resetShadowsSplits = ffi.C.lj_resetShadowsSplits__impl
ac.setShadowsSplits = function(interior, exterior)
	ffi.C.lj_setShadowsSplits__impl(__sane(interior), __sane(exterior))
end
ac.setFogColor = function(c)
	ffi.C.lj_setFogColor__impl(__sane(rgb.new(c)))
end
ac.setFogBlend = function(blend)
	ffi.C.lj_setFogBlend__impl(__sane(blend))
end
ac.setFogDistance = function(distance)
	ffi.C.lj_setFogDistance__impl(__sane(distance))
end
ac.setFogAlgorithm = function(value)
	ffi.C.lj_setFogAlgorithm__impl(__sane(value))
end
ac.setFogBacklitExponent = function(value)
	ffi.C.lj_setFogBacklitExponent__impl(__sane(value))
end
ac.setFogBacklitMultiplier = function(value)
	ffi.C.lj_setFogBacklitMultiplier__impl(__sane(value))
end
ac.setFogExponent = function(value)
	ffi.C.lj_setFogExponent__impl(__sane(value))
end
ac.setFogHeight = function(value)
	ffi.C.lj_setFogHeight__impl(__sane(value))
end
ac.setFogDensity = function(value)
	ffi.C.lj_setFogDensity__impl(__sane(value))
end
ac.setLightDirection = function(dir)
	ffi.C.lj_setLightDirection__impl(__sane(dir))
end
ac.setLightColor = function(c)
	ffi.C.lj_setLightColor__impl(__sane(rgb.new(c)))
end
ac.setLightShadowOpacity = function(value)
	ffi.C.lj_setLightShadowOpacity__impl(__sane(value))
end
ac.getCloudsShadow = ffi.C.lj_getCloudsShadow__impl
ac.setAmbientColor = function(c)
	ffi.C.lj_setAmbientColor__impl(__sane(rgb.new(c)))
end
ac.isRainFxActive = ffi.C.lj_isRainFxActive__impl
ac.getRainAmount = ffi.C.lj_getRainAmount__impl
ac.setRainAmount = function(v)
	ffi.C.lj_setRainAmount__impl(__sane(v))
end
ac.setSunColor = function(c)
	ffi.C.lj_setSunColor__impl(__sane(rgb.new(c)))
end
ac.setSkyStarsMap = function(v)
	ffi.C.lj_setSkyStarsMap__impl(v ~= nil and tostring(v) or nil)
end
ac.setSkyMoonTexture = function(v)
	ffi.C.lj_setSkyMoonTexture__impl(v ~= nil and tostring(v) or nil)
end
ac.setSkyColor = function(c)
	ffi.C.lj_setSkyColor__impl(__sane(rgb.new(c)))
end
ac.setSkyAnisotropicIntensity = function(v)
	ffi.C.lj_setSkyAnisotropicIntensity__impl(__sane(v))
end
ac.setSkyZenithOffset = function(v)
	ffi.C.lj_setSkyZenithOffset__impl(__sane(v))
end
ac.setSkyZenithDensityExp = function(v)
	ffi.C.lj_setSkyZenithDensityExp__impl(__sane(v))
end
ac.setSkyInputYOffset = function(v)
	ffi.C.lj_setSkyInputYOffset__impl(__sane(v))
end
ac.setSkyMultiScatterPhase = function(v)
	ffi.C.lj_setSkyMultiScatterPhase__impl(__sane(v))
end
ac.setSkyDensity = function(v)
	ffi.C.lj_setSkyDensity__impl(__sane(v))
end
ac.setSkyBrightnessMult = function(v)
	ffi.C.lj_setSkyBrightnessMult__impl(__sane(v))
end
ac.setSkySunBaseColor = function(v)
	ffi.C.lj_setSkySunBaseColor__impl(__sane(rgb.new(v)))
end
ac.setSkySunBrightness = function(v)
	ffi.C.lj_setSkySunBrightness__impl(__sane(v))
end
ac.setSkySunMieExp = function(v)
	ffi.C.lj_setSkySunMieExp__impl(__sane(v))
end
ac.setSkySunMoonSizeMultiplier = function(v)
	ffi.C.lj_setSkySunMoonSizeMultiplier__impl(__sane(v))
end
ac.setSkyMoonBaseColor = function(v)
	ffi.C.lj_setSkyMoonBaseColor__impl(__sane(rgb.new(v)))
end
ac.setSkyMoonMieExp = function(v)
	ffi.C.lj_setSkyMoonMieExp__impl(__sane(v))
end
ac.setSkyMoonMieMultiplier = function(v)
	ffi.C.lj_setSkyMoonMieMultiplier__impl(__sane(v))
end
ac.setSkyMoonBrightness = function(v)
	ffi.C.lj_setSkyMoonBrightness__impl(__sane(v))
end
ac.setSkyMoonOpacity = function(v)
	ffi.C.lj_setSkyMoonOpacity__impl(__sane(v))
end
ac.setSkyMoonDepthSkip = function(v)
	ffi.C.lj_setSkyMoonDepthSkip__impl(__sane(v))
end
ac.setSkyStarsColor = function(v)
	ffi.C.lj_setSkyStarsColor__impl(__sane(rgb.new(v)))
end
ac.setSkyStarsBrightness = function(v)
	ffi.C.lj_setSkyStarsBrightness__impl(__sane(v))
end
ac.setSkyStarsSaturation = function(v)
	ffi.C.lj_setSkyStarsSaturation__impl(__sane(v))
end
ac.setSkyStarsExponent = function(v)
	ffi.C.lj_setSkyStarsExponent__impl(__sane(v))
end
ac.setSkyPlanetsBrightness = function(v)
	ffi.C.lj_setSkyPlanetsBrightness__impl(__sane(v))
end
ac.setSkyPlanetsOpacity = function(v)
	ffi.C.lj_setSkyPlanetsOpacity__impl(__sane(v))
end
ac.setSkyPlanetsSizeBase = function(v)
	ffi.C.lj_setSkyPlanetsSizeBase__impl(__sane(v))
end
ac.setSkyPlanetsSizeVariance = function(v)
	ffi.C.lj_setSkyPlanetsSizeVariance__impl(__sane(v))
end
ac.setSkyPlanetsSizeMultiplier = function(v)
	ffi.C.lj_setSkyPlanetsSizeMultiplier__impl(__sane(v))
end
ac.resetSpecularColor = ffi.C.lj_resetSpecularColor__impl
ac.setSpecularColor = function(c)
	ffi.C.lj_setSpecularColor__impl(__sane(rgb.new(c)))
end
ac.resetEmissiveMultiplier = ffi.C.lj_resetEmissiveMultiplier__impl
ac.setEmissiveMultiplier = function(v)
	ffi.C.lj_setEmissiveMultiplier__impl(__sane(v))
end
ac.resetGodraysCustomColor = ffi.C.lj_resetGodraysCustomColor__impl
ac.setGodraysCustomColor = function(c)
	ffi.C.lj_setGodraysCustomColor__impl(__sane(rgb.new(c)))
end
ac.resetGodraysCustomDirection = ffi.C.lj_resetGodraysCustomDirection__impl
ac.setGodraysCustomDirection = function(v)
	ffi.C.lj_setGodraysCustomDirection__impl(__sane(v))
end
ac.setGodraysLength = function(v)
	ffi.C.lj_setGodraysLength__impl(__sane(v))
end
ac.setGodraysGlareRatio = function(v)
	ffi.C.lj_setGodraysGlareRatio__impl(__sane(v))
end
ac.setGodraysAngleAttenuation = function(v)
	ffi.C.lj_setGodraysAngleAttenuation__impl(__sane(v))
end
ac.setGodraysNoiseFrequency = function(v)
	ffi.C.lj_setGodraysNoiseFrequency__impl(__sane(v))
end
ac.setGodraysNoiseMask = function(v)
	ffi.C.lj_setGodraysNoiseMask__impl(__sane(v))
end
ac.setGodraysDepthMapThreshold = function(v)
	ffi.C.lj_setGodraysDepthMapThreshold__impl(__sane(v))
end
ac.setGlareThreshold = function(v)
	ffi.C.lj_setGlareThreshold__impl(__sane(v))
end
ac.setGlareBloomFilterThreshold = function(v)
	ffi.C.lj_setGlareBloomFilterThreshold__impl(__sane(v))
end
ac.setGlareStarFilterThreshold = function(v)
	ffi.C.lj_setGlareStarFilterThreshold__impl(__sane(v))
end
ac.setPpColorTemperatureK = function(v)
	ffi.C.lj_setPpColorTemperatureK__impl(__sane(v))
end
ac.setPpWhiteBalanceK = function(v)
	ffi.C.lj_setPpWhiteBalanceK__impl(__sane(v))
end
ac.setPpHue = function(v)
	ffi.C.lj_setPpHue__impl(__sane(v))
end
ac.setPpSepia = function(v)
	ffi.C.lj_setPpSepia__impl(__sane(v))
end
ac.setPpSaturation = function(v)
	ffi.C.lj_setPpSaturation__impl(__sane(v))
end
ac.setPpBrightness = function(v)
	ffi.C.lj_setPpBrightness__impl(__sane(v))
end
ac.setPpContrast = function(v)
	ffi.C.lj_setPpContrast__impl(__sane(v))
end
ac.setPpTonemapFunction = function(v)
	ffi.C.lj_setPpTonemapFunction__impl(__sane(v))
end
ac.setPpTonemapExposure = function(v)
	ffi.C.lj_setPpTonemapExposure__impl(__sane(v))
end
ac.setPpTonemapGamma = function(v)
	ffi.C.lj_setPpTonemapGamma__impl(__sane(v))
end
ac.setPpTonemapUseHdrSpace = function(v)
	ffi.C.lj_setPpTonemapUseHdrSpace__impl(__sane(v))
end
ac.setPpTonemapMappingFactor = function(v)
	ffi.C.lj_setPpTonemapMappingFactor__impl(__sane(v))
end
ac.setPpTonemapFilmicContrast = function(v)
	ffi.C.lj_setPpTonemapFilmicContrast__impl(__sane(v))
end
ac.isPpActive = ffi.C.lj_isPpActive__impl
ac.getGodraysLength = ffi.C.lj_getGodraysLength__impl
ac.getGodraysGlareRatio = ffi.C.lj_getGodraysGlareRatio__impl
ac.getGodraysAngleAttenuation = ffi.C.lj_getGodraysAngleAttenuation__impl
ac.getGodraysNoiseFrequency = ffi.C.lj_getGodraysNoiseFrequency__impl
ac.getGodraysNoiseMask = ffi.C.lj_getGodraysNoiseMask__impl
ac.getGodraysDepthMapThreshold = ffi.C.lj_getGodraysDepthMapThreshold__impl
ac.getGlareThreshold = ffi.C.lj_getGlareThreshold__impl
ac.getGlareBloomFilterThreshold = ffi.C.lj_getGlareBloomFilterThreshold__impl
ac.getGlareStarFilterThreshold = ffi.C.lj_getGlareStarFilterThreshold__impl
ac.getPpColorTemperatureK = ffi.C.lj_getPpColorTemperatureK__impl
ac.getPpWhiteBalanceK = ffi.C.lj_getPpWhiteBalanceK__impl
ac.getPpHue = ffi.C.lj_getPpHue__impl
ac.getPpSepia = ffi.C.lj_getPpSepia__impl
ac.getPpSaturation = ffi.C.lj_getPpSaturation__impl
ac.getPpBrightness = ffi.C.lj_getPpBrightness__impl
ac.getPpContrast = ffi.C.lj_getPpContrast__impl
ac.getPpTonemapFunction = ffi.C.lj_getPpTonemapFunction__impl
ac.getPpTonemapExposure = ffi.C.lj_getPpTonemapExposure__impl
ac.getPpTonemapGamma = ffi.C.lj_getPpTonemapGamma__impl
ac.getPpTonemapMappingFactor = ffi.C.lj_getPpTonemapMappingFactor__impl
ac.getPpTonemapFilmicContrast = ffi.C.lj_getPpTonemapFilmicContrast__impl
ac.getPpTonemapUseHdrSpace = ffi.C.lj_getPpTonemapUseHdrSpace__impl
ac.getPpGodraysEnabled = ffi.C.lj_getPpGodraysEnabled__impl
ac.getPpDofEnabled = ffi.C.lj_getPpDofEnabled__impl
ac.getPpDofActive = ffi.C.lj_getPpDofActive__impl
ac.getPpChromaticAbberationActive = ffi.C.lj_getPpChromaticAbberationActive__impl
ac.getPpGlareGhostActive = ffi.C.lj_getPpGlareGhostActive__impl
ac.getPpHeatParticleActive = ffi.C.lj_getPpHeatParticleActive__impl
ac.getPpAirydiskEnabled = ffi.C.lj_getPpAirydiskEnabled__impl
ac.getPpAntialiasingEnabled = ffi.C.lj_getPpAntialiasingEnabled__impl
ac.getPpAutoExposureEnabled = ffi.C.lj_getPpAutoExposureEnabled__impl
ac.getPpChromaticAbberationEnabled = ffi.C.lj_getPpChromaticAbberationEnabled__impl
ac.getPpFeedbackEnabled = ffi.C.lj_getPpFeedbackEnabled__impl
ac.getPpLensDistortionEnabled = ffi.C.lj_getPpLensDistortionEnabled__impl
ac.getPpHeatParticleEnabled = ffi.C.lj_getPpHeatParticleEnabled__impl
ac.getPpGlareEnabled = ffi.C.lj_getPpGlareEnabled__impl
ac.getPpGlareAnamorphicEnabled = ffi.C.lj_getPpGlareAnamorphicEnabled__impl
ac.setPpTonemapViewportScale = function(v)
	ffi.C.lj_setPpTonemapViewportScale__impl(__sane(v))
end
ac.setPpTonemapViewportOffset = function(v)
	ffi.C.lj_setPpTonemapViewportOffset__impl(__sane(v))
end
ac.setHeatParticles = function(v)
	ffi.C.lj_setHeatParticles__impl(__sane(v))
end
ac.isVertexAoPatchApplied = ffi.C.lj_isVertexAoPatchApplied__impl
ac.isTrackAmbientLowerMultiplierDefined = ffi.C.lj_isTrackAmbientLowerMultiplierDefined__impl
ac.getTrackAmbientLowerMultiplier = ffi.C.lj_getTrackAmbientLowerMultiplier__impl
ac.getTrackLightPollution = ffi.C.lj_getTrackLightPollution__impl
ac.getWeatherStaticAmbientLowerMultiplier = ffi.C.lj_getWeatherStaticAmbientLowerMultiplier__impl
ac.setWeatherStaticAmbient = function(upper, lower)
	ffi.C.lj_setWeatherStaticAmbient__impl(__sane(rgb.new(upper)), __sane(rgb.new(lower)))
end
ac.resetWeatherStaticAmbient = ffi.C.lj_resetWeatherStaticAmbient__impl
ac.setEmissiveCameraGain = function(direct, mirror)
	ffi.C.lj_setEmissiveCameraGain__impl(__sane(direct), __sane(mirror))
end
ac.setExtraAsphaltReflectionsMultiplier = function(value)
	ffi.C.lj_setExtraAsphaltReflectionsMultiplier__impl(__sane(value))
end
ac.setParticlesSmokeMaterial = function(material)
	ffi.C.lj_setParticlesSmokeMaterial__impl(__sane(material))
end
ac.setParticlesGrassMaterial = function(material)
	ffi.C.lj_setParticlesGrassMaterial__impl(__sane(material))
end
ac.setParticlesGrassPiecesMaterial = function(material)
	ffi.C.lj_setParticlesGrassPiecesMaterial__impl(__sane(material))
end
ac.setWeatherFakeShadowOpacity = function(v)
	ffi.C.lj_setWeatherFakeShadowOpacity__impl(__sane(v))
end
ac.setWeatherDynamicAmbientMultiplier = function(v)
	ffi.C.lj_setWeatherDynamicAmbientMultiplier__impl(__sane(v))
end
ac.setWeatherDynamicAmbientSaturation = function(v)
	ffi.C.lj_setWeatherDynamicAmbientSaturation__impl(__sane(v))
end
ac.setWeatherDynamicAmbientGamma = function(v)
	ffi.C.lj_setWeatherDynamicAmbientGamma__impl(__sane(v))
end
ac.setWeatherDynamicAmbientBrightness = function(v)
	ffi.C.lj_setWeatherDynamicAmbientBrightness__impl(__sane(v))
end
ac.setWeatherBouncedLightMultiplier = function(v)
	ffi.C.lj_setWeatherBouncedLightMultiplier__impl(__sane(rgb.new(v)))
end
ac.setWeatherBouncedInteriorLightMultiplier = function(v)
	ffi.C.lj_setWeatherBouncedInteriorLightMultiplier__impl(__sane(rgb.new(v)))
end
ac.setWeatherBouncedLightShDirection = function(v)
	ffi.C.lj_setWeatherBouncedLightShDirection__impl(__sane(v))
end
ac.setWeatherBouncedLightShMultiplier = function(v)
	ffi.C.lj_setWeatherBouncedLightShMultiplier__impl(__sane(v))
end
ac.setWeatherBouncedLightShSaturation = function(v)
	ffi.C.lj_setWeatherBouncedLightShSaturation__impl(__sane(v))
end
ac.getWeatherLightsMultiplier = ffi.C.lj_getWeatherLightsMultiplier__impl
ac.setWeatherLightsMultiplier = function(value)
	ffi.C.lj_setWeatherLightsMultiplier__impl(__sane(value))
end
ac.resetWeatherLightsMultiplier = ffi.C.lj_resetWeatherLightsMultiplier__impl
ac.getAutoExposure = ffi.C.lj_getAutoExposure__impl
ac.setAutoExposureActive = function(v)
	ffi.C.lj_setAutoExposureActive__impl(__sane(v))
end
ac.setAutoExposureInfluencedByGlare = function(v)
	ffi.C.lj_setAutoExposureInfluencedByGlare__impl(__sane(v))
end
ac.setAutoExposureTarget = function(v)
	ffi.C.lj_setAutoExposureTarget__impl(__sane(v))
end
ac.setAutoExposureMeasuringArea = function(center, size)
	ffi.C.lj_setAutoExposureMeasuringArea__impl(__sane(center), __sane(size))
end
ac.setAutoExposureLimits = function(min, max)
	ffi.C.lj_setAutoExposureLimits__impl(__sane(min), __sane(max))
end
ac.setSkyFogMultiplier = function(v)
	ffi.C.lj_setSkyFogMultiplier__impl(__sane(v))
end
ac.calculateSkyColor = function(v, include_sky_color, include_moon_color)
	return ffi.C.lj_calculateSkyColor__impl(__sane(v), __sane(include_sky_color), __sane(include_moon_color))
end
ac.setAiHeadlights = function(v)
	ffi.C.lj_setAiHeadlights__impl(__sane(v))
end
ac.loadSoundbank = function(soundbank, guids)
	ffi.C.lj_loadSoundbank__impl(soundbank ~= nil and tostring(soundbank) or nil, guids ~= nil and tostring(guids) or nil)
end
ac.setTrackCondition = function(key, value)
	ffi.C.lj_set_track_condition__impl(key, value)
end
__ac_obsolete()
__ac_lists()
