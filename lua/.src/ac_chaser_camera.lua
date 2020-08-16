require './ac_common'

ffi.cdef [[
DEFINITIONS
]]
SANE
EXPORT

ac.getCameraParameters = function (index)
  local parameters = ffi.C.lj_get_camera_params_as_vec3(index)
  return { distance = parameters.x, height = parameters.y, pitch = parameters.z }
end

ac.getJoystickLook = function ()
  local parameters = ffi.C.lj_get_joystick_look()
  return parameters.x ~= 0 and vec2(parameters.y, parameters.z) or nil
end
