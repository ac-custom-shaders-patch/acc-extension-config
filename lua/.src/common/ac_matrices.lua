ffi.cdef [[ 
typedef struct {
  vec3 row1;
  vec3 row2;
  vec3 row3;
} mat3x3;
]]

mat3x3 = ffi.metatype('mat3x3', { __index = {} })
