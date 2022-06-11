local shader = [[
  float3 rgbToYiq(float3 c){   
    return mul(float3x3(
      0.299, 0.596, 0.211,
      0.587, -0.274, -0.523,
      0.114, -0.322, 0.312), c);
  }
  
  float3 yiqToRgb(float3 c){
    return mul(float3x3(
      1, 1, 1,
      0.956, -0.272, -1.106,
      0.621, -0.647, 1.703), c);
  }
  
  float rand(float2 co){
    return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
  }
  
  float3 blur(float2 uv, float d, float o){
    float3 blurred = 0;
    for (int i = -7; i <= 7; i++){
      float2 newUv = uv + float2((1.0 - 1.5 * (o + i)) * d, 0);
      blurred += clamp(txInput.SampleLevel(samLinearSimple, newUv, 0).rgb, 0, 2);
    }  
    return blurred / 15;
  }
  
  float waveOffset(float pos, float y){
    return smoothstep(pos - 0.05, pos, y) - smoothstep(pos, pos + 0.05, y);
  }
        
  float4 main(PS_IN pin) {
    float2 uv = pin.Tex;
  
    const float offsetIntensity = 0.01;
    for (float j = 0.0; j < 5; j++) {
      float d = fmod(gTimeS * j * 0.12, 7);
      float o = sin(1.0 - tan(gTimeS * j * 0.024));
      uv.x += waveOffset(d, uv.y) * 0.005;
    }
   
    [branch]
    if (gPaused){
      uv += float2(
        (rand(float2(gTimeS, uv.y)) - 0.5) / 240,
        (rand(gTimeS) - 0.5) / 135);
      float noise = rand(float2(floor(uv.y * 240.0) + gTimeS, floor(uv.x * 150.0)));
      if (30 * uv.y - 18.5 > noise && noise > 5 * uv.y - 3.5) {
        return gBrightnessMult;
      }
    }
  
    float o = rand(uv);
    float lineValue = round(uv.y * 240) / 240;
    uv.x += 0.001 * rand(float2(gTimeS * 0.00001, lineValue));
  
    float4 baseColor = txInput.SampleLevel(samLinearSimple, uv, 0);
    float4 nearbyColor = txInput.SampleLevel(samLinearSimple, uv - float2(0, 0.05), 0);
    return baseColor;
    
    float3 colorNoise = (-0.5 + float3(
      rand(float2(lineValue, gTimeS)),
      rand(float2(lineValue, gTimeS + 1.0)),
      rand(float2(lineValue, gTimeS + 2.0)))) * 0.03 * (0.5 + saturate(dot(nearbyColor.rgb - baseColor.rgb, 10)));
  
    float s = 0.1;
    float e = min(0.3, pow(max(0, cos(uv.y * 4 + 0.3) - 0.75) * (s + 0.5), 3)) * 25;
    uv.x += e * 0.3;
    
    float y = rgbToYiq(blur(uv, 0.0002, o)).r;    
    float i = rgbToYiq(blur(uv, 0.0018, o)).g;
    float q = rgbToYiq(blur(uv, 0.0027, o)).b;
    return float4(yiqToRgb(float3(y, i, q)) * gBrightnessMult + colorNoise, 1);
  }
]]

local cfg = ac.INIConfig.scriptSettings():mapSection('POSTPROCESSING_VHS', {
  BRIGHTNESS_MULT = 1.2,
  USE_24H_FORMAT = false,
  FORCE_DATE = '',
  FONT = 'VCR OSD Mono:vcr_osd_mono.ttf',
  FONT_SIZE = 80,
  TEXT_COLOR = rgbm.colors.white,
  MARGIN = vec2(140, 100)
})

local canvas ---@type ui.ExtraCanvas

function script.update()
  local size = ui.windowSize()
  if not canvas or size ~= canvas:size() then
    ac.log('Create extra canvas: '..tostring(size))
    canvas = ui.ExtraCanvas(size):setName('Image with text')
  end

  local sim = ac.getSim()
  local paused = sim.isPaused or sim.replayPlaybackRate == 0

  -- Extra canvas is used to add text before running VHS filter
  canvas:update(function (dt)
    ui.setShadingOffset(1, 0, 0, 1)
    ui.drawImage('dynamic::screen', vec2(), size)
    ui.resetShadingOffset()
    
    ui.pushDWriteFont(cfg.FONT)
    ui.dwriteDrawText(paused and 'PAUSE' or 'PLAY',
      cfg.FONT_SIZE, cfg.MARGIN, cfg.TEXT_COLOR)
    ui.dwriteDrawText(cfg.USE_24H_FORMAT and os.date('%H:%M', sim.timestamp) or os.date('%I:%M %p', sim.timestamp),
     cfg.FONT_SIZE, vec2(cfg.MARGIN.x, size.y - cfg.MARGIN.y - cfg.FONT_SIZE * 2), cfg.TEXT_COLOR)
    ui.dwriteDrawText(#cfg.FORCE_DATE > 0 and cfg.FORCE_DATE or os.date('%h. %d %Y', sim.timestamp):upper(),
      cfg.FONT_SIZE, vec2(cfg.MARGIN.x, size.y - cfg.MARGIN.y - cfg.FONT_SIZE), cfg.TEXT_COLOR)
    ui.popDWriteFont()
    if paused then
      ui.setCursor(cfg.MARGIN + vec2(245, 8))
      ui.icon(ui.Icons.Pause, cfg.FONT_SIZE * 0.75, cfg.TEXT_COLOR)
    else
      ui.setCursor(cfg.MARGIN + vec2(200, 8))
      ui.icon(ui.Icons.Play, cfg.FONT_SIZE * 0.75, cfg.TEXT_COLOR)
    end
  end)

  ui.renderShader({
    p1 = vec2(),
    p2 = size,
    blendMode = render.BlendMode.Opaque,
    textures = {
      txInput = canvas
    },
    values = {
      gTimeS = sim.time / 1e3,
      gPaused = paused,
      gBrightnessMult = cfg.BRIGHTNESS_MULT
    },
    shader = shader
  })
end
