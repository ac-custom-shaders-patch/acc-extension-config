__source 'lua/api_render.cpp'
__namespace 'render'

render = {}

render.BlendMode = __enum({ cpp = 'AC::BlendMode', max = 25 }, {
  Opaque = 0,
  AlphaBlend = 1,
  AlphaTest = 2,
  BlendAdd = 4,
  BlendMultiply = 5,
})

render.CullMode = __enum({ cpp = 'AC::CullMode', max = 11 }, {
  Front = 0,
  Back = 1,
  None = 2,
  Wireframe = 4,
  WireframeAntialised = 7,
  ShadowsDouble = 9,
  ShadowsSingle = 10,
})

render.DepthMode = __enum({ cpp = 'AC::DepthMode', max = 5 }, {
  Normal = 0,
  ReadOnly = 1,
  Off = 2,
  LessEqual = 3,
  ReadOnlyLessEqual = 4
})

render.GLPrimitiveType = __enum({ cpp = 'AC::GLPrimitiveType', max = 5 }, {
  Lines = 0,
  LinesStrip = 1,
  Triangles = 2,
  Quads = 3
})
