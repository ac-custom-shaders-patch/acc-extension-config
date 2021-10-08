-- Copyright (c) 2012-2014 Evan Wies.  All rights reserved.
-- MIT License, see the COPYRIGHT file.
-- https://github.com/neomantra/lds

local ffi = require 'ffi'
local C = ffi.C

local size_t = ffi.typeof('size_t')

local function simple_deep_copy( x )
  if type(x) ~= 'table' then return x end
  local t = {}
  for k, v in pairs(x) do
    t[k] = simple_deep_copy(v)
  end
  return t
end

ffi.cdef [[
void* lj_calloc(size_t count, size_t size);
void* lj_realloc(void *ptr, size_t size);
void* lj_memmove(void *dst, const void *src, size_t len);
void lj_free(void *ptr); 
]]

local MallocAllocatorT__mt = {
  __index = {
    allocate  = function(self, n)
      return C.lj_calloc( n, self._ct_size )
    end,
    deallocate = function(self, p)
      if p ~= 0 then C.lj_free(p) end
    end,
    reallocate = function(self, p, n)
      return C.lj_realloc(p, n)
    end,
  }
}

local function MallocAllocatorT( ct, which )
  if type(ct) ~= 'cdata' then error('argument 1 is not a valid "cdata"') end
  local t_mt = simple_deep_copy(MallocAllocatorT__mt)
  t_mt.__index._ct = ct
  t_mt.__index._ct_size = ffi.sizeof(ct)
  local t_anonymous = ffi.typeof('struct {}')
  return ffi.metatype(t_anonymous, t_mt)
end

local function MallocAllocator(ct)
  return MallocAllocatorT(ct)()
end

local VectorT__cdef = [[ struct { $ * _data; int _size; int _cap; } ]]

local function VectorT__resize(v, reserve_n, shrinkToFit)
  local new_cap = math.max(1, reserve_n or 2 * v._cap, shrinkToFit and 1 or 2 * v._cap)
  if v._cap >= new_cap then return end
  local new_data = v.__alloc:reallocate(v._data, new_cap * v.__ct_size)
  v._data = ffi.cast(v._data, new_data)
  v._cap = new_cap
end 

local Vector = {}

function Vector:size()
  return self._size
end

function Vector:sizeBytes()
  return self._size * self.__ct_size
end

function Vector:isEmpty()
  return self._size == 0
end

function Vector:capacity()
  return self._cap
end

function Vector:capacityBytes()
  return self._cap * self.__ct_size
end

function Vector:reserve(reserve_n)
  VectorT__resize(self, reserve_n)
end

function Vector:shrinkToFit()
  VectorT__resize(self, self._size, true)
end

function Vector:get(i)
  if i < 1 or i > self._size then return nil end
  return self._data[i - 1]
end

function Vector:data()
  return self._data
end

function Vector:set(i, x)
  if x == nil then self:remove(i) end
  if i > self._size + 1 then i = self._size + 1 end
  if i > self._cap then
    VectorT__resize(self, math.max(i, self._cap * 2))
    self._size = i
  elseif i < 1 then return nil end
  self._data[i - 1] = x
  if i > self._size then self._size = i end
  self.__keep_alive[i] = x
end

function Vector:insert(i, x)
  if type(x) == 'nil' then self:push(i) 
  elseif i < 1 then error("insert: index out of bounds")
  elseif i > self._size then self:push(x) 
  else
    if self._size + 1 > self._cap then VectorT__resize(self) end
    C.lj_memmove(self._data + i, self._data + i - 1, (self._size - i + 1) * self.__ct_size)
    self._data[i - 1] = x
    self._size = self._size + 1
    table.insert(self.__keep_alive, i, x)
  end
end

function Vector:push(x)
  if x == nil then return end
  self:set(self._size + 1, x)
end

function Vector:pushWhereFits(x)
  for i = 1, #self do
    if self:get(i) == nil then
      self:set(i, x)
      return i
    end
  end
  self:push(x)
  return #self
end

function Vector:erase(x)
  for i = 1, #self do
    if self:get(i) == x then
      self:remove(i)
      return
    end
  end
end

function Vector:remove(i)
  if type(i) == 'nil' then return self:pop() end
  if i < 1 or i > self._size then return nil end
  local x = self._data[i - 1]
  C.lj_memmove(self._data + i - 1, self._data + i, (self._size - i + 1) * self.__ct_size)
  self._size = self._size - 1
  table.remove(self.__keep_alive, i)
  return x
end

function Vector:pop()
  if self._size == 0 then return nil end
  local x = self._data[self._size - 1]
  self._size = self._size - 1
  table.remove(self.__keep_alive, #self.__keep_alive)
  return x
end

function Vector:clear()
  self._size = 0
  for k in pairs(self.__keep_alive) do
    self.__keep_alive[k] = nil
  end
  -- self.__keep_alive = {}
end

local VectorT__mt = {
  __new = function(vt, reserve_n)
    local self = ffi.new(vt)
    reserve_n = 16
    if reserve_n and reserve_n > 0 then
      local data = self.__alloc:allocate(reserve_n)
      if data == nil then error('VectorT.new allocation failed') end
      self._data, self._size, self._cap = data, 0, reserve_n
    else
      self._data, self._size, self._cap = nil, 0, 0
    end
    if self.__cb ~= 0 then ffi.C[self.__cb](self) end
    return self
  end,
  __gc = function( self ) 
    self.__alloc:deallocate(self._data)
    self.__keep_alive = {}
    self._data, self._cap, self._size = nil, 0, 0
    if self.__cb ~= 0 then ffi.C[self.__cb](nil) end
    return self
  end,
  __len = function( self ) return self._size end,
  __index = Vector,
  __newindex = function (self, k, v) return self:set(k, v) end,
}

local function VectorT(ct, cb)
  if type(ct) ~= 'cdata' then error("argument 1 is not a valid 'cdata'") end

  local vt_mt = simple_deep_copy(VectorT__mt)
  vt_mt.__index.__ct = ct
  vt_mt.__index.__ct_size = ffi.sizeof(ct)
  vt_mt.__index.__alloc = MallocAllocator(ct)
  vt_mt.__index.__keep_alive = {}
  vt_mt.__index.__cb = cb or 0

  local vt = ffi.typeof(VectorT__cdef, ct)
  local result = ffi.metatype(vt, vt_mt)()

  -- todo: is there a better way?
  setmetatable(vt_mt.__index, {
    __index = function (self, k) return result:get(k) end,
    -- __newindex = function (self, k, v) result:set(k, v) end,
  })

  return result
end

__vector = Vector
function __bound_array(ct, cb) return VectorT(ct, cb) end
