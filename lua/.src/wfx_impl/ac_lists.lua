ac.weatherClouds = __bound_array(ffi.typeof('cloud*'), 'lj_set_clouds__impl')
ac.skyExtraGradients = __bound_array(ffi.typeof('extra_gradient*'), 'lj_set_gradients__impl')
ac.weatherColorCorrections = __bound_array(ffi.typeof('void*'), 'lj_set_corrections__impl')

ac.addWeatherCloud = function(cloud) return ac.weatherClouds:pushWhereFits(cloud) end
ac.addSkyExtraGradient = function(gradient) return ac.skyExtraGradients:pushWhereFits(gradient) end
ac.addWeatherColorCorrection = function(cc) return ac.weatherColorCorrections:pushWhereFits(cc) end
