ac.FogAlgorithm = { 
  Original = 0,
  New = 1
}

ac.ShadowsState = { 
  Off = 0,
  On = 1,
  EverythingShadowed = 2
}

ac.WeatherType = { 
  LightThunderstorm = 0,
  Thunderstorm = 1,
  HeavyThunderstorm = 2,
  LightDrizzle = 3,
  Drizzle = 4,
  HeavyDrizzle = 5,
  LightRain = 6,
  Rain = 7,
  HeavyRain = 8,
  LightSnow = 9,
  Snow = 10,
  HeavySnow = 11,
  LightSleet = 12,
  Sleet = 13,
  HeavySleet = 14,
  Clear = 15,
  FewClouds = 16,
  ScatteredClouds = 17,
  BrokenClouds = 18,
  OvercastClouds = 19,
  Fog = 20,
  Mist = 21,
  Smoke = 22,
  Haze = 23,
  Sand = 24,
  Dust = 25,
  Squalls = 26,
  Tornado = 27,
  Hurricane = 28,
  Cold = 29,
  Hot = 30,
  Windy = 31,
  Hail = 32 
}

ac.TonemapFunction = {
  Linear = 0,         -- simple linear mapping.
  LinearClamped = 1,  -- linear mapping (LDR clamp)
  Sensitometric = 2,  -- simple simulation of response of film, CCD, etc., recommended
  Reinhard = 3,       -- Reinhard
  ReinhardLum = 4,    -- saturation retention type Reinhard tone map function
  Log = 5,            -- tone map function for the logarithmic space
  LogLum = 6          -- saturation retention type logarithmic space tone map function
}

ac.FolderId = {   
  AppData = 0,
  Documents = 1,   
  Root = 4,
  Cfg = 5,
  Setups = 6,
  Logs = 7,
  Screenshots = 8,
  Replays = 9,
  ReplaysTemp = 10,
  UserSetups = 11,
  PPFilters = 12,
  ContentCars = 13,
  ContentDrivers = 14,
  ContentTracks = 15,
  ExtRoot = 16,
  ExtCfgSys = 17,
  ExtCfgUser = 18,
  ExtTextures = 21,
  ACApps = 23,
  ACAppsPython = 24,
  ExtCfgState = 25,
  ContentFonts = 26,
  RaceResults = 27
}

ac.HolidayType = {
  None = 0,
  NewYear = 1,
  Christmas = 2,
  VictoryDay = 3,
  IndependenceDay = 4,
  Halloween = 5,
  JapanFestival = 6,
  ChineseNewYear = 7,
  EidAlAdha = 8,
  GuyFawkesNight = 9
}

ac.SkyRegion = {
  None = 0,
  Sun = 1,
  Opposite = 2,
  All = 3
}