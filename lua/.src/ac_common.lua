__source 'lua/api_common.cpp'

ac = {}

-- not doing anything anymore, kept for compatibility:
ac.skipSaneChecks = function() end

-- all sorts of modules:
require 'ffi'
require './deps/vector'
require './common/ac_primitive'
require './common/function'
require './common/math'
require './common/table'
require './common/timer'
require './common/internal'
require './common/io'
require './common/ac_enums'
require './common/ac_numlut'
require './common/ac_state'
require './common/ac_trackconfig'
require './common/ac_reftypes'

-- a simple wrapper for creating new classes, similar to middleclass (check that file for more info)
class = require './common/class'

-- for better compatibility
function print(v) ac.log(v) end

-- calls fn() and then catch() if fn() would fail, and finally() at the end, both catch and finally can be nil
function try(fn, catch, finally)
  if not fn then 
    return finally()
  end
  local ranFine, result = pcall(fn)
  if ranFine then
    if finally ~= nil then finally() end
    return result
  else
    if catch ~= nil then catch(result) end
    if finally ~= nil then return finally() end
  end
end

-- calls fn() and then dispose() even if fn() would fail
local __toDispose = {}
function using(fn, dispose)
  table.insert(__toDispose, dispose)
  fn()
  dispose()
  table.remove(__toDispose)
end
function __handleError()
  for i = #__toDispose, 1, -1 do
    __toDispose[i]()
  end
  __toDispose = {}
end

-- functions to exchange data with other scripts and Python apps, allow to transfer strings or numbers:
function ac.store(key, value)
  key = tostring(key or "")
  if type(value) == 'number' then
    ffi.C.lj_store_number(key, value)
  else
    ffi.C.lj_store_string(key, value ~= nil and tostring(value) or nil)
  end
end

function ac.load(key)
  key = tostring(key or "")
  if ffi.C.lj_has_number(key) then
    return ffi.C.lj_load_number(key)
  else
    return __util.strref(ffi.C.lj_load_string(key))
  end
end

-- for easy import of scripts from subdirectories
function package.add(dir)
  package.path = package.path .. ';' .. __dirname .. '/' .. dir .. '/?.lua'
end

-- automatically generated entries go here:
__definitions()
