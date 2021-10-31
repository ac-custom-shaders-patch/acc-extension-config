__source 'lua/api_ray.cpp'
__namespace 'render'

ffi.cdef [[ 
typedef struct {
  vec3 pos;
  vec3 dir;
  vec3 _pad0;
  vec3 _pad1;
  float length;
} ray;
]]

__post_cdef(function ()
  ray = ffi.metatype('ray', { __index = {
    aabb = function(s, min, max) return ffi.C.lj_ray_aabb__render(s, __util.ensure_vec3(min), __util.ensure_vec3(max)) end,
    line = function(s, from, to, width) return ffi.C.lj_ray_line__render(s, __util.ensure_vec3(from), __util.ensure_vec3(to), width) end,
    triangle = function(s, p1, p2, p3) return ffi.C.lj_ray_triangle__render(s, __util.ensure_vec3(p1), __util.ensure_vec3(p2), __util.ensure_vec3(p3)) end,
    sphere = function(s, center, radius) return ffi.C.lj_ray_sphere__render(s, __util.ensure_vec3(center), tonumber(radius) or 0) end,
    track = ffi.C.lj_ray_track__render,
    scene = ffi.C.lj_ray_scene__render,
    cars = ffi.C.lj_ray_cars__render,
    distance = function(s, p) 
      local v = p - s.pos
      local t = v:dot(s.dir)
      return p:distance(v:set(s.dir):scale(t):add(s.pos))
    end
  } })
end)
