__source 'apps/positioning_helper.cpp'
__namespace 'render'

require './ac_ray'

ffi.cdef [[ 
typedef struct {
  void* __car;
  uint __highlighted_axis_bits_;
  int __highlighted_rotational_axis_;
  bool __moving_active_;
  bool __rotating_active_;
  bool __relative_coords_;

  vec2 __rotating_start_pos_;
  vec3 __drag_start_origin_;
  ray __drag_start_onscreen_;
} positioning_helper;
]]

__post_cdef(function ()
  render.PositioningHelper = ffi.metatype('positioning_helper', { __index = {
    render = function(s, pos, inactive) 
      return ffi.C.lj_positioninghelper_render__render(s, __util.ensure_vec3(pos), inactive and true or false) 
    end,
    renderAligned = function(s, pos, look, inactive) 
      return ffi.C.lj_positioninghelper_render_l__render(s, __util.ensure_vec3(pos), __util.ensure_vec3(look), inactive and true or false)
    end,
    renderFullyAligned = function(s, pos, look, up, inactive) 
      return ffi.C.lj_positioninghelper_render_lu__render(s, __util.ensure_vec3(pos), __util.ensure_vec3(look), __util.ensure_vec3(up), inactive and true or false) 
    end,
    anyHighlight = ffi.C.lj_positioninghelper_anyhighlight__render,
    movingInScreenSpace = ffi.C.lj_positioninghelper_movinginscreenspace__render,
  } })
end)
