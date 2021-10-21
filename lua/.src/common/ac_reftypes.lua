ffi.cdef [[ 
typedef struct { bool value; } refbool;
typedef struct { float value; } refnumber;
]]

refbool = ffi.metatype('refbool', { __index = {} })
refnumber = ffi.metatype('refnumber', { __index = {} })