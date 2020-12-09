ffi.cdef [[ 
typedef struct {
  float ambient, road;
} weather_conditions_temperatures;

typedef struct {
  float sessionStart, sessionTransfer, randomness, lapGain;
} weather_conditions_track;

typedef struct {
  float direction, speedFrom, speedTo;
} weather_conditions_wind;

typedef struct {
  char currentType;
  char upcomingType;
  weather_conditions_temperatures temperatures;
  weather_conditions_track trackState;
  weather_conditions_wind wind;
  float transition;
  float humidity, pressure;
  float variableA, variableB, variableC;
  float rainIntensity, rainWetness, rainWater;
} weather_conditions;
]]

ac.TrackConditions = ffi.metatype('weather_conditions_track', { __index = {} })
ac.TemperatureParams = ffi.metatype('weather_conditions_temperatures', { __index = {} })
ac.WindParams = ffi.metatype('weather_conditions_wind', { __index = {} })
ac.ConditionsSet = ffi.metatype('weather_conditions', { __index = {} })
