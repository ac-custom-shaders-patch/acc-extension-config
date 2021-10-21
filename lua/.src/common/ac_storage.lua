__source 'lua/api_storage.cpp'

ffi.cdef [[ 
typedef struct {
  uint64_t key;
  uint32_t phase_storage;
  uint32_t phase_value;
  bool changed;
} storage_ref;
]]

__post_cdef(function ()

  local function createType(fnDefault, fnGet, fnSet, fnConvert, fnReset, fnSetApply)
    if fnConvert == nil then fnConvert = function (dst, value) dst.value = value end end
    if fnReset == nil then fnReset = function (dst) dst.value = dst.default end end
    return function(key, default)
      return setmetatable({ ref = ffi.C.lj_storage_ref_init(__util.str(key)), default = fnDefault(default), value = default }, { __index = {
        get = function(self)
          local curValue = fnGet(self.ref, self.default)
          if self.ref.changed then
            if curValue == nil then fnReset(self) else fnConvert(self, curValue) end
          end
          return self.value
        end,
        set = function(self, value)
          if fnSet(self.ref, value) and fnSetApply ~= nil then
            fnSetApply(self, value)
          end
        end
      } })
    end
  end

  local storedNumber = createType(
    function(def) return tonumber(def) or 0 end,
    function(ref, def) return ffi.C.lj_storage_ref_sync_number(ref, def) end,
    function(ref, value) return ffi.C.lj_storage_ref_store_number(ref, tonumber(value) or 0, value ~= nil) end)
  local storedBoolean = createType(
    function(def) return def == true end,
    function(ref, def) return ffi.C.lj_storage_ref_sync_boolean(ref, def) end,
    function(ref, value) return ffi.C.lj_storage_ref_store_boolean(ref, value == true, value ~= nil) end)
  local storedString = createType(
    function(def) return def ~= nil and tostring(def) or nil end,
    function(ref) return ffi.C.lj_storage_ref_sync_string(ref) end,
    function(ref, value) return ffi.C.lj_storage_ref_store_string(ref, value ~= nil and tostring(value) or nil) end,
    function(dst, value) dst.value = __util.strref(value) end, nil,
    function(dst, value) dst.value = value ~= nil and value or dst.default end)

  local function createVecType(fnType, fnSync, fnStore, fnCast)
    local tmpVec = fnType()
    return createType(
      function(def) return def:clone() end,
      function(ref) return fnSync(ref) end,
      function(ref, value) return fnStore(ref, fnCast(tmpVec, value, nil)) end,
      function(dst, value) dst.value:set(value[0]) end,
      function(dst) return dst.value:set(dst.default) end)
  end

  local storedVec2 = createVecType(vec2, ffi.C.lj_storage_ref_sync_vec2, ffi.C.lj_storage_ref_store_vec2, __util.cast_vec2)
  local storedVec3 = createVecType(vec3, ffi.C.lj_storage_ref_sync_vec3, ffi.C.lj_storage_ref_store_vec3, __util.cast_vec3)
  local storedVec4 = createVecType(vec4, ffi.C.lj_storage_ref_sync_vec4, ffi.C.lj_storage_ref_store_vec4, __util.cast_vec4)
  local storedRgb = createVecType(rgb, ffi.C.lj_storage_ref_sync_rgb, ffi.C.lj_storage_ref_store_rgb, __util.cast_rgb)
  local storedRgbm = createVecType(rgbm, ffi.C.lj_storage_ref_sync_rgbm, ffi.C.lj_storage_ref_store_rgbm, __util.cast_rgbm)

  local function createStored(key, default)
    if type(key) ~= 'string' then key = tostring(key) end
    if type(default) == 'string' or default == nil then return storedString(key, default) end
    if type(default) == 'number' then return storedNumber(key, default) end
    if type(default) == 'boolean' then return storedBoolean(key, default) end
    if type(default) == 'cdata' then 
      if vec2.isvec2(default) then return storedVec2(key, default) end
      if vec3.isvec3(default) then return storedVec3(key, default) end
      if vec4.isvec4(default) then return storedVec4(key, default) end
      if rgb.isrgb(default) then return storedRgb(key, default) end
      if rgbm.isrgbm(default) then return storedRgbm(key, default) end
    end
    error('Type is not supported: '..type(default))
  end

  local storedMetatable = {
    __index = function(self, key) return self.__data__[key]:get() end,
    __newindex = function(self, key, value) return self.__data__[key]:set(value) end,
  }

  local function storedItems(data)
    local self = setmetatable({ __data__ = {} }, storedMetatable)
    for key, value in pairs(data) do
      self.__data__[key] = createStored(key, value)
    end
    return self
  end

  ac.storage = {}
  setmetatable(ac.storage, {
    __index = function(s, key)
      local v = ffi.C.lj_storage_get_string(__util.str(key))
      return v and __util.strref(v) or nil
    end,
    __newindex = function(s, key, value) 
      ffi.C.lj_storage_store_string(__util.str(key), value ~= nil and tostring(value) or nil)
    end,
    __call = function(s, key, default)
      if default == nil and type(key) == 'table' then
        return storedItems(key)
      end
      return createStored(key, default)
    end
  })

  -- Example:
  function ac.StorageTest()
    ac.storage.key = 'value'
    ac.debug('loaded', ac.storage.key)
    local stored = ac.storage('someKey', 15)
    stored:get()
    stored:set(20)

    local storedValues = ac.storage{
      someKey = 15,
      someStringValue = 20
    }
    storedValues.someKey = 20
  end

end)
