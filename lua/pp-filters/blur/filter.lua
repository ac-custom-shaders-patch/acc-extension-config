ac.setMIPs(8)

-- Direct pass allows to apply post-processing directly to output image without IMGUI framework. Faster and
-- with the access to `ac.setFrameData()`.
ac.setDirectPass(true)

function script.update(dt)
  local sim = ac.getSim()
  if sim.cameraMode ~= ac.CameraMode.Cockpit then
    -- If not in cockpit mode, simply copy input to output and quit
    render.fullscreenPass({
      textures = { txInput = 'dynamic::screen' },
      shader = 'float4 main(PS_IN pin) { return txInput.SampleLevel(samLinear, pin.Tex, 0); }'
    })
    return
  end

  if ac.isTripleModeActive() then
    for i = 0, 2 do
      ac.setFrameData(i)
      render.fullscreenPass({
        region = ac.getTripleScreenViewport(i),
        blendMode = render.BlendMode.Opaque,
        depthMode = render.DepthMode.Off,
        textures = {
          txInput = 'dynamic::screen'
        },
        values = {
          gRegion = ac.getTripleScreenViewport(i)
        },
        shader = 'shader.fx'
      })
    end
  else
    ac.setFrameData(0)
    render.fullscreenPass({
      blendMode = render.BlendMode.Opaque,
      depthMode = render.DepthMode.Off,
      textures = {
        txInput = 'dynamic::screen'
      },
      values = {
        gRegion = vec4(0, 0, 1, 1)
      },
      shader = 'shader.fx'
    })
  end
end
