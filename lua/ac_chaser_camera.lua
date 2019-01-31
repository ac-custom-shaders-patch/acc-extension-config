	require "extension/lua/ac_common"
ffi.cdef [[
vec3 lj_getCamera_position();
void lj_setCamera_position(vec3 v);
vec3 lj_getCamera_direction();
void lj_setCamera_direction(vec3 v);
vec3 lj_getCamera_up();
void lj_setCamera_up(vec3 v);
float lj_getCamera_fov();
void lj_setCamera_fov(float v);
float lj_getCamera_dofFactor();
void lj_setCamera_dofFactor(float v);
float lj_getCamera_dofFocus();
void lj_setCamera_dofFocus(float v);
float lj_getCamera_dofRange();
void lj_setCamera_dofRange(float v);
float lj_getCamera_blurSpeed();
void lj_setCamera_blurSpeed(float v);
bool lj_getCamera_lensFlare();
void lj_setCamera_lensFlare(bool v);
bool lj_getCamera_chromaticAbberation();
void lj_setCamera_chromaticAbberation(bool v);
bool lj_getCamera_useBlur();
void lj_setCamera_useBlur(bool v);
bool lj_getCamera_useRadialBlur();
void lj_setCamera_useRadialBlur(bool v);
void lj_debug(const char* key, const char* value);
void lj_log(const char* value);
vec3 lj_getCarPosition();
vec3 lj_getCarDirection();
vec3 lj_getCarUp();
vec3 lj_getCarVelocity();
vec3 lj_getCarAngularVelocity();
vec3 lj_getCarLocalVelocity();
vec3 lj_getCarLocalAngularVelocity();
vec3 lj_getCarGForces();
bool lj_isGearGrinding();
float lj_getTurboBoost();
float lj_getEngineLifeLeft();
float lj_getCGHeight();
float lj_getTyreSlip(int tyre);
float lj_getTyreSlipRatio(int tyre);
float lj_getTyreSlipAngle(int tyre);
float lj_getTyreAngularSpeed(int tyre);
vec3 lj_getTyreContactPoint(int tyre);
vec3 lj_getTyrePosition(int tyre);
vec3 lj_getTyreDirection(int tyre);
float lj_getDamageLevel(int side);
float lj_getSteer();
float lj_getGas();
float lj_getBrake();
float lj_getClutch();
int lj_getGear();
bool lj_looksLeft();
bool lj_looksRight();
bool lj_looksBehind();
vec3 lj_get_joystick_look();
vec3 lj_get_camera_params_as_vec3(int index);
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
ac.debug = function(key, value)
	ffi.C.lj_debug(__sane(tostring(key)), __sane(tostring(value)))
end
ac.log = function(value)
	ffi.C.lj_log(__sane(tostring(value)))
end
ac.getCarPosition = ffi.C.lj_getCarPosition
ac.getCarDirection = ffi.C.lj_getCarDirection
ac.getCarUp = ffi.C.lj_getCarUp
ac.getCarVelocity = ffi.C.lj_getCarVelocity
ac.getCarAngularVelocity = ffi.C.lj_getCarAngularVelocity
ac.getCarLocalVelocity = ffi.C.lj_getCarLocalVelocity
ac.getCarLocalAngularVelocity = ffi.C.lj_getCarLocalAngularVelocity
ac.getCarGForces = ffi.C.lj_getCarGForces
ac.isGearGrinding = ffi.C.lj_isGearGrinding
ac.getTurboBoost = ffi.C.lj_getTurboBoost
ac.getEngineLifeLeft = ffi.C.lj_getEngineLifeLeft
ac.getCGHeight = ffi.C.lj_getCGHeight
ac.getTyreSlip = function(tyre)
	return ffi.C.lj_getTyreSlip(__sane(tyre))
end
ac.getTyreSlipRatio = function(tyre)
	return ffi.C.lj_getTyreSlipRatio(__sane(tyre))
end
ac.getTyreSlipAngle = function(tyre)
	return ffi.C.lj_getTyreSlipAngle(__sane(tyre))
end
ac.getTyreAngularSpeed = function(tyre)
	return ffi.C.lj_getTyreAngularSpeed(__sane(tyre))
end
ac.getTyreContactPoint = function(tyre)
	return ffi.C.lj_getTyreContactPoint(__sane(tyre))
end
ac.getTyrePosition = function(tyre)
	return ffi.C.lj_getTyrePosition(__sane(tyre))
end
ac.getTyreDirection = function(tyre)
	return ffi.C.lj_getTyreDirection(__sane(tyre))
end
ac.getDamageLevel = function(side)
	return ffi.C.lj_getDamageLevel(__sane(side))
end
ac.getSteer = ffi.C.lj_getSteer
ac.getGas = ffi.C.lj_getGas
ac.getBrake = ffi.C.lj_getBrake
ac.getClutch = ffi.C.lj_getClutch
ac.getGear = ffi.C.lj_getGear
ac.looksLeft = ffi.C.lj_looksLeft
ac.looksRight = ffi.C.lj_looksRight
ac.looksBehind = ffi.C.lj_looksBehind
ac.Camera = {}
setmetatable(ac.Camera, {
	__index = function(self, k)
		if k == 'position' then
			return ffi.C.lj_getCamera_position()
		elseif k == 'direction' then
			return ffi.C.lj_getCamera_direction()
		elseif k == 'up' then
			return ffi.C.lj_getCamera_up()
		elseif k == 'fov' then
			return ffi.C.lj_getCamera_fov()
		elseif k == 'dofFactor' then
			return ffi.C.lj_getCamera_dofFactor()
		elseif k == 'dofFocus' then
			return ffi.C.lj_getCamera_dofFocus()
		elseif k == 'dofRange' then
			return ffi.C.lj_getCamera_dofRange()
		elseif k == 'blurSpeed' then
			return ffi.C.lj_getCamera_blurSpeed()
		elseif k == 'lensFlare' then
			return ffi.C.lj_getCamera_lensFlare()
		elseif k == 'chromaticAbberation' then
			return ffi.C.lj_getCamera_chromaticAbberation()
		elseif k == 'useBlur' then
			return ffi.C.lj_getCamera_useBlur()
		elseif k == 'useRadialBlur' then
			return ffi.C.lj_getCamera_useRadialBlur()
		else
			error('Camera does not have an attribute `' .. k .. '`')
		end
	end,
	__newindex = function(self, k, v)
		if k == 'position' then
			ffi.C.lj_setCamera_position(v)
		elseif k == 'direction' then
			ffi.C.lj_setCamera_direction(v)
		elseif k == 'up' then
			ffi.C.lj_setCamera_up(v)
		elseif k == 'fov' then
			ffi.C.lj_setCamera_fov(v)
		elseif k == 'dofFactor' then
			ffi.C.lj_setCamera_dofFactor(v)
		elseif k == 'dofFocus' then
			ffi.C.lj_setCamera_dofFocus(v)
		elseif k == 'dofRange' then
			ffi.C.lj_setCamera_dofRange(v)
		elseif k == 'blurSpeed' then
			ffi.C.lj_setCamera_blurSpeed(v)
		elseif k == 'lensFlare' then
			ffi.C.lj_setCamera_lensFlare(v)
		elseif k == 'chromaticAbberation' then
			ffi.C.lj_setCamera_chromaticAbberation(v)
		elseif k == 'useBlur' then
			ffi.C.lj_setCamera_useBlur(v)
		elseif k == 'useRadialBlur' then
			ffi.C.lj_setCamera_useRadialBlur(v)
		else
			error('Camera does not have an attribute `' .. k .. '`')
		end
	end
})
ac.getCameraParameters = function(index)
	local parameters = ffi.C.lj_get_camera_params_as_vec3(index)
	return {
		distance = parameters.x,
		height = parameters.y,
		pitch = parameters.z
	}
end
ac.getJoystickLook = function()
	local parameters = ffi.C.lj_get_joystick_look()
	return parameters.x ~= 0 and vec2(parameters.y, parameters.z) or nil
end
