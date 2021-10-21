__source 'lua/api_scene.cpp'
__allow 'scene'

ffi.cdef [[ typedef struct { void* __data[6]; int size; int __pad; } noderef; ]]
ffi.metatype('noderef', { __index = {
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
  ensureUniqueMaterials = function (s) return ffi.C.lj_noderef_ensureuniquematerials__scene(s) end,
  setVisible = function (s, visible) return ffi.C.lj_noderef_setvisible__scene(s, visible) end,
  setPosition = function (s, pos) 
    return ffi.C.lj_noderef_setposition__scene(s, __util.ensure_vec3(pos))
  end,
  setOrientation = function (s, look, up) 
    return ffi.C.lj_noderef_setorientation__scene(s, __util.ensure_vec3(look), up and __util.ensure_vec3(up) or vec3(0, 1, 0))
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
ac.findNodes = function (filter)
  return ffi.gc(
    ffi.C.lj_noderef_new__scene(__util.str(filter), 1),
    ffi.C.lj_noderef_gc__scene)
end
ac.findMeshes = function (filter)
  return ffi.gc(
    ffi.C.lj_noderef_new__scene(__util.str(filter), 2),
    ffi.C.lj_noderef_gc__scene)
end
ac.findSkinnedMeshes = function (filter)
  return ffi.gc(
    ffi.C.lj_noderef_new__scene(__util.str(filter), 4),
    ffi.C.lj_noderef_gc__scene)
end