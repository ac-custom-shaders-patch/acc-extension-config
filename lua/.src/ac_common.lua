__source 'lua/api_common.cpp'

ac = {}

-- not doing anything anymore, kept for compatibility:
ac.skipSaneChecks = function() end

-- all sorts of modules:
require 'ffi'
require './deps/vector'
require './common/ac_primitive'
require './common/math'
require './common/internal'
require './common/ac_enums'
require './common/ac_state'
require './common/ac_trackconfig'

-- for better compatibility
print = ac.log

-- functions to exchange data with other scripts and Python apps, allow to transfer strings or numbers:
ac.store = function(key, value)
  key = tostring(key or "")
  if type(value) == 'number' then
    ffi.C.lj_store_number(key, value)
  else
    ffi.C.lj_store_string(key, value ~= nil and tostring(value or "") or value)
  end
end

ac.load = function(key)
  key = tostring(key or "")
  if ffi.C.lj_has_number(key) then
    return ffi.C.lj_load_number(key)
  else
    return ffi.string(ffi.C.lj_load_string(key))
  end
end

-- automatically generated entries go here:
__definitions()
