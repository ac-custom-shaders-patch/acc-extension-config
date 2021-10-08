ac.getTrackConfig = function ()
  return {
    bool = function(key, value, def) return ffi.C.lj_cfg_track_bool(tostring(key or ""), tostring(value or ""), def and true or false) end,
    number = function(key, value, def) return ffi.C.lj_cfg_track_decimal(tostring(key or ""), tostring(value or ""), def or 0) end,
    string = function(key, value, def) return ffi.string(ffi.C.lj_cfg_track_string(tostring(key or ""), tostring(value or ""), tostring(def or ""))) end,
    rgb = function(key, value, def) return ffi.C.lj_cfg_track_rgb(tostring(key or ""), tostring(value or ""), def or rgb()) end,
    rgbm = function(key, value, def) return ffi.C.lj_cfg_track_rgbm(tostring(key or ""), tostring(value or ""), def or rgbm()) end,
    vec2 = function(key, value, def) return ffi.C.lj_cfg_track_vec2(tostring(key or ""), tostring(value or ""), def or vec2()) end,
    vec3 = function(key, value, def) return ffi.C.lj_cfg_track_vec3(tostring(key or ""), tostring(value or ""), def or vec3()) end,
    vec4 = function(key, value, def) return ffi.C.lj_cfg_track_vec4(tostring(key or ""), tostring(value or ""), def or vec4()) end,
  }
end
