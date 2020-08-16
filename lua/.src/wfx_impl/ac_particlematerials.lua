ffi.cdef [[ 
typedef struct {
  float emissiveBlend, diffuse, ambient;
} particles_material;
]]
ac.ParticlesMaterial = ffi.metatype('particles_material', { __index = {} })