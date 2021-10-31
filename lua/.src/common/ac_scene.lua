__source 'lua/api_scene.cpp'
__allow 'scene'

local function cr(v)
  if v == nil then return nil end
  return ffi.gc(v, ffi.C.lj_noderef_gc__scene)
end

local function nf(v)
  if type(v) == 'table' then
    return '{' .. table.join(v, ', ') .. '}'
  end
  return v ~= nil and tostring(v) or ""
end

local __emptyNodeRef = nil
local function emptyNodeRef()
  if __emptyNodeRef == nil then
    __emptyNodeRef = cr(ffi.C.lj_noderef_new__scene(nil, 1))
  end
  return __emptyNodeRef
end

ffi.cdef [[ typedef struct { int __size; } noderef; ]]
ffi.metatype('noderef', { __index = {
  dispose = function (s) return ffi.C.lj_noderef_dispose__scene(s) end,
  setMaterialProperty = function (s, property, value)
    property = __util.str(property)
    if type(value) == 'number' then ffi.C.lj_noderef_setmaterialproperty1__scene(s, property, value)
    elseif vec2.isvec2(value) then ffi.C.lj_noderef_setmaterialproperty2__scene(s, property, value)
    elseif vec3.isvec3(value) then ffi.C.lj_noderef_setmaterialproperty3__scene(s, property, value)
    elseif rgb.isrgb(value) then ffi.C.lj_noderef_setmaterialproperty3c__scene(s, property, value)
    elseif vec4.isvec4(value) then ffi.C.lj_noderef_setmaterialproperty4__scene(s, property, value) 
    elseif rgbm.isrgbm(value) then ffi.C.lj_noderef_setmaterialproperty4c__scene(s, property, value) 
    elseif type(value) == 'boolean' then ffi.C.lj_noderef_setmaterialproperty1__scene(s, property, value and 1 or 0) 
    else error('Not supported type: '..value) end
  end,
  setMaterialTexture = function (s, texture, color) return ffi.C.lj_noderef_setmaterialtexture__scene(s, texture, __util.ensure_rgbm(color)) end,
  ensureUniqueMaterials = function (s) return ffi.C.lj_noderef_ensureuniquematerials__scene(s) end,
  size = function (s) return s.__size end,
  empty = function (s) return s.__size == 0 end,

  findAny = function (s, filter) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 0)) end,
  findNodes = function (s, filter) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 1)) end,
  findMeshes = function (s, filter) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 2)) end,
  findSkinnedMeshes = function (s, filter) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_find__scene(s, nf(filter), 4)) end,

  createNode = function (s, name) return cr(ffi.C.lj_noderef_createnode__scene(s, name)) end,  -- can return nil if failed
  createBoundingSphereNode = function (s, name, radius) return cr(ffi.C.lj_noderef_createbsnode__scene(s, name, radius)) end,  -- can return nil if failed
  loadKN5 = function (s, filename) return cr(ffi.C.lj_noderef_loadkn5__scene(s, filename)) end,  -- can return nil if failed
  loadKN5LOD = function (s, filename, mainFilename) return cr(ffi.C.lj_noderef_loadkn5lod__scene(s, filename, mainFilename)) end,  -- can return nil if failed
  
  setVisible = function (s, visible) return ffi.C.lj_noderef_setvisible__scene(s, visible == true) end,
  setShadows = function (s, shadows) return ffi.C.lj_noderef_setshadows__scene(s, shadows == true) end,
  setTransparent = function (s, transparent) return ffi.C.lj_noderef_settransparent__scene(s, transparent == true) end,
  setPosition = function (s, pos) 
    return ffi.C.lj_noderef_setposition__scene(s, __util.ensure_vec3(pos))
  end,
  setOrientation = function (s, look, up) 
    return ffi.C.lj_noderef_setorientation__scene(s, __util.ensure_vec3(look), up and __util.ensure_vec3(up) or vec3(0, 1, 0))
  end,
  rotate = function (s, axis, angleRad) 
    return ffi.C.lj_noderef_rotate__scene(s, __util.ensure_vec3(axis), angleRad)
  end,
  getPosition = function (s) 
    return ffi.C.lj_noderef_getposition__scene(s)
  end,
  getLook = function (s) 
    return ffi.C.lj_noderef_getlook__scene(s)
  end,
  getUp = function (s) 
    return ffi.C.lj_noderef_getup__scene(s)
  end,
} })
ac.findAny = function (s) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 0)) end
ac.findNodes = function (s) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 1)) end
ac.findMeshes = function (s) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 2)) end
ac.findSkinnedMeshes = function (s) return s == nil and emptyNodeRef() or cr(ffi.C.lj_noderef_new__scene(nf(s), 4)) end
