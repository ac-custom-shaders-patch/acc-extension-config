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
require "extension/lua/ac_common"
__ac_weatherconditions()
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
void lj_debug__controller(const char* key, const char* value);
void lj_log__controller(const char* value);
void lj_warn__controller(const char* value);
void lj_error__controller(const char* value);
char lj_getInputWeatherType__controller();
weather_conditions_temperatures lj_getInputTemperatures__controller();
weather_conditions_wind lj_getInputWind__controller();
weather_conditions_track lj_getInputTrackState__controller();
void lj_setConditionsSet__controller(const weather_conditions& c);
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
	ffi.C.lj_debug__controller(key ~= nil and tostring(key) or nil, value ~= nil and tostring(value) or nil)
end
ac.log = function(value)
	ffi.C.lj_log__controller(value ~= nil and tostring(value) or nil)
end
ac.warn = function(value)
	ffi.C.lj_warn__controller(value ~= nil and tostring(value) or nil)
end
ac.error = function(value)
	ffi.C.lj_error__controller(value ~= nil and tostring(value) or nil)
end
ac.getInputWeatherType = ffi.C.lj_getInputWeatherType__controller
ac.getInputTemperatures = ffi.C.lj_getInputTemperatures__controller
ac.getInputWind = ffi.C.lj_getInputWind__controller
ac.getInputTrackState = ffi.C.lj_getInputTrackState__controller
ac.setConditionsSet = function(c)
	ffi.C.lj_setConditionsSet__controller(__sane(c))
end
