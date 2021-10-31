ffi.cdef [[ 
typedef struct {
  vec3 row1;
  vec3 row2;
  vec3 row3;
} mat3x3;
]]

mat3x3 = ffi.metatype('mat3x3', { __index = {} })

ffi.cdef [[ 
typedef struct {
  vec4 row1;
  vec4 row2;
  vec4 row3;
  vec4 row4;
} mat4x4;
]]

mat4x4 = ffi.metatype('mat4x4', { __index = {} })
