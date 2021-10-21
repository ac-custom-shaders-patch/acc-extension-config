__source 'extensions/track_adjustments/track_scriptable_display.cpp'
__allow 'tsd'

require './common/ac_ui'
require './common/ac_display'
require './common/ac_audio'
require './common/ac_light'
require './common/ac_storage'
require './common/ac_scene'
require './common/ac_web'

-- access to track conditions
ffi.cdef [[ typedef struct { void* __data[4]; } trackcondition; ]]
ffi.metatype('trackcondition', { __index = {
  get = function (s) return ffi.C.lj_trackcondition_get__tsd(s) end,
  getColor = function (s) return ffi.C.lj_trackcondition_getcolor__tsd(s) end,
  isDynamic = function (s) return ffi.C.lj_trackcondition_isdynamic__tsd(s) end,
} })
ac.TrackCondition = function (expression, offset, defaultValue)
  return ffi.gc(
    ffi.C.lj_trackcondition_new__tsd(__util.str(expression), tonumber(offset) or 0, tonumber(defaultValue) or 0),
    ffi.C.lj_trackcondition_gc__tsd)
end

-- automatically generated entries go here:
__definitions()

-- extra additions:
sim = nil
function __init__()
  sim = ac.getSimState()
end
