	local function __ac_fireworks()
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
	ac.Firework = function(t)
		local created = ffi.C.lj_firework_new()
		return ffi.gc(created, ffi.C.lj_firework_gc)
	end
end
local function __ac_lists()
	ac.fireworks = __bound_array(ffi.typeof('firework*'), 'lj_set_fireworks')
	ac.addFirework = function(item)
		return ac.fireworks:pushWhereFits(item)
	end
end
require "extension/lua/ac_common"
__ac_fireworks()
ffi.cdef [[
vec3 lj_getRandomFireworksSpot();
vec3 lj_getFireworksSpot(uint32_t index);
uint32_t lj_getFireworksSpotCount();
void lj_addFireworkFlash(uint32_t group, const vec3& pos, const rgb& color, float duration);
firework* lj_firework_new();
void lj_firework_gc(firework* r);
void lj_set_fireworks(const void* arr);
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
ac.getRandomFireworksSpot = ffi.C.lj_getRandomFireworksSpot
ac.getFireworksSpot = function(index)
	return ffi.C.lj_getFireworksSpot(__sane(index))
end
ac.getFireworksSpotCount = ffi.C.lj_getFireworksSpotCount
ac.addFireworkFlash = function(group, pos, color, duration)
	ffi.C.lj_addFireworkFlash(__sane(group), __sane(pos), __sane(rgb.new(color)), __sane(duration))
end
__ac_lists()
