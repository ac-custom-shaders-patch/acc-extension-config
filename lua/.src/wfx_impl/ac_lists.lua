ac.weatherClouds = __bound_array(ffi.typeof('cloud*'), 'lj_set_clouds__impl')
ac.weatherCloudsCovers = __bound_array(ffi.typeof('cloudscover*'), 'lj_set_cloudscovers__impl')
ac.skyExtraGradients = __bound_array(ffi.typeof('extragradient*'), 'lj_set_gradients__impl')
ac.weatherColorCorrections = __bound_array(ffi.typeof('void*'), 'lj_set_corrections__impl')

ac.addWeatherCloud = function(cloud) return ac.weatherClouds:pushWhereFits(cloud) end
ac.addWeatherCloudCover = function(cloud) return ac.weatherCloudsCovers:pushWhereFits(cloud) end
ac.addSkyExtraGradient = function(gradient) return ac.skyExtraGradients:pushWhereFits(gradient) end
ac.addWeatherColorCorrection = function(cc) return ac.weatherColorCorrections:pushWhereFits(cc) end
ac.removeWeatherCloud = function(cloud) return ac.weatherClouds:erase(cloud) end
ac.removeWeatherCloudCover = function(cloud) return ac.weatherCloudsCovers:erase(cloud) end
ac.removeSkyExtraGradient = function(gradient) return ac.skyExtraGradients:erase(gradient) end
ac.removeWeatherColorCorrection = function(cc) return ac.weatherColorCorrections:erase(cc) end
