function script.update()
  ui.renderShader({
    p1 = vec2(),
    p2 = ui.windowSize(),
    blendMode = render.BlendMode.Opaque,
    textures = {
      txInput = 'dynamic::screen',
      txDepth = 'dynamic::depth',
      txNoise = 'dynamic::noise', -- only available for PP-filters, for other scripts please include your own noise texture
      txHDR = 'dynamic::hdr'
    },
    values = {},
    shader = 'filter.fx'
  })
end
