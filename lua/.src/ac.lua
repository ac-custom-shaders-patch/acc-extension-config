ac = {}

function __num_fallback(v, f)
  if type(v) ~= 'number' then return f end
  return v
end

-- local STP = require 'extension/weather/base/stp'
-- debug.traceback = STP.stacktrace

require 'ffi'
require 'extension/weather/base/vector'
require 'extension/weather/base/ac_primitive'
require 'extension/weather/base/ac_clouds'
require 'extension/weather/base/ac_gradients'
require 'extension/weather/base/ac_weatherconditions'
require 'extension/weather/base/ac_colorcorrections'
require 'extension/weather/base/ac_definitions'
require 'extension/weather/base/ac_enums'
require 'extension/weather/base/ac_obsolete'
require 'extension/weather/base/ac_lists'
require 'extension/weather/base/math'
