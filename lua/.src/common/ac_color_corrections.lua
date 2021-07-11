__source 'lua/api_color_corrections.cpp'

-- grayscale
ffi.cdef [[ typedef struct { void* __vfptr; } cc_grayscale; ]]
ffi.metatype('cc_grayscale', { __index = {} })
ac.ColorCorrectionGrayscale = function () return ffi.gc(ffi.C.lj_cc_grayscale_new(), ffi.C.lj_cc_grayscale_gc) end

-- negative
ffi.cdef [[ typedef struct { void* __vfptr; } cc_negative; ]]
ffi.metatype('cc_negative', { __index = {} })
ac.ColorCorrectionNegative = function () return ffi.gc(ffi.C.lj_cc_negative_new(), ffi.C.lj_cc_negative_gc) end

-- sepiatone
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_sepiatone; ]]
ffi.metatype('cc_sepiatone', { __index = {} })
ac.ColorCorrectionSepiaTone = function (t) 
  local r = ffi.C.lj_cc_sepiatone_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_sepiatone_gc) 
end

-- brightness
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_brightness; ]]
ffi.metatype('cc_brightness', { __index = {} })
ac.ColorCorrectionBrightness = function (t) 
  local r = ffi.C.lj_cc_brightness_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_brightness_gc) 
end

-- saturation
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_saturation; ]]
ffi.metatype('cc_saturation', { __index = {} })
ac.ColorCorrectionSaturation = function (t) 
  local r = ffi.C.lj_cc_saturation_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_saturation_gc) 
end

-- contrast
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_contrast; ]]
ffi.metatype('cc_contrast', { __index = {} })
ac.ColorCorrectionContrast = function (t) 
  local r = ffi.C.lj_cc_contrast_new() 
  r.value = type(t) == 'table' and t['value'] or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_contrast_gc) 
end

-- bias
ffi.cdef [[ typedef struct { void* __vfptr; float value; } cc_bias; ]]
ffi.metatype('cc_bias', { __index = {} })
ac.ColorCorrectionBias = function (t) 
  local r = ffi.C.lj_cc_bias_new() 
  r.value = type(t) == 'table' and t['value'] or t or 0.0
  return ffi.gc(r, ffi.C.lj_cc_bias_gc) 
end

-- modulation (color)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_modulation_rgb; ]]
ffi.metatype('cc_modulation_rgb', { __index = {} })
ac.ColorCorrectionModulationRgb = function (t) 
  local r = ffi.C.lj_cc_modulation_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  return ffi.gc(r, ffi.C.lj_cc_modulation_rgb_gc) 
end

-- saturation (color)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_saturation_rgb; ]]
ffi.metatype('cc_saturation_rgb', { __index = {} })
ac.ColorCorrectionSaturationRgb = function (t) 
  local r = ffi.C.lj_cc_saturation_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  return ffi.gc(r, ffi.C.lj_cc_saturation_rgb_gc) 
end

-- contrast (color)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_contrast_rgb; ]]
ffi.metatype('cc_contrast_rgb', { __index = {} })
ac.ColorCorrectionContrastRgb = function (t) 
  local r = ffi.C.lj_cc_contrast_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  return ffi.gc(r, ffi.C.lj_cc_contrast_rgb_gc) 
end

-- bias (color)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; } cc_bias_rgb; ]]
ffi.metatype('cc_bias_rgb', { __index = {} })
ac.ColorCorrectionBiasRgb = function (t) 
  local r = ffi.C.lj_cc_bias_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb()
  return ffi.gc(r, ffi.C.lj_cc_bias_rgb_gc) 
end

-- monotone (color, effectRatio)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float effectRatio; } cc_monotone_rgb; ]]
ffi.metatype('cc_monotone_rgb', { __index = {} })
ac.ColorCorrectionMonotoneRgb = function (t) 
  local r = ffi.C.lj_cc_monotone_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  r.effectRatio = type(t) == 'table' and t['effectRatio'] or 1
  return ffi.gc(r, ffi.C.lj_cc_monotone_rgb_gc) 
end

-- monotone (color, saturation, modulation)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float saturation; float modulation; } cc_monotone_rgbsatmod; ]]
ffi.metatype('cc_monotone_rgbsatmod', { __index = {} })
ac.ColorCorrectionMonotoneRgbSatMod = function (t) 
  local r = ffi.C.lj_cc_monotone_rgbsatmod_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  r.saturation = type(t) == 'table' and t['saturation'] or 1
  r.modulation = type(t) == 'table' and t['modulation'] or 1
  return ffi.gc(r, ffi.C.lj_cc_monotone_rgbsatmod_gc) 
end

-- fade (color, effectRatio)
ffi.cdef [[ typedef struct { void* __vfptr; rgb color; float effectRatio; } cc_fade_rgb; ]]
ffi.metatype('cc_fade_rgb', { __index = {} })
ac.ColorCorrectionFadeRgb = function (t) 
  local r = ffi.C.lj_cc_fade_rgb_new() 
  r.color = type(t) == 'table' and t['color'] or rgb.new(1)
  r.effectRatio = type(t) == 'table' and t['effectRatio'] or 1
  return ffi.gc(r, ffi.C.lj_cc_fade_rgb_gc) 
end

-- hue (hue, keepLuminance)
ffi.cdef [[ typedef struct { void* __vfptr; float hue; bool keepLuminance; } cc_hue; ]]
ffi.metatype('cc_hue', { __index = {} })
ac.ColorCorrectionHue = function (t) 
  local r = ffi.C.lj_cc_hue_new() 
  r.hue = type(t) == 'table' and t['hue'] or t or 0
  r.keepLuminance = type(t) == 'table' and t['keepLuminance'] or 1
  return ffi.gc(r, ffi.C.lj_cc_hue_gc) 
end

-- hue (hue, keepLuminance)
ffi.cdef [[ typedef struct { void* __vfptr; float hue; float saturation; float brightness; } cc_hsb; ]]
ffi.metatype('cc_hsb', { __index = {} })
ac.ColorCorrectionHsb = function (t) 
  local r = ffi.C.lj_cc_hsb_new() 
  r.hue = type(t) == 'table' and t['hue'] or t or 0
  r.saturation = type(t) == 'table' and t['saturation'] or t or __util.num_or(t, 1)
  r.brightness = type(t) == 'table' and t['brightness'] or t or __util.num_or(t, 1)
  return ffi.gc(r, ffi.C.lj_cc_hsb_gc) 
end

-- temperature
ffi.cdef [[ typedef struct { void* __vfptr; float temperature; float luminance; } cc_temperature; ]]
ffi.metatype('cc_temperature', { __index = {} })
ac.ColorCorrectionTemperature = function (t) 
  local r = ffi.C.lj_cc_temperature_new() 
  r.temperature = type(t) == 'table' and t['temperature'] or __util.num_or(t, 6500.0)
  r.luminance = type(t) == 'table' and t['luminance'] or 0.0
  return ffi.gc(r, ffi.C.lj_cc_temperature_gc) 
end

-- whitebalance
ffi.cdef [[ typedef struct { void* __vfptr; float whitebalance; float luminance; } cc_whitebalance; ]]
ffi.metatype('cc_whitebalance', { __index = {} })
ac.ColorCorrectionWhiteBalance = function (t) 
  local r = ffi.C.lj_cc_whitebalance_new() 
  r.temperature = type(t) == 'table' and t['temperature'] or __util.num_or(t, 6500.0)
  r.luminance = type(t) == 'table' and t['luminance'] or 0.0
  return ffi.gc(r, ffi.C.lj_cc_whitebalance_gc) 
end
