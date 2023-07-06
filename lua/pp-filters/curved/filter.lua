local sim = ac.getSim()

if sim.isVRMode or sim.isCustomVideoMode then
  ac.warn('Curved PP-filter is only available in single or triple screen mode')
  ac.setFilterActive(false)
  return
end

local canvasDebug ---@type ui.ExtraCanvas
local cameraRotation = vec2(-2.3, 1)
local cameraZoom = 0
local tripleState = ac.getTripleConfiguration()
local gAppliedFOV = -1
local gOptimalFOV = -1
local shaderData = nil
local settingsClock = -1
local hoveredScreen = -1
local hoveredState = {1, 1, 1}

local config = ac.storage{
  curvedPixelWidth = sim.windowWidth,
  curvedPixelHeight = sim.windowHeight,
  curvedSizeInches = 34,
  curvedRadius = 4,
  curvedPosBase = vec3(0, 0, 0),
  eyePosBase = vec3(0, 0, 0),
  flatActive = false,
  flatLeftWidth = 0.33,
  flatLeftHeight = 1,
  flatLeftGap = 0,
  flatLeftY = 0,
  flatLeftAngle = 45,
  flatRightWidth = 0.33,
  flatRightHeight = 1,
  flatRightGap = 0,
  flatRightY = 0,
  flatRightAngle = 45
}

if config.eyePosBase.z >= 0 then
  config.eyePosBase.z = -ac.INIConfig.load(ac.getFolder(ac.FolderID.ACDocuments)..'/cfg/triple_screen.ini'):get('SPINNERS', 'SP_DISTANCE', 1300) / 1000
end

local function saveSettings()
  return stringify{
    curvedPixelWidth = config.curvedPixelWidth,
    curvedPixelHeight = config.curvedPixelHeight,
    curvedSizeInches = config.curvedSizeInches,
    curvedRadius = config.curvedRadius,
    curvedPosBase = config.curvedPosBase,
    eyePosBase = config.eyePosBase,
    flatActive = config.flatActive,
    flatLeftWidth = config.flatLeftWidth,
    flatLeftHeight = config.flatLeftHeight,
    flatLeftGap = config.flatLeftGap,
    flatLeftY = config.flatLeftY,
    flatLeftAngle = config.flatLeftAngle,
    flatRightWidth = config.flatRightWidth,
    flatRightHeight = config.flatRightHeight,
    flatRightGap = config.flatRightGap,
    flatRightY = config.flatRightY,
    flatRightAngle = config.flatRightAngle,
  }
end

local function getCurvedFlatWidth()
  return vec2.tmp():set(config.curvedPixelWidth, config.curvedPixelHeight):normalize():scale(config.curvedSizeInches * 0.0254).x
end

local function getCurvedWidth()
  local angle = 2 * math.asin(math.min(1, getCurvedFlatWidth() / (2 * config.curvedRadius)))
  return angle * config.curvedRadius
end

local function loadSettings(data)
  table.assign(config, stringify.tryParse(data, {}))
end

local function cross2d(a, b)
  return a.x * b.y - a.y * b.x
end

local function vecItem(vec, index)
  if index == 0 then return vec.x end
  if index == 1 then return vec.y end
  return vec.z
end

local ca, cb, cc, cp, cnor, cpos, cmor = vec3(), vec3(), vec3(), vec3(), vec3(), vec3(), vec3()
local ckp, cka, ckb, ckc, ckg, cma = vec2(), vec2(), vec2(), vec2(), vec2(), math.abs
local function quadIntersect(ro, rd, v0, v1, v2, v3, d)
  local a = ca:set(v1):sub(v0)
  local b = cb:set(v3):sub(v0)
  local c = cc:set(v2):sub(v0)
  local p = cp:set(ro):sub(v0)

  local nor = cnor:set(a):cross(b)
  local t = -p:dot(nor) / rd:dot(nor)
  if t < 0 then return false end

  local pos = cpos:set(p):addScaled(rd, t)
  local mor = cmor:set(cma(nor.x), cma(nor.y), cma(nor.z))
  local id = (mor.x > mor.y and mor.x > mor.z) and 0 or (mor.y > mor.z) and 1 or 2
  local idu = (id + 1) % 3
  local idv = (id + 2) % 3

  local kp = ckp:set(vecItem(pos, idu), vecItem(pos, idv))
  local ka = cka:set(vecItem(a, idu), vecItem(a, idv))
  local kb = ckb:set(vecItem(b, idu), vecItem(b, idv))
  local kc = ckc:set(vecItem(c, idu), vecItem(c, idv))

  local kg = ckg:set(kc):sub(kb):sub(ka)
  local k0 = cross2d(kp, kb)
  local k1 = cross2d(kp, kg) - vecItem(nor, id)

  local v = -k0 / k1
  local u = cross2d(kp, ka) / k1
  return u >= 0 and u <= 1 and v >= 0 and v <= 1
end

local cos = vec3()
local function getOnscreenPos(x, y, curvedAngle, curvedRadius, curvedHeight, curvedPos, flatProjectData)
  if flatProjectData then
    return cos:set(x == -1
      and (y == -1 and flatProjectData.gFlatLeft0 or flatProjectData.gFlatLeft1)
      or (y == -1 and flatProjectData.gFlatRight2 or flatProjectData.gFlatRight3))
  else
    local u = (x - 0.5) * curvedAngle
    return cos:set(math.sin(u) * curvedRadius, (0.5 - y) * curvedHeight, math.cos(u) * curvedRadius):add(curvedPos)
  end
end

local function reprojectFn(x, y, curvedAngle, curvedRadius, curvedHeight, curvedPos, corners, flatProjectData)
  local onScreen = getOnscreenPos(x, y, curvedAngle, curvedRadius, curvedHeight, curvedPos, flatProjectData)
  return quadIntersect(config.eyePosBase, onScreen:sub(config.eyePosBase):normalize(), corners[1], corners[2], corners[3], corners[4])
end

local function reprojectTripleFn(x, y, curvedAngle, curvedRadius, curvedHeight, curvedPos, tripleData, flatProjectData)
  local onScreen = getOnscreenPos(x, y, curvedAngle, curvedRadius, curvedHeight, curvedPos, flatProjectData)
  local dir = onScreen:sub(config.eyePosBase):normalize()
  return quadIntersect(config.eyePosBase, dir, tripleData.gTripleCornerL0, tripleData.gTripleCornerL1, tripleData.gTripleCornerL2, tripleData.gTripleCornerL3)
    or quadIntersect(config.eyePosBase, dir, tripleData.gTripleCornerR0, tripleData.gTripleCornerR1, tripleData.gTripleCornerR2, tripleData.gTripleCornerR3)
    or quadIntersect(config.eyePosBase, dir, tripleData.gTripleCornerC0, tripleData.gTripleCornerC1, tripleData.gTripleCornerC2, tripleData.gTripleCornerC3)
end

local fc = {vec3(), vec3(), vec3(), vec3()}
local function computeFlatCorners(aspectRatio, fov, distanceMult)
  local flatSize = vec2(1, aspectRatio) * math.sin(fov) * -config.eyePosBase.z
  local flatPosZ = math.cos(fov) * -config.eyePosBase.z
  distanceMult = distanceMult and distanceMult / flatPosZ or 1
  fc[1]:set(-flatSize.x / 2., flatSize.y / 2., flatPosZ):scale(distanceMult)
  fc[2]:set(-flatSize.x / 2., -flatSize.y / 2., flatPosZ + 0.0001):scale(distanceMult)
  fc[3]:set(flatSize.x / 2., -flatSize.y / 2., flatPosZ + 0.0001):scale(distanceMult)
  fc[4]:set(flatSize.x / 2., flatSize.y / 2., flatPosZ):scale(distanceMult)
  return fc
end

local function getFlatPrecomputedData(curvedAngle, curvedRadius, curvedWidth, curvedHeight, curvedPos)
  local lRef = getOnscreenPos(0, 0.5, curvedAngle, curvedRadius, curvedHeight, curvedPos):clone()
  local lY, lX = -math.sin(math.rad(config.flatLeftAngle)), -math.cos(math.rad(config.flatLeftAngle))
  local lH = curvedHeight * config.flatLeftHeight / 2
  local lW = curvedWidth * config.flatLeftWidth
  local rRef = getOnscreenPos(1, 0.5, curvedAngle, curvedRadius, curvedHeight, curvedPos)
  local rY, rX = -math.sin(math.rad(config.flatRightAngle)), math.cos(math.rad(config.flatRightAngle))
  local rH = curvedHeight * config.flatRightHeight / 2
  local rW = curvedWidth * config.flatRightWidth
  local lS = config.flatLeftWidth / (1 + config.flatLeftWidth + config.flatRightWidth)
  local rS = config.flatRightWidth / (1 + config.flatLeftWidth + config.flatRightWidth)
  return {
    gFlatLeftShare = lS,
    gFlatRightShare = rS,
    gFlatXMul = 1 / (1 - lS - rS),
    gFlatLeft0 = vec3(lX * (lW + config.flatLeftGap), lH + config.flatLeftY * curvedHeight, lY * (lW + config.flatLeftGap)):add(lRef),
    gFlatLeft1 = vec3(lX * (lW + config.flatLeftGap), -lH + config.flatLeftY * curvedHeight, lY * (lW + config.flatLeftGap)):add(lRef),
    gFlatLeft2 = vec3(lX * (0 + config.flatLeftGap), -lH + config.flatLeftY * curvedHeight, lY * (0 + config.flatLeftGap)):add(lRef),
    gFlatLeft3 = vec3(lX * (0 + config.flatLeftGap), lH + config.flatLeftY * curvedHeight, lY * (0 + config.flatLeftGap)):add(lRef),
    gFlatRight0 = vec3(rX * (0 + config.flatRightGap), rH + config.flatRightY * curvedHeight, rY * (0 + config.flatRightGap)):add(rRef),
    gFlatRight1 = vec3(rX * (0 + config.flatRightGap), -rH + config.flatRightY * curvedHeight, rY * (0 + config.flatRightGap)):add(rRef),
    gFlatRight2 = vec3(rX * (rW + config.flatRightGap), -rH + config.flatRightY * curvedHeight, rY * (rW + config.flatRightGap)):add(rRef),
    gFlatRight3 = vec3(rX * (rW + config.flatRightGap), rH + config.flatRightY * curvedHeight, rY * (rW + config.flatRightGap)):add(rRef),
    gHoveredLeft = hoveredState[1],
    gHoveredMiddle = hoveredState[2],
    gHoveredRight = hoveredState[3],
  }
end

local function findFittingFOV()
  local aspectRatio = sim.windowHeight / sim.windowWidth
  local curvedWidth = getCurvedWidth()
  local curvedAngle = curvedWidth / config.curvedRadius
  local curvedHeight = (aspectRatio * config.curvedRadius * curvedAngle)
  local curvedPos = config.curvedPosBase - vec3(0, 0, config.curvedRadius)
  local distanceMult = config.curvedPosBase.z + 0.5

  local flatProjectData
  if config.flatActive then
    flatProjectData = getFlatPrecomputedData(curvedAngle, config.curvedRadius, curvedWidth, curvedHeight, curvedPos)
  end

  local a = math.rad(1) / 2
  local b = math.rad(179) / 2
  for _ = 1, 12 do
    local c = (a + b) / 2
    local corners = computeFlatCorners(aspectRatio, c, distanceMult)
    if reprojectFn(0, 0, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners) 
        and reprojectFn(0, 1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners)
        and reprojectFn(1, 1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners)
        and reprojectFn(1, 0, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners)
        and (not flatProjectData
          or reprojectFn(-1, -1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners, flatProjectData)
          and reprojectFn(-1, 2, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners, flatProjectData)
          and reprojectFn(2, 2, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners, flatProjectData)
          and reprojectFn(2, -1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, corners, flatProjectData)) then
      b = c
    else
      a = c
    end
  end
  return math.deg((a + b) / 2) * 2
end

local function isTripleFits()
  if not shaderData.values or not shaderData.values.gTripleCornerR0 then
    return nil
  end

  local aspectRatio = sim.windowHeight / sim.windowWidth
  local curvedWidth = getCurvedWidth()
  local curvedAngle = curvedWidth / config.curvedRadius
  local curvedHeight = (aspectRatio * config.curvedRadius * curvedAngle)
  local curvedPos = config.curvedPosBase - vec3(0, 0, config.curvedRadius)

  local flatProjectData
  if config.flatActive then
    flatProjectData = getFlatPrecomputedData(curvedAngle, config.curvedRadius, curvedWidth, curvedHeight, curvedPos)
  end

  -- do 
  --   return reprojectTripleFn(0, 0, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values) 
  -- end

  return reprojectTripleFn(0, 0, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values) 
      and reprojectTripleFn(0, 1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values)
      and reprojectTripleFn(1, 1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values)
      and reprojectTripleFn(1, 0, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values)
      and (not flatProjectData
        or reprojectTripleFn(-1, -1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values, flatProjectData)
        and reprojectTripleFn(-1, 2, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values, flatProjectData)
        and reprojectTripleFn(2, 2, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values, flatProjectData)
        and reprojectTripleFn(2, -1, curvedAngle, config.curvedRadius, curvedHeight, curvedPos, shaderData.values, flatProjectData))
end

local function refreshComputedValues(useOptimalFOV)
  local windowSize = vec2(sim.windowWidth, sim.windowHeight)
  local aspectRatio = sim.windowHeight / sim.windowWidth
  local curvedWidth = getCurvedWidth()
  local curvedAngle = curvedWidth / config.curvedRadius
  local curvedHeight = (aspectRatio * config.curvedRadius * curvedAngle)
  local curvedPos = config.curvedPosBase - vec3(0, 0, config.curvedRadius)

  local cacheKey = 1
  local shaderValues = {
    iResolution = windowSize,
    gHighlightMissingData = os.preciseClock() < settingsClock,
    gCamera = cameraRotation,
    gCameraZoom = cameraZoom,
    gCurvedRadius = config.curvedRadius,
    gCurvedAngle = curvedAngle,
    gCurvedHeight = curvedHeight,
    gCurvedPos = curvedPos,
    gEyePos = config.eyePosBase,
  }

  if config.flatActive then
    table.assign(shaderValues, getFlatPrecomputedData(curvedAngle, config.curvedRadius, curvedWidth, curvedHeight, curvedPos))
    cacheKey = bit.bor(cacheKey, 2)
  end

  if tripleState and sim.isTripleScreenAvailable then
    gOptimalFOV = -1
    local distanceMult = (config.curvedPosBase.z + 0.5) * 0.7
    table.assign(shaderValues, {
      gTripleX0 = tripleState.screens[1].xFrom,
      gTripleX1 = tripleState.screens[1].xTo,
      gTripleCornerL0 = vec3(tripleState.screens[0].left.x, tripleState.screens[0].height / 2, tripleState.screens[0].left.y):scale(distanceMult),
      gTripleCornerL1 = vec3(tripleState.screens[0].left.x, -tripleState.screens[0].height / 2, tripleState.screens[0].left.y):scale(distanceMult),
      gTripleCornerL2 = vec3(tripleState.screens[0].right.x, -tripleState.screens[0].height / 2, tripleState.screens[0].right.y):scale(distanceMult),
      gTripleCornerL3 = vec3(tripleState.screens[0].right.x, tripleState.screens[0].height / 2, tripleState.screens[0].right.y):scale(distanceMult),
      gTripleCornerC0 = vec3(tripleState.screens[1].left.x, tripleState.screens[1].height / 2, tripleState.screens[1].left.y):scale(distanceMult),
      gTripleCornerC1 = vec3(tripleState.screens[1].left.x, -tripleState.screens[1].height / 2, tripleState.screens[1].left.y):scale(distanceMult),
      gTripleCornerC2 = vec3(tripleState.screens[1].right.x, -tripleState.screens[1].height / 2, tripleState.screens[1].right.y):scale(distanceMult),
      gTripleCornerC3 = vec3(tripleState.screens[1].right.x, tripleState.screens[1].height / 2, tripleState.screens[1].right.y):scale(distanceMult),
      gTripleCornerR0 = vec3(tripleState.screens[2].left.x, tripleState.screens[2].height / 2, tripleState.screens[2].left.y):scale(distanceMult),
      gTripleCornerR1 = vec3(tripleState.screens[2].left.x, -tripleState.screens[2].height / 2, tripleState.screens[2].left.y):scale(distanceMult),
      gTripleCornerR2 = vec3(tripleState.screens[2].right.x, -tripleState.screens[2].height / 2, tripleState.screens[2].right.y):scale(distanceMult),
      gTripleCornerR3 = vec3(tripleState.screens[2].right.x, tripleState.screens[2].height / 2, tripleState.screens[2].right.y):scale(distanceMult),
    })
    cacheKey = bit.bor(cacheKey, 4)
  else
    gOptimalFOV = findFittingFOV()
    -- gOptimalFOV = -1
    local distanceMult = config.curvedPosBase.z + 0.5
    local fov = math.rad(useOptimalFOV and gOptimalFOV ~= -1 and gOptimalFOV or sim.cameraFOV) / 2
    local corners = computeFlatCorners(aspectRatio, fov, distanceMult)
    table.assign(shaderValues, {
      gFlatCorner0 = corners[1],
      gFlatCorner1 = corners[2],
      gFlatCorner2 = corners[3],
      gFlatCorner3 = corners[4],
    })
  end

  shaderData = {
    p1 = vec2(),
    p2 = ui.windowSize(),
    blendMode = render.BlendMode.Opaque,
    textures = {
      txSource = 'dynamic::screen'
    },
    values = shaderValues,
    defines = {
      USE_SIDE_MONITORS = config.flatActive,
      TRIPLE_MODE = tripleState and sim.isTripleScreenAvailable
    },
    shader = 'filter.fx',
    cacheKey = cacheKey
  }
end

local autoFitTriple = false
local configureBoth = false

local function settingsWindow()
  settingsClock = os.preciseClock() + 0.5

  hoveredState[1] = math.applyLag(hoveredState[1], hoveredScreen <= 0 and 1 or 0, 0.8, ui.deltaTime())
  hoveredState[2] = math.applyLag(hoveredState[2], (hoveredScreen == -1 or hoveredScreen == 1) and 1 or 0, 0.8, ui.deltaTime())
  hoveredState[3] = math.applyLag(hoveredState[3], (hoveredScreen == -1 or hoveredScreen == 2) and 1 or 0, 0.8, ui.deltaTime())
  hoveredScreen = -1

  refreshComputedValues()
  local windowSize = vec2(sim.windowWidth, sim.windowHeight)
  if not canvasDebug or canvasDebug:size() ~= windowSize then
    canvasDebug = ui.ExtraCanvas(windowSize)
  end

  canvasDebug:updateWithShader({
    textures = shaderData.textures,
    values = shaderData.values,
    defines = {
      DEBUG_VIEW = true,
      USE_SIDE_MONITORS = config.flatActive,
      TRIPLE_MODE = tripleState and sim.isTripleScreenAvailable
    },
    shader = 'filter.fx',
    cacheKey = bit.bor(shaderData.cacheKey, 8),
    async = true
  })

  ui.drawImage(canvasDebug, vec2(), ui.windowSize() - vec2(0, 10), true)

  ui.drawRectFilledMultiColor(vec2(ui.windowSize().x - 400, 0), ui.windowSize() - vec2(320, 10), 
    rgbm.colors.transparent, rgbm(0, 0, 0, 0.5), rgbm(0, 0, 0, 0.5), rgbm.colors.transparent)
  ui.drawRectFilled(vec2(ui.windowSize().x - 320, 0), ui.windowSize() - vec2(0, 10), rgbm(0, 0, 0, 0.5))

  local cur = ui.getCursor()
  ui.invisibleButton('##drag', ui.availableSpace())
  ui.setItemAllowOverlap()
  if ui.itemHovered() then
    if ui.mouseDown() then
      cameraRotation:addScaled(ui.mouseDelta():mul(vec2(-1, 1)), 0.02)
      cameraRotation.y = math.clampN(cameraRotation.y, -math.pi / 2, math.pi / 2)
    end
    cameraZoom = math.clampN(cameraZoom - ui.mouseWheel() * 0.4, -1, 1)
  end

  ui.setCursor(cur)
  ui.setCursorX(ui.availableSpaceX() - 320)
  ui.pushItemWidth(320)
  ui.beginGroup()
  local newValue

  ui.header('Monitors')
  ui.beginGroup()
  ui.setNextItemWidth(158)
  newValue = ui.slider('##width', config.curvedPixelWidth, 640, 12000, 'Width: %.0f px', 3)
  if ui.itemEdited() then config.curvedPixelWidth = newValue end
  ui.sameLine(0, 4)
  ui.setNextItemWidth(158)
  newValue = ui.slider('##height', config.curvedPixelHeight, 640, 12000, 'Height: %.0f px', 3)
  if ui.itemEdited() then config.curvedPixelHeight = newValue end
  ui.endGroup()
  if ui.itemHovered() then
    hoveredScreen = 1
    ui.setTooltip('Dimensions of a curved monitor. Only ratio is needed, so you can use the ratio (such as “16, 9”) instead of pixel dimensions.\n\nHold Shift while dragging a slider to increase accuracy. Hold Ctrl and click on a slider to set the exact number with keyboard.')
  end

  ui.setNextItemWidth(158)
  newValue = ui.slider('##size', config.curvedSizeInches, 5, 150, 'Size: %.1f inches')
  if ui.itemEdited() then config.curvedSizeInches = newValue end
  if ui.itemHovered() then
    hoveredScreen = 1
    ui.setTooltip('Size of the curved monitor’s diagonal in inches. Used together with ratio computed from Width and Height to estimate the actual screen width.\n\nHold Shift while dragging a slider to increase accuracy. Hold Ctrl and click on a slider to set the exact number with keyboard.')
  end
  ui.sameLine(0, 4)
  ui.setNextItemWidth(158)
  newValue = ui.slider('##radius', config.curvedRadius * 1000, 500, 6e3, 'Radius: %.0fR') / 1000
  if ui.itemEdited() then config.curvedRadius = newValue end
  if ui.itemHovered() then
    hoveredScreen = 1
    ui.setTooltip('Radius of the curved monitor’s curvature in millimeters. The exact value should be mentioned in tech specifications.\n\nHold Shift while dragging a slider to increase accuracy. Hold Ctrl and click on a slider to set the exact number with keyboard.')
  end

  ui.offsetCursorY(12)

  if configureBoth then
    ui.header('Positions')
    ui.beginGroup()
    ui.setNextItemWidth(104)
    newValue = ui.slider('##eye.x', config.eyePosBase.x * 100, -50, 50, 'Eye: %.1f cm') / 100
    if ui.itemEdited() then config.eyePosBase = vec3(newValue, config.eyePosBase.y, config.eyePosBase.z) end  
    ui.sameLine(0, 4)
    ui.setNextItemWidth(104)
    newValue = ui.slider('##eye.y', config.eyePosBase.y * 100, -50, 50, '%.1f cm') / 100
    if ui.itemEdited() then config.eyePosBase = vec3(config.eyePosBase.x, newValue, config.eyePosBase.z) end
    ui.sameLine(0, 4)
    ui.setNextItemWidth(104)
    newValue = ui.slider('##eye.z', config.eyePosBase.z * 100, -50, 50, '%.1f cm') / 100
    if ui.itemEdited() then config.eyePosBase = vec3(config.eyePosBase.x, config.eyePosBase.y, newValue) end
    ui.endGroup()
    if ui.itemHovered() then
      ui.setTooltip('Position of a viewer (marked as a red dot in a visualization).')
    end

    ui.beginGroup()
    ui.setNextItemWidth(104)
    newValue = ui.slider('##pos.x', config.curvedPosBase.x * 100, -50, 50, 'Mon.: %.1f cm') / 100
    if ui.itemEdited() then config.curvedPosBase = vec3(newValue, config.curvedPosBase.y, config.curvedPosBase.z) end
    ui.sameLine(0, 4)
    ui.setNextItemWidth(104)
    newValue = ui.slider('##pos.y', config.curvedPosBase.y * 100, -50, 50, '%.1f cm') / 100
    if ui.itemEdited() then config.curvedPosBase = vec3(config.curvedPosBase.x, newValue, config.curvedPosBase.z) end
    ui.sameLine(0, 4)
    ui.setNextItemWidth(104)
    newValue = ui.slider('##pos.z', config.curvedPosBase.z * 100, 20, 180, '%.1f cm') / 100
    if ui.itemEdited() then config.curvedPosBase = vec3(config.curvedPosBase.x, config.curvedPosBase.y, newValue) end
    ui.endGroup()
    if ui.itemHovered() then
      hoveredScreen = 1
      ui.setTooltip('Offset of the curved monitor.')
    end
  else
    ui.header('Position')
    ui.beginGroup()
    ui.setNextItemWidth(ui.availableSpaceX())
    newValue = ui.slider('##eye.x', config.eyePosBase.x * 100, -200, 200, 'Eye: %.1f cm') / 100
    if ui.itemEdited() then config.eyePosBase = vec3(newValue, config.eyePosBase.y, config.eyePosBase.z) end  
    ui.setNextItemWidth(ui.availableSpaceX())
    newValue = ui.slider('##eye.y', config.eyePosBase.y * 100, -200, 200, '%.1f cm') / 100
    if ui.itemEdited() then config.eyePosBase = vec3(config.eyePosBase.x, newValue, config.eyePosBase.z) end
    ui.setNextItemWidth(ui.availableSpaceX())
    newValue = ui.slider('##eye.z', -config.eyePosBase.z * 100, 50, 750, '%.1f cm', 2) / 100
    if ui.itemEdited() then config.eyePosBase = vec3(config.eyePosBase.x, config.eyePosBase.y, -newValue) end
    ui.endGroup()
    if ui.itemHovered() then
      ui.setTooltip('Position of a viewer (marked as a red dot in a visualization).')
    end
  end

  ui.offsetCursorY(12)
  ui.pushFont(ui.Font.Small)
  ui.pushStyleColor(ui.StyleColor.Text, rgbm.colors.transparent)
  if ui.checkbox('Additional monitors', config.flatActive) then
    config.flatActive = not config.flatActive
  end
  if ui.itemHovered() then
    ui.setTooltip('Use this option if you have two extra flat monitors on sides and want to project an accurate image on them as well.')
  end
  ui.popStyleColor()
  ui.sameLine(24)
  ui.header('Additional monitors')
  ui.popFont()

  if not config.flatActive then
    ui.pushDisabled()
  end
  
  ui.setNextItemWidth(158)
  newValue = ui.slider('##lw', config.flatLeftWidth * 100, 1, 200, 'Left width: %.1f%%')
  if ui.itemEdited() then config.flatLeftWidth = newValue / 100 end
  if ui.itemHovered() then hoveredScreen = 0 ui.setTooltip('Width relative to width of the curved monitor.') end
  ui.sameLine(0, 4)
  ui.setNextItemWidth(158)
  newValue = ui.slider('##lh', config.flatLeftHeight * 100, 1, 200, 'Left height: %.1f%%')
  if ui.itemEdited() then config.flatLeftHeight = newValue / 100 end  
  if ui.itemHovered() then hoveredScreen = 0 ui.setTooltip('Height relative to height of the curved monitor.') end
  ui.setNextItemWidth(158)
  newValue = ui.slider('##lg', config.flatLeftGap * 100, 0, 20, 'Left gap: %.1f cm')
  if ui.itemEdited() then config.flatLeftGap = newValue / 100 end
  if ui.itemHovered() then hoveredScreen = 0 ui.setTooltip('Distance between the curved monitor and the left one.') end
  ui.sameLine(0, 4)
  ui.setNextItemWidth(158)
  newValue = ui.slider('##lo', config.flatLeftY * 100, -50, 50, 'Left Y offset: %.1f%%')
  if ui.itemEdited() then config.flatLeftY = newValue / 100 end
  if ui.itemHovered() then hoveredScreen = 0 ui.setTooltip('Vertical offset relative to height of the curved monitor.') end
  newValue = ui.slider('##la', config.flatLeftAngle, 0, 90, 'Left angle: %.1f°')
  if ui.itemEdited() then config.flatLeftAngle = newValue  end
  if ui.itemHovered() then hoveredScreen = 0 ui.setTooltip('Angle at which left monitor is turned.') end
  
  ui.setNextItemWidth(158)
  newValue = ui.slider('##rw', config.flatRightWidth * 100, 1, 200, 'Right width: %.1f%%')
  if ui.itemEdited() then config.flatRightWidth = newValue / 100 end
  if ui.itemHovered() then hoveredScreen = 2 ui.setTooltip('Width relative to width of the curved monitor.') end
  ui.sameLine(0, 4)
  ui.setNextItemWidth(158)
  newValue = ui.slider('##rh', config.flatRightHeight * 100, 1, 200, 'Right height: %.1f%%')
  if ui.itemEdited() then config.flatRightHeight = newValue / 100 end  
  if ui.itemHovered() then hoveredScreen = 2 ui.setTooltip('Height relative to height of the curved monitor.') end
  ui.setNextItemWidth(158)
  newValue = ui.slider('##rg', config.flatRightGap * 100, 0, 20, 'Right gap: %.1f cm')
  if ui.itemEdited() then config.flatRightGap = newValue / 100 end
  if ui.itemHovered() then hoveredScreen = 2 ui.setTooltip('Distance between the curved monitor and the right one.') end
  ui.sameLine(0, 4)
  ui.setNextItemWidth(158)
  newValue = ui.slider('##ro', config.flatRightY * 100, -50, 50, 'Right Y offset: %.1f%%')
  if ui.itemEdited() then config.flatRightY = newValue / 100 end
  if ui.itemHovered() then hoveredScreen = 2 ui.setTooltip('Vertical offset relative to height of the curved monitor.') end
  newValue = ui.slider('##ra', config.flatRightAngle, 0, 90, 'Right angle: %.1f°')
  if ui.itemEdited() then config.flatRightAngle = newValue  end
  if ui.itemHovered() then hoveredScreen = 2 ui.setTooltip('Angle at which right monitor is turned.') end

  if not config.flatActive then
    ui.popDisabled()
  end

  if ui.button('Export settings', vec2(158, 0)) then
    os.saveFileDialog({
      defaultFolder = ac.getFolder(ac.FolderID.Documents),
      fileTypes = { { name = 'Curved Monitor config', mask = '*.cfg' } },
      defaultExtension = '.cfg'
    }, function (err, filename)
      if filename then
        io.save(filename, saveSettings())
      end
    end)
  end
  if ui.itemHovered() then ui.setTooltip('Save settings to a file to quicky apply them to a different PC.') end
  ui.sameLine(0, 4)
  if ui.button('Import settings', vec2(158, 0)) then
    os.openFileDialog({
      defaultFolder = ac.getFolder(ac.FolderID.Root),
      fileTypes = { { name = 'Curved Monitor config', mask = '*.cfg' } },
    }, function (err, filename)
      if filename then
        loadSettings(io.load(filename))
      end
    end)
  end
  if ui.itemHovered() then ui.setTooltip('Load previously saved settings.') end
  if sim.isTripleScreenAvailable then
    if ui.button('Auto-fit triple configuration', vec2(320, 0), autoFitTriple and ui.ButtonFlags.Active or 0) then
      autoFitTriple = true
    end
    if ui.itemHovered() then ui.setTooltip('Adjust triple screen configuration automatically to better fit the screens.') end
  else
    autoFitTriple = false
  end
  ui.endGroup()

  if gOptimalFOV > 0 then
    local msg, color = string.format('Optimal FOV: %.1f°', gOptimalFOV), rgbm.colors.white
    ui.drawRectFilled(vec2(40, 40) - 8, ui.measureText(msg) + 48, rgbm(0, 0, 0, 0.8), 2)
    ui.drawText(msg, vec2(40, 40), color)
  end
end

ui.addSettings({
  icon = 'icon.png',
  name = 'Curved Monitor Filter',
  size = {default = vec2(960, 540), min = vec2(480, 270)},
}, function ()
  gAppliedFOV = -1
  settingsWindow()
end)

ac.onTripleConfigurationChanged(function ()
  gAppliedFOV = -1
end)

local tripleAvailable = false
local tripleAdjustmentVelocity = 0
local tripleFitTarget
local tripleFitHits = 0
local tripleMajorJump = false

local function runTripleAutoFit()
  local fits = isTripleFits()
  if fits == nil then return end
  
  if tripleFitTarget == nil then
    tripleFitTarget = not fits
    tripleFitHits = 0
    tripleAdjustmentVelocity = 0
    tripleMajorJump = false
  end

  if tripleFitTarget == fits then
    if not tripleMajorJump then
      tripleMajorJump = true
      ac.setTripleWidth(ac.getTripleWidth() - 0.05)
    else
      tripleFitHits = tripleFitHits + 1
      if tripleFitHits > 10 then
        autoFitTriple = false
      end
    end
  end

  if fits then
    tripleAdjustmentVelocity = math.min(tripleAdjustmentVelocity, 0) - 0.001
  else
    tripleAdjustmentVelocity = math.max(tripleAdjustmentVelocity, 0) + 0.001
  end
  ac.setTripleWidth(ac.getTripleWidth() + tripleAdjustmentVelocity)
end

function script.update()
  if settingsClock ~= -1 and settingsClock < os.preciseClock() then
    settingsClock = -1
    gAppliedFOV = -1
  end
  if tripleAvailable ~= sim.isTripleScreenAvailable then
    tripleAvailable = not tripleAvailable
    gAppliedFOV = -1
  end
  if not shaderData or gAppliedFOV ~= sim.cameraFOV then
    gAppliedFOV = sim.cameraFOV
    refreshComputedValues(false)
    if not sim.isTripleScreenAvailable then
      if gOptimalFOV ~= -1 then
        ac.setFixedFOV(gOptimalFOV)
      else
        ac.setFixedFOV(nil)
      end
    elseif autoFitTriple then
      runTripleAutoFit()
    else
      tripleFitTarget = nil
    end
  end
  ui.renderShader(shaderData)
end
