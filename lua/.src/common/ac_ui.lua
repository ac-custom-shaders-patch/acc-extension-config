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

ui.pushStyleVar = function(var_id, value)
  if type(value) == 'number' then
    ffi.C.lj_pushStyleVar_v1__ui(var_id, value)
  else
    ffi.C.lj_pushStyleVar_v2__ui(var_id, value)
  end
end