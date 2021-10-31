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

ui.ButtonFlags = {
  ImGuiButtonFlags_None                      = 0,
  ImGuiButtonFlags_Repeat                    = 0x1,       -- Hold to repeat
  ImGuiButtonFlags_PressedOnClickRelease     = 0x2,       -- Return true on click + release on same item
  ImGuiButtonFlags_PressedOnClick            = 0x4,       -- Return true on click (default requires click+release)
  ImGuiButtonFlags_PressedOnRelease          = 0x8,       -- Return true on release (default requires click+release)
  ImGuiButtonFlags_PressedOnDoubleClick      = 0x10,      -- Return true on double-click (default requires click+release)
  ImGuiButtonFlags_FlattenChildren           = 0x20,      -- Allow interactions even if a child window is overlapping
  ImGuiButtonFlags_AllowItemOverlap          = 0x40,      -- Require previous frame HoveredId to either match id or be null before being usable, use along with SetItemAllowOverlap()
  ImGuiButtonFlags_DontClosePopups           = 0x80,      -- Disable automatically closing parent popup on press
  ImGuiButtonFlags_Disabled                  = 0x100,     -- Disable interactions
  ImGuiButtonFlags_NoKeyModifiers            = 0x400,     -- Disable interaction if a key modifier is held
  ImGuiButtonFlags_PressedOnDragDropHold     = 0x1000,    -- Press when held into while we are drag and dropping another item (used by e.g. tree nodes, collapsing headers)
  ImGuiButtonFlags_NoNavFocus                = 0x2000,    -- Don't override navigation focus when activated
  ImGuiButtonFlags_NoHoveredOnNav            = 0x4000,    -- Don't report as hovered when navigated on
  ImGuiButtonFlags_Active                    = 0x100000,  -- Button is correctly active (checked)
  ImGuiButtonFlags_Activable                 = 0x200000,  -- If not set, _Active would make background brighter
}

ui.WindowFlags = {
  ImGuiWindowFlags_None                      = 0,
  ImGuiWindowFlags_NoTitleBar                = 0x1,       -- Disable title-bar
  ImGuiWindowFlags_NoResize                  = 0x2,       -- Disable user resizing with the lower-right grip
  ImGuiWindowFlags_NoMove                    = 0x4,       -- Disable user moving the window
  ImGuiWindowFlags_NoScrollbar               = 0x8,       -- Disable scrollbars (window can still scroll with mouse or programmatically)
  ImGuiWindowFlags_NoScrollWithMouse         = 0x10,      -- Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
  ImGuiWindowFlags_NoCollapse                = 0x20,      -- Disable user collapsing window by double-clicking on it
  ImGuiWindowFlags_AlwaysAutoResize          = 0x40,      -- Resize every window to its content every frame
  ImGuiWindowFlags_NoBackground              = 0x80,      -- Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).
  ImGuiWindowFlags_NoSavedSettings           = 0x100,     -- Never load/save settings in .ini file
  ImGuiWindowFlags_NoMouseInputs             = 0x200,     -- Disable catching mouse, hovering test with pass through.
  ImGuiWindowFlags_MenuBar                   = 0x400,     -- Has a menu-bar
  ImGuiWindowFlags_HorizontalScrollbar       = 0x800,     -- Allow horizontal scrollbar to appear (off by default)
  ImGuiWindowFlags_NoFocusOnAppearing        = 0x1000,    -- Disable taking focus when transitioning from hidden to visible state
  ImGuiWindowFlags_NoBringToFrontOnFocus     = 0x2000,    -- Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
  ImGuiWindowFlags_AlwaysVerticalScrollbar   = 0x4000,    -- Always show vertical scrollbar (even if ContentSize.y < Size.y)
  ImGuiWindowFlags_AlwaysHorizontalScrollbar = 0x8000,    -- Always show horizontal scrollbar (even if ContentSize.x < Size.x)
  ImGuiWindowFlags_AlwaysUseWindowPadding    = 0x10000,   -- Ensure child windows without border uses style.WindowPadding (ignored by default for non-bordered child windows, because more convenient)
  ImGuiWindowFlags_NoNavInputs               = 0x40000,   -- No gamepad/keyboard navigation within the window
  ImGuiWindowFlags_NoNavFocus                = 0x80000,   -- No focusing toward this window with gamepad/keyboard navigation (e.g. skipped by CTRL+TAB)
  ImGuiWindowFlags_UnsavedDocument           = 0x100000,  -- Append '*' to title without affecting the ID, as a convenience to avoid using the ### operator
  ImGuiWindowFlags_NoNav                     = 0xc0000,   -- ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
  ImGuiWindowFlags_NoDecoration              = 0x2b,      -- ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse,
  ImGuiWindowFlags_NoInputs                  = 0xc0200,   -- ImGuiWindowFlags_NoMouseInputs | ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
}

ui.ComboFlags = {
  ImGuiComboFlags_None                       = 0,
  ImGuiComboFlags_PopupAlignLeft             = 0x1,    -- Align the popup toward the left by default
  ImGuiComboFlags_HeightSmall                = 0x2,    -- Max ~4 items visible. Tip: If you want your combo popup to be a specific size you can use SetNextWindowSizeConstraints() prior to calling BeginCombo()
  ImGuiComboFlags_HeightRegular              = 0x4,    -- Max ~8 items visible (default)
  ImGuiComboFlags_HeightLarge                = 0x8,    -- Max ~20 items visible
  ImGuiComboFlags_HeightLargest              = 0x10,   -- As many fitting items as possible
  ImGuiComboFlags_NoArrowButton              = 0x20,   -- Display on the preview box without the square arrow button
  ImGuiComboFlags_NoPreview                  = 0x40,   -- Display only a square arrow button
  ImGuiComboFlags_GoUp                       = 0x80,   -- IMGUI_CSP
  ImGuiComboFlags_HeightChubby               = 0x100,  -- IMGUI_CSP
}

ui.InputTextFlags = {
  ImGuiInputTextFlags_None                   = 0,
  ImGuiInputTextFlags_CharsDecimal           = 0x1,       -- Allow 0123456789.+-*/
  ImGuiInputTextFlags_CharsHexadecimal       = 0x2,       -- Allow 0123456789ABCDEFabcdef
  ImGuiInputTextFlags_CharsUppercase         = 0x4,       -- Turn a..z into A..Z
  ImGuiInputTextFlags_CharsNoBlank           = 0x8,       -- Filter out spaces, tabs
  ImGuiInputTextFlags_AutoSelectAll          = 0x10,      -- Select entire text when first taking mouse focus
  ImGuiInputTextFlags_EnterReturnsTrue       = 0x20,      -- Return 'true' when Enter is pressed (as opposed to every time the value was modified)
  ImGuiInputTextFlags_AllowTabInput          = 0x400,     -- Pressing TAB input a '\t' character into the text field
  ImGuiInputTextFlags_CtrlEnterForNewLine    = 0x800,     -- In multi-line mode, unfocus with Enter, add new line with Ctrl+Enter (default is opposite: unfocus with Ctrl+Enter, add line with Enter)
  ImGuiInputTextFlags_NoHorizontalScroll     = 0x1000,    -- Disable following the cursor horizontally
  ImGuiInputTextFlags_AlwaysInsertMode       = 0x2000,    -- Insert mode
  ImGuiInputTextFlags_ReadOnly               = 0x4000,    -- Read-only mode
  ImGuiInputTextFlags_Password               = 0x8000,    -- Password mode, display all characters as '*'
  ImGuiInputTextFlags_NoUndoRedo             = 0x10000,   -- Disable undo/redo. Note that input text owns the text data while active, if you want to provide your own undo/redo stack you need e.g. to call ClearActiveID().
  ImGuiInputTextFlags_CharsScientific        = 0x20000,   -- Allow 0123456789.+-*/eE (Scientific notation input)
  ImGuiInputTextFlags_Placeholder            = 0x400000,  -- Show label as a placeholder
  ImGuiInputTextFlags_ClearButton            = 0x800000   -- Add button erasing text
}

ui.SelectableFlags = {
  ImGuiSelectableFlags_None                  = 0,
  ImGuiSelectableFlags_DontClosePopups       = 0x1,  -- Clicking this don't close parent popup window
  ImGuiSelectableFlags_SpanAllColumns        = 0x2,  -- Selectable frame can span all columns (text will still fit in current column)
  ImGuiSelectableFlags_AllowDoubleClick      = 0x4,  -- Generate press events on double clicks too
  ImGuiSelectableFlags_Disabled              = 0x8,  -- Cannot be selected, display grayed out text
}

ui.TabBarFlags = {
  ImGuiTabBarFlags_None                              = 0,
  ImGuiTabBarFlags_Reorderable                       = 0x1,   -- Allow manually dragging tabs to re-order them + New tabs are appended at the end of list
  ImGuiTabBarFlags_AutoSelectNewTabs                 = 0x2,   -- Automatically select new tabs when they appear
  ImGuiTabBarFlags_TabListPopupButton                = 0x4,   -- Disable buttons to open the tab list popup
  ImGuiTabBarFlags_NoCloseWithMiddleMouseButton      = 0x8,   -- Disable behavior of closing tabs (that are submitted with p_open !   = NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open    = false.
  ImGuiTabBarFlags_NoTabListScrollingButtons         = 0x10,  -- Disable scrolling buttons (apply when fitting policy is ImGuiTabBarFlags_FittingPolicyScroll)
  ImGuiTabBarFlags_NoTooltip                         = 0x20,  -- Disable tooltips when hovering a tab
  ImGuiTabBarFlags_FittingPolicyResizeDown           = 0x40,  -- Resize tabs when they don't fit
  ImGuiTabBarFlags_FittingPolicyScroll               = 0x80,  -- Add scroll buttons when tabs don't fit
}

ui.TabItemFlags = {
  ImGuiTabItemFlags_None                             = 0,
  ImGuiTabItemFlags_UnsavedDocument                  = 0x1,   -- Append '*' to title without affecting the ID, as a convenience to avoid using the ### operator. Also: tab is selected on closure and closure is deferred by one frame to allow code to undo it without flicker.
  ImGuiTabItemFlags_SetSelected                      = 0x2,   -- Trigger flag to programmatically make the tab selected when calling BeginTabItem()
  ImGuiTabItemFlags_NoCloseWithMiddleMouseButton     = 0x4,   -- Disable behavior of closing tabs (that are submitted with p_open !   = NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open    = false.
}

ui.TreeNodeFlags = {
  ImGuiTreeNodeFlags_None                    = 0,
  ImGuiTreeNodeFlags_Selected                = 0x1,    -- Draw as selected
  ImGuiTreeNodeFlags_Framed                  = 0x2,    -- Full colored frame (e.g. for CollapsingHeader)
  ImGuiTreeNodeFlags_AllowItemOverlap        = 0x4,    -- Hit testing to allow subsequent widgets to overlap this one
  ImGuiTreeNodeFlags_NoTreePushOnOpen        = 0x8,    -- Don't do a TreePush() when open (e.g. for CollapsingHeader)    = no extra indent nor pushing on ID stack
  ImGuiTreeNodeFlags_NoAutoOpenOnLog         = 0x10,   -- Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
  ImGuiTreeNodeFlags_DefaultOpen             = 0x20,   -- Default node to be open
  ImGuiTreeNodeFlags_OpenOnDoubleClick       = 0x40,   -- Need double-click to open node
  ImGuiTreeNodeFlags_OpenOnArrow             = 0x80,   -- Only open when clicking on the arrow part. If ImGuiTreeNodeFlags_OpenOnDoubleClick is also set, single-click arrow or double-click all box to open.
  ImGuiTreeNodeFlags_Leaf                    = 0x100,  -- No collapsing, no arrow (use as a convenience for leaf nodes).
  ImGuiTreeNodeFlags_Bullet                  = 0x200,  -- Display a bullet instead of arrow
  ImGuiTreeNodeFlags_FramePadding            = 0x400,  -- Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding().
  ImGuiTreeNodeFlags_CollapsingHeader        = 0x1a,   -- ImGuiTreeNodeFlags_Framed | ImGuiTreeNodeFlags_NoTreePushOnOpen | ImGuiTreeNodeFlags_NoAutoOpenOnLog,
  ImGuiTreeNodeFlags_NoArrow                 = 0x4000,
  ImGuiTreeNodeFlags_Animated                = 0xf0000000,
}

ui.ColorPickerFlags = {
  None             = 0,
  NoAlpha          = 0x2,        -- Ignore Alpha component (will only read 3 components from the input pointer).
  NoPicker         = 0x4,        -- Disable picker when clicking on colored square.
  NoOptions        = 0x8,        -- Disable toggling options menu when right-clicking on inputs/small preview.
  NoSmallPreview   = 0x10,       -- Disable colored square preview next to the inputs. (e.g. to show only the inputs)
  NoInputs         = 0x20,       -- Disable inputs sliders/text widgets (e.g. to show only the small preview colored square).
  NoTooltip        = 0x40,       -- Disable tooltip when hovering the preview.
  NoLabel          = 0x80,       -- Disable display of inline text label (the label is still forwarded to the tooltip and picker).
  NoSidePreview    = 0x100,      -- Disable bigger color preview on right side of the picker, use small colored square preview instead.
  NoDragDrop       = 0x200,      -- Disable drag and drop target. ColorButton: disable drag and drop source.
  AlphaBar         = 0x10000,    -- Show vertical alpha bar/gradient in picker.
  AlphaPreview     = 0x20000,    -- Display preview as a transparent color over a checkerboard, instead of opaque.
  AlphaPreviewHalf = 0x40000,    -- Display half opaque / half checkerboard, instead of opaque.
  DisplayRGB       = 0x100000,   -- Override _display_ type among RGB/HSV/Hex. select any combination using one or more of RGB/HSV/Hex.
  DisplayHSV       = 0x200000,
  DisplayHex       = 0x400000,
  Uint8            = 0x800000,   -- Display values formatted as 0..255.
  Float            = 0x1000000,  -- Display values formatted as 0.0f..1.0f floats instead of 0..255 integers. No round-trip of value via integers.
  PickerHueBar     = 0x2000000,  -- Bar for Hue, rectangle for Sat/Value.
  PickerHueWheel   = 0x4000000,  -- Wheel for Hue, triangle for Sat/Value
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
