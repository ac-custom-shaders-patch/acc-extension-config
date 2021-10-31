__source 'lua/api_ui.cpp'
__namespace 'ui'

require './ac_matrices'

ui = {}

ui.Font = {
  Small = 1,
  Tiny = 2,
  Monospace = 3,
  Main = 4,
  Italic = 5,
  Title = 6,
  Huge = 7
}

ui.Key = { 
  Tab = 0,
  Left = 1,
  Right = 2,
  Up = 3,
  Down = 4,
  PageUp = 5,
  PageDown = 6,
  Home = 7,
  End = 8,
  Insert = 9,
  Delete = 10,
  Backspace = 11,
  Space = 12,
  Enter = 13,
  Escape = 14,
  KeyPadEnter = 15,
  A = 16,
  C = 17,
  D = 18,
  S = 19,
  V = 20,
  W = 21,
  X = 22,
  Y = 23,
  Z = 24,
}

ui.StyleVar = {
  Alpha = 0,
  WindowPadding = 1,
  WindowRounding = 2,
  WindowBorderSize = 3,
  WindowMinSize = 4,
  WindowTitleAlign = 5,
  ChildRounding = 6,
  ChildBorderSize = 7,
  PopupRounding = 8,
  PopupBorderSize = 9,
  FramePadding = 10,
  FrameRounding = 11,
  FrameBorderSize = 12,
  ItemSpacing = 13,
  ItemInnerSpacing = 14,
  IndentSpacing = 15,
  ScrollbarSize = 16,
  ScrollbarRounding = 17,
  GrabMinSize = 18,
  GrabRounding = 19,
  TabRounding = 20,
  ButtonTextAlign = 21,
  SelectableTextAlign = 22,
  SelectablePadding = 23,
}

ui.StyleColor = {
  Text = 0,
  TextDisabled = 1,
  WindowBg = 2,
  ChildBg = 3,
  PopupBg = 4,
  Border = 5,
  BorderShadow = 6,
  FrameBg = 7,
  FrameBgHovered = 8,
  FrameBgActive = 9,
  TitleBg = 10,
  TitleBgActive = 11,
  TitleBgCollapsed = 12,
  MenuBarBg = 13,
  ScrollbarBg = 14,
  ScrollbarGrab = 15,
  ScrollbarGrabHovered = 16,
  ScrollbarGrabActive = 17,
  CheckMark = 18,
  SliderGrab = 19,
  SliderGrabActive = 20,
  Button = 21,
  ButtonHovered = 22,
  ButtonActive = 23,
  Header = 24,
  HeaderHovered = 25,
  HeaderActive = 26,
  Separator = 27,
  SeparatorHovered = 28,
  SeparatorActive = 29,
  ResizeGrip = 30,
  ResizeGripHovered = 31,
  ResizeGripActive = 32,
  Tab = 33,
  TabHovered = 34,
  TabActive = 35,
  TabUnfocused = 36,
  TabUnfocusedActive = 37,
  PlotLines = 38,
  PlotLinesHovered = 39,
  PlotHistogram = 40,
  PlotHistogramHovered = 41,
  TextSelectedBg = 42,
  DragDropTarget = 43,
  NavHighlight = 44,
  NavWindowingHighlight = 45,
  NavWindowingDimBg = 46,
  ModalWindowDimBg = 47,
  TextHovered = 48,
  TextActive = 49
}

ui.Icons = { 
  Apps = 'APPS',
  ArrowDown = 'ARROW_DOWN',
  ArrowLeft = 'ARROW_LEFT',
  ArrowRight = 'ARROW_RIGHT',
  ArrowUp = 'ARROW_UP',
  Ballast = 'BALLAST',
  Ban = 'BAN',
  Befriend = 'BEFRIEND',
  Bell = 'BELL',
  Bluetooth = 'BLUETOOTH',
  Bug = 'BUG',
  Bulb = 'BULB',
  CallBluetooth = 'CALL_BLUETOOTH',
  Call = 'CALL',
  Camera = 'CAMERA',
  Cancel = 'CANCEL',
  CarFront = 'CAR_FRONT',
  Clip = 'CLIP',
  Clock = 'CLOCK',
  Compass = 'COMPASS',
  Confirm = 'CONFIRM',
  Copy = 'COPY',
  Crosshair = 'CROSSHAIR',
  Delete = 'DELETE',
  Down = 'DOWN',
  Download = 'DOWNLOAD',
  Earth = 'EARTH',
  Edit = 'EDIT',
  Eye = 'EYE',
  File = 'FILE',
  Finish = 'FINISH',
  Fm = 'FM',
  Folder = 'FOLDER',
  Fuel = 'FUEL',
  Global = 'GLOBAL',
  GlowThick = 'GLOW_THICK',
  Glow = 'GLOW',
  Gps = 'GPS',
  Group = 'GROUP',
  Hammer = 'HAMMER',
  Hide = 'HIDE',
  Horizontal = 'HORIZONTAL',
  Info = 'INFO',
  Key = 'KEY',
  Kick = 'KICK',
  Leave = 'LEAVE',
  Loading = 'LOADING',
  Location = 'LOCATION',
  Map = 'MAP',
  Menu = 'MENU',
  Minus = 'MINUS',
  Monitor = 'MONITOR',
  Music = 'MUSIC',
  Navigation = 'NAVIGATION',
  Palette = 'PALETTE',
  Pin = 'PIN',
  PitStop = 'PIT_STOP',
  Plus = 'PLUS',
  Preview = 'PREVIEW',
  Python = 'PYTHON',
  Referee = 'REFEREE',
  Repair = 'REPAIR',
  RestartWarning = 'RESTART_WARNING',
  Restart = 'RESTART',
  Restrictor = 'RESTRICTOR',
  Road = 'ROAD',
  Rubber = 'RUBBER',
  SatelliteDishLow = 'SATELLITE_DISH_LOW',
  SatelliteDishNone = 'SATELLITE_DISH_NONE',
  SatelliteDish = 'SATELLITE_DISH',
  Save = 'SAVE',
  Sea = 'SEA',
  Send = 'SEND',
  Settings = 'SETTINGS',
  Skip = 'SKIP',
  Sleep = 'SLEEP',
  SlowMotion = 'SLOW_MOTION',
  Smile = 'SMILE',
  Spotify = 'SPOTIFY',
  StarEmpty = 'STAR_EMPTY',
  StarFull = 'STAR_FULL',
  StarHalf = 'STAR_HALF',
  Start = 'START',
  Stay = 'STAY',
  Tag = 'TAG',
  Target = 'TARGET',
  Teleport = 'TELEPORT',
  Thermometer = 'THERMOMETER',
  Undo = 'UNDO',
  Up = 'UP',
  VideoCamera = 'VIDEO_CAMERA',
  Warning = 'WARNING',
  WeatherClear = 'WEATHER_CLEAR',
  WeatherCold = 'WEATHER_COLD',
  WeatherDrizzle = 'WEATHER_DRIZZLE',
  WeatherFewClouds = 'WEATHER_FEW_CLOUDS',
  WeatherFog = 'WEATHER_FOG',
  WeatherHail = 'WEATHER_HAIL',
  WeatherHot = 'WEATHER_HOT',
  WeatherHurricane = 'WEATHER_HURRICANE',
  WeatherOvercast = 'WEATHER_OVERCAST',
  WeatherRainLight = 'WEATHER_RAIN_LIGHT',
  WeatherRain = 'WEATHER_RAIN',
  WeatherSleet = 'WEATHER_SLEET',
  WeatherSnowLight = 'WEATHER_SNOW_LIGHT',
  WeatherSnow = 'WEATHER_SNOW',
  WeatherStormLight = 'WEATHER_STORM_LIGHT',
  WeatherStorm = 'WEATHER_STORM',
  WeatherTornado = 'WEATHER_TORNADO',
  WeatherWarm = 'WEATHER_WARM',
  WeatherWindySun = 'WEATHER_WINDY_SUN',
  WeatherWindy = 'WEATHER_WINDY',
  YoutubeSolid = 'YOUTUBE_SOLID',
  Youtube = 'YOUTUBE',
}

ui.ColorPickerFlags = {
  None             = 0,
  NoAlpha          = 0x2,   -- ignore Alpha component (will only read 3 components from the input pointer).
  NoPicker         = 0x4,   -- disable picker when clicking on colored square.
  NoOptions        = 0x8,   -- disable toggling options menu when right-clicking on inputs/small preview.
  NoSmallPreview   = 0x10,   -- disable colored square preview next to the inputs. (e.g. to show only the inputs)
  NoInputs         = 0x20,   -- disable inputs sliders/text widgets (e.g. to show only the small preview colored square).
  NoTooltip        = 0x40,   -- disable tooltip when hovering the preview.
  NoLabel          = 0x80,   -- disable display of inline text label (the label is still forwarded to the tooltip and picker).
  NoSidePreview    = 0x100,   -- disable bigger color preview on right side of the picker, use small colored square preview instead.
  NoDragDrop       = 0x200,   -- disable drag and drop target. ColorButton: disable drag and drop source.
  AlphaBar         = 0x10000,  -- show vertical alpha bar/gradient in picker.
  AlphaPreview     = 0x20000,  -- display preview as a transparent color over a checkerboard, instead of opaque.
  AlphaPreviewHalf = 0x40000,  -- display half opaque / half checkerboard, instead of opaque.
  DisplayRGB       = 0x100000,  -- override _display_ type among RGB/HSV/Hex. select any combination using one or more of RGB/HSV/Hex.
  DisplayHSV       = 0x200000,
  DisplayHex       = 0x400000,
  Uint8            = 0x800000,  -- display values formatted as 0..255.
  Float            = 0x1000000,  -- display values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
  PickerHueBar     = 0x2000000,  -- bar for Hue, rectangle for Sat/Value.
  PickerHueWheel   = 0x4000000,  -- wheel for Hue, triangle for Sat/Value
}

ui.pushStyleVar = function(var_id, value)
  if type(value) == 'number' then
    ffi.C.lj_pushStyleVar_v1__ui(var_id, value)
  else
    ffi.C.lj_pushStyleVar_v2__ui(var_id, __util.ensure_vec2(value))
  end
end

ui.pushID = function(value)
  if type(value) == 'number' then
    ffi.C.lj_pushID_num__ui(value)
  else
    ffi.C.lj_pushID_string__ui(__util.str(value))
  end
end

ui.inputText = function(label, str, flags)
  local changed = ffi.C.lj_inputText_inner__ui(__util.str(label), __util.str(str), tonumber(flags) or 0)
  if changed == nil then return str, false end
  return ffi.string(changed), true
end

ui.colorPicker = function(label, color, flags)
  if rgb.isrgb(color) then
    return ffi.C.lj_colorPicker_rgb__ui(__util.str(label), color, tonumber(flags) or 0)
  elseif rgbm.isrgbm(color) then
    return ffi.C.lj_colorPicker_rgbm__ui(__util.str(label), color, tonumber(flags) or 0)
  else
    error('Unsupported type for color picker: '..color)
  end
end

local function smoothInterpolation(value, speed, target, dt)
  if dt >= 0.1 or math.abs(value - target) < 0.0001 then
    return target, 0
  end
  for i = 1, 10 do
		local lag1 = 0.98
		local lag2 = 0.6
		local dir = target - value
		local lag = lag1 + (lag2 - lag1) * speed * speed
		local delta = dir * math.lagMult(lag, dt / 10)
		local localSpeed = math.saturate(10 * (delta / dt) / dir)
    speed = math.lerp(localSpeed, speed, 1 / (1 + dt * 4))
			value = value + delta
  end
  return value, speed
end

ui.SmoothInterpolation = function(initialValue)
  local value = initialValue
  local speed = 0
  return function(target)
    value, speed = smoothInterpolation(value, speed, target, ac.getUiState().dt)
    return value
  end
end

ui.FadingElement = function(drawCallback, initialState)
  local value = ui.SmoothInterpolation(initialState and 1 or 0)
  return function(state)
    local alpha = value(state and 1 or 0)
    if alpha > 0.002 then
      ffi.C.lj_pushStyleVar_v1__ui(ui.StyleVar.Alpha, alpha)
      drawCallback()
      ffi.C.lj_popStyleVar__ui(1)
    end
  end
end

ui.toast = function(icon, message, undoCallback)
  if undoCallback == nil then
    ffi.C.lj_toast_inner__ui(__util.str(icon), __util.str(message), 0)
  else
    ffi.C.lj_toast_inner__ui(__util.str(icon), __util.str(message), __util.expectReply(function (arg)
      if arg then
        undoCallback()
      end
    end))
  end
end

ui.transparentWindow = function(id, pos, size, content)
  ui.beginTransparentWindow(id, pos, size, true)
  return using(content, ui.endTransparentWindow)
end

ui.toolWindow = function(id, pos, size, content)
  ui.beginToolWindow(id, pos, size, true)
  return using(content, ui.endToolWindow)
end

ui.childWindow = function(id, size, border, flags, content)
  if content == nil then flags, content = content, flags end
  if content == nil then border, content = content, border end
  if content == nil then size, content = content, size end
  if ui.beginChild(id, size, border, flags) then
    return using(content, ui.endChild)
  end
end

ui.treeNode = function(label, flags, content)
  if content == nil then flags, content = content, flags end
  if ui.beginTreeNode(label, flags) then
    return using(content, ui.endTreeNode)
  end
end

ui.tabBar = function(id, flags, content)
  if content == nil then flags, content = content, flags end
  if ui.beginTabBar(id, flags) then
    return using(content, ui.endTabBar)
  end
end

ui.tabItem = function(label, flags, content)
  if content == nil then flags, content = content, flags end
  if ui.beginTabItem(label, flags) then
    return using(content, ui.endTabItem)
  end
end

ui.itemPopup = function(id, mouseButton, content)
  if content == nil then mouseButton, content = content, mouseButton end
  if ui.beginPopupContextItem(id, mouseButton) then
    return using(content, ui.endPopup)
  end
end

ui.combo = function(label, previewValue, flags, content)
  if content == nil then flags, content = content, flags end
  if content == nil then previewValue, content = content, previewValue end
  if ui.beginCombo(label, previewValue, flags) then
    return using(content, ui.endCombo)
  end
end
