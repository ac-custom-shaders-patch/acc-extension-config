__source 'extensions/weather_fx/ac_ext_weather_fx__lua.h'
__allow 'impl'

require './common/ac_audio'
require './common/ac_color_corrections'
require './common/ac_light'
require './common/ac_render'
require './wfx_common/ac_weatherconditions'
require './wfx_impl/ac_clouds'
require './wfx_impl/ac_cloudscovers'
require './wfx_impl/ac_gradients'
require './wfx_impl/ac_particlematerials'
require './wfx_impl/ac_lightpollution'

-- automatically generated entries go here:
__definitions()

ac.setTrackCondition = function (key, value)
  ffi.C.lj_set_track_condition__impl(key, value)
end

require './wfx_impl/ac_obsolete'
require './wfx_impl/ac_lists'
