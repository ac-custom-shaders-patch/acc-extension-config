ac.setMIPs(9)

local offset = 0
local offsetSmooth = 0
local flash = 0
local flashNoiseOffset = vec2(0.5, 0.5)
local texOffset = vec2()
local texSkew = 0
local baseLevel = 0
local blurLevel = 0
local blurLevelSmooth = 0

function script.update(dt)
  local sim = ac.getSim()
  local paused = sim.isPaused or sim.replayPlaybackRate == 0
  local aspectRatio = ui.windowWidth() / ui.windowHeight()

  offset = math.applyLag(offset, 0, 0.95, dt)
  if math.random() > 0.95 + math.sin(sim.time / 1e3) * math.sin(sim.time / 1.71e3) * 0.04 then
    offset = offset + (math.random() - 0.5) * 0.01
  end
  offsetSmooth = math.applyLag(offsetSmooth, offset, 0.5, dt)

  if math.random() > 0.995 then
    flash = math.random() > 0.3 and math.random() or -math.random() / 2
    flashNoiseOffset.x, flashNoiseOffset.y = math.random(), math.random()
  else
    flash = math.applyLag(flash, 0, 0.6, dt)
  end

  if math.random() > 0.95 then
    texOffset = vec2(math.random(), math.random()) * 0.0012
    texSkew = math.random() * 0.005
  end

  if math.random() > 0.99 then
    baseLevel = math.random() ^ 2 * 0.8
  end

  local r = math.random()
  if r > 0.98 - blurLevelSmooth * 0.04 then
    blurLevel = r < 0.981 and 1 + math.random() or 0
  end
  blurLevelSmooth = math.applyLag(blurLevelSmooth, blurLevel, 0.8, dt)

  ui.renderShader({
    p1 = vec2(),
    p2 = ui.windowSize(),
    blendMode = render.BlendMode.Opaque,
    textures = {
      txInput = 'dynamic::screen',
      txNoise = 'dynamic::noise'
    },
    values = {
      gBaseLevel = baseLevel + blurLevelSmooth,
      gBlurLevel = vec2(1, aspectRatio):scale(blurLevelSmooth * 0.002),
      gAspectRatioInv = 1 / aspectRatio,
      gTimeS = sim.time / 1e3,
      gPaused = paused,
      gOffset = offsetSmooth,
      gFlicker = (math.random() - 0.5) ^ 7,
      gTexOffset = texOffset,
      gTexSkew = texSkew,

      gStripeColor = math.random() > 0.1 and 1 or -1,
      gStripeWidth = math.random() * 0.003 + 0.002,
      gStripePosition = math.random() > 0.95 and math.random() or -1,

      gSpot = math.random() > 0.995 and vec2(math.random(), math.random()) or vec2(-1, -1),
      gSpotColor = math.random() > 0.1 and 1 or -1,
      gSpotSize = 0.05 + math.random() ^ 2 * 0.15,
      gSpotHeight = 0.5 + math.random(),

      gFlash = flash,
      gFlashNoiseOffset = flashNoiseOffset,

      gScratch = vec2(math.random(), math.random()),
      gScratchChance = 24 - math.random() ^ 2 * 5,
      gBlobChance = 4 - math.random() ^ 2 * 2,

      gNoiseOffset = vec2(math.random(), math.random()),
    },
    shader = 'filter.fx'
  })
end
