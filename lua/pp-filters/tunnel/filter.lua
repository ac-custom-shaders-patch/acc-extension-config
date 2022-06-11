ac.setMIPs(8)

local shader = [[        
  float4 main(PS_IN pin) {
    float2 uv = pin.Tex + 0.1 * gShake;

    float4 noise = txNoise.SampleLevel(samPoint, pin.PosH.xy / 32, 0);
    float blurIntensity = max(gBlur, gHit) * saturate(pow(length(uv * 2 - 1), 2));
    float mipLevel = 3 * blurIntensity;
    float2 blurDir = normalize(uv * 2 - 1) * 0.002 * blurIntensity;

    float4 ret = 0;
    for (int i = 0; i < 20; ++i){
      float4 col = txInput.SampleLevel(samLinearBorder0, uv - blurDir * ((float)i + noise.x * 0.5), mipLevel);
      float w = dot(col.rgb, 1) + 1;
      ret += float4(col.xyz, 1) * w;
    }

    ret /= ret.w;
    ret.rgb = lerp(ret.rgb, dot(ret.rgb, 0.33), gHit);
    ret.rgb = lerp(ret.rgb, 0.5 + 1.5 * (ret.rgb - 0.5), gHit);
    return ret;
  }
]]

local hit = 0
local speedLast = 0
local shake = vec2()

function script.update(dt)
  local gameDt = ac.getGameDeltaT()
  local sim = ac.getSim()

  if sim.cameraMode ~= ac.CameraMode.Cockpit then
    -- If not in cockpit mode, simply copy input to output and quit
    ui.setShadingOffset(1, 0, 0, 1)
    ui.drawImage('dynamic::screen', vec2(), ui.windowSize())
    return
  end

  local car = ac.getCar(sim.focusedCar)
  shake = math.applyLag(shake, vec2(), 0.8, gameDt)
  if hit > 0 then
    hit = hit - gameDt * 0.25
  end
  if car.collisionDepth > 0 and gameDt > 0 then
    local nHit = math.saturateN((speedLast - car.speedKmh) / 60)
    if nHit > hit then
      hit = nHit
      if nHit > 0.2 then
        shake = vec2(math.random() - 0.5, math.random() - 0.5):normalize():scale(hit)
      end
    end
  end
  speedLast = math.applyLag(speedLast, car.speedKmh, 0.8, gameDt)

  ui.renderShader({
    p1 = vec2(),
    p2 = ui.windowSize(),
    blendMode = render.BlendMode.Opaque,
    textures = {
      txInput = 'dynamic::screen',
      txNoise = 'dynamic::noise', -- only available for PP-filters, for other scripts please include your own noise texture
    },
    values = {
      gHit = math.min(hit * 1.4, 1) ^ 2,
      gBlur = math.saturateN(car.speedKmh / 120 - 1),
      gShake = shake
    },
    shader = shader
  })
end
