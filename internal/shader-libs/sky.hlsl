/*
  A library helping to create a custom sky look:
  • Initialize library with `SkyUtils sky = initSkyUtils(pin);` once and access its public methods later;
  • Calculate full sky color with gradients, sun, moon and stars (without fog or rainbow) with `sky.Compute()`;
  • Calculate base sky color with `sky.GetBaseColor()` (use additional arguments to specify whether to include gradients or not);
  • Calculate sky color in a different direction with `sky.GetBaseColorAt(direction)`;
  • Get sun and moon direction with `sky.GetSunDirection()` and `sky.GetMoonDirection()`;
  • Get sun and moon shape with `sky.GetSunShape()` and `sky.GetMoonShape()` (1 within sun);
  • Compute star map UV with `sky.GetStarsUV()` and use it to sample the star map like `weather_fx/starmap.dds` one;
  • To respect user setting about star map quality use `sky.SampleStars(uv)`;
  • Use value returned by `sky.GetStarsMask()` as a multiplier for stars to hide ones behind sun and moon;
  • Use `sky.ApplyFog(color)` to apply sky-like fog and dithering to break banding to your color.

  Limitations:
  • Works with v2 sky only;
  • Works with new fog implementation only;
  • Doesn’t work as expected with cloud covers at the moment;
  • Rainbow is not included (it will go above clouds in the next update).

  Please do not use items with “__” at the start: those are implementation-specific and might change in the future.
*/

// Private part with implementation details:
Texture2D __txStarMap : register(t12);
#define __MAX_EXTRA_GRADIENTS_NUM 16

float __luminance(float3 rgb) {
  return dot(rgb, float3(0.2125, 0.7154, 0.0721));
}

struct ExtraGradient {
  float3 color;
  uint isAdditive_expValue;
  float3 directionX;
  float sizeY;
};

struct SkyParams {
  float3 gBetaM;
  float gMieV;
  float3 gCacheA;
  uint gSunShapeMult_Saturation;
  float gMieDirectionalG;
  float gMieZenithLength;
  float gRayleigh;
  float gRayleighZenithLength;
  float gSunIntensityFactor;
  float gSunIntensityFalloffSteepness;
  float gYScale;
  float gYOffset;
  float gLuminance;
  float gBackgroundLight;
  float gGammaInv;
  float gSaturation;

  float henyeyGreensteinPhase(float cosTheta) {
    float g2 = pow(gMieDirectionalG, 2);
    return (0.25 / 3.14159265359) * (1 - g2) / pow(saturate(1 - 2 * gMieDirectionalG * cosTheta + g2), 1.5);
  }

  float sunIntensity(float zenithAngleCos) {
    float cutoffAngle = 3.14159265359 / 1.95; // Earth shadow hack
    return gSunIntensityFactor * saturate(1 - exp(-((cutoffAngle - acos(zenithAngleCos)) / gSunIntensityFalloffSteepness)));
  }

  float3 getBetaR(float3 dir){
    float sunfade = 1 - saturate(1 - exp(dir.y));
    float rayleighCoefficient = gRayleigh - (1 - sunfade);
    return gCacheA * rayleighCoefficient;
  }

  float getDenom(float dirY){
    float zenithAngle = acos(dirY);
    return dirY + 0.15 * pow(93.885 - zenithAngle * (180.0 / 3.14159265359), -1.253);
  }

  float rayleighPhase(float cosTheta) {
    return (3 / (16 * 3.14159265359)) * (1 + pow(cosTheta, 2));
  }

  void calculate(float3 dir, out float3 sky, out float3 sun, out float3 fex);
};

cbuffer cbSkyData : register(b6) { 
  float __cSunSize;
  float3 __cSunDirection;
  float __cMoonSize;
  float __cMoonMieExp;
  float __cFogMult;
  float __cBrightnessMult;
  float3 __cMoonMieColor;
  float __cStarsSaturation;
  float3 __cStarsColor;
  float __cStarsBrightness;
  float3 __cMoonDirection;
  float __cStarsExponent;
  float __cFogMult2;
  float __cFogMultExp;
  float cFogRange;
  uint __cExtraGradientsCount;
  float4x4 __cStarMapRotation;
  SkyParams __gSkySun;
  SkyParams __gSkyOpposite;
  float __cRainbowBrightness;
  float __cRainbowSecondaryBrightness;
  float __cRainbowInBetweenDarkening;
  float __cFogNewFormula;
  float3 __cGradientDirection;
  float __sky_hlsl_pad;
  ExtraGradient __extraGradients[__MAX_EXTRA_GRADIENTS_NUM]; 
}

// Main thing providing a nice interface:
struct SkyUtils {
  // Public functions (will always remain this way):
  float3 GetSunDirection() {
    return __cSunDirection;
  }

  float3 GetMoonDirection() {
    return __cMoonDirection;
  }

  float GetSunShape() {
    float sunDotV = dot(__dir, __cSunDirection);
    return __sunPoint(sunDotV);
  }

  float GetMoonShape() {
    float moonDotV = saturate(dot(__dir, __cMoonDirection));
    return saturate(__moonPoint(moonDotV) * 100);
  }

  float2 GetStarsUV() {
    float3 dirRotated = mul(__dir, (float3x3)__cStarMapRotation);
    float u = atan2(-dirRotated.x, dirRotated.z) / (2 * 3.14159265359) + 0.5;
    float v = 0.5 - asin(dirRotated.y) / (3.14159265359 / 2) * 0.5;
    return float2(u, v);
  }

  float GetStarsMask() {
    return (1 - GetSunShape()) * (1 - GetMoonShape());
  }

  float3 SampleStars(float2 uv){
    float3 ret;
    #ifdef __SKY_HLSL_HIGH_QUALITY_STARS
      float2 textureResolution;
      __txStarMap.GetDimensions(textureResolution.x, textureResolution.y);
      float2 sizeInv = 2 / textureResolution;    
      float mip0 = __txStarMap.CalculateLevelOfDetail(samLinearSimple, uv.y) - 0.5;
      float4 base = __txStarMap.SampleLevel(samLinearSimple, uv, mip0);
      float4 blurred = 0
        + __txStarMap.SampleLevel(samLinearSimple, uv + sizeInv * float2(0.5, 0.5), mip0)
        + __txStarMap.SampleLevel(samLinearSimple, uv + sizeInv * float2(0.5, -0.5), mip0)
        + __txStarMap.SampleLevel(samLinearSimple, uv + sizeInv * float2(-0.5, 0.5), mip0)
        + __txStarMap.SampleLevel(samLinearSimple, uv + sizeInv * float2(-0.5, -0.5), mip0);
      float4 delta = base - blurred / 4;
      return (base + (0.6 * saturate(dot(float4(delta.xyz, 0.5), 1)) - 0.3) * 0).xyz;
    #else
      return __txStarMap.Sample(samLinearSimple, uv).xyz;
    #endif
  }

  float3 GetBaseColor(bool withGradients = true) {
    return GetBaseColorAt(__dir, withGradients);
  }

  float3 GetBaseColorAt(float3 dir, bool withGradients = true) {
    float3 sky0, sun0, fex0, sky1, sun1, fex1;
    __gSkySun.calculate(__dir, sky0, sun0, fex0);
    __gSkyOpposite.calculate(__dir, sky1, sun1, fex1);

    float sunSideBase = saturate(dot(__dir, __cGradientDirection) * 0.5 + 0.5);
    float sunSide = sunSideBase;
    float3 totalSky = lerp(sky1, sky0, sunSide);
    if (withGradients) {
      __gradients(__dir, totalSky);
    }

    return totalSky * __cBrightnessMult;
  }

  float3 Compute(){
    float3 sky0, sun0, fex0, sky1, sun1, fex1;
    __gSkySun.calculate(__dir, sky0, sun0, fex0);
    __gSkyOpposite.calculate(__dir, sky1, sun1, fex1);

    float sunSideBase = saturate(dot(__dir, __cGradientDirection) * 0.5 + 0.5);
    float sunSide = sunSideBase;
    float3 totalSky = lerp(sky1, sky0, sunSide);
    float3 totalSun = lerp(sun1, sun0, sunSide);
    float3 totalFex = lerp(fex1, fex0, sunSide);
    __gradients(__dir, totalSky);

    float sunShape = GetSunShape();
    float moonDotV = saturate(dot(__dir, __cMoonDirection));
    float moonShapeInv = saturate(1.0 - __moonPoint(moonDotV) * 100);
    float moonMie = pow(moonDotV, __cMoonMieExp);
    totalSky += moonMie * __cMoonMieColor;
    totalSky += totalSun * sunShape * moonShapeInv;

    [branch]
    if (__cStarsBrightness > 0.001){
      float3 dirRotated = mul(__dir, (float3x3)__cStarMapRotation);
      float u = atan2(-dirRotated.x, dirRotated.z) / (2 * 3.14159265359) + 0.5;
      float v = 0.5 - asin(dirRotated.y) / (3.14159265359 / 2) * 0.5;
      float3 txStarsValue = SampleStars(float2(u, v)) * (1 - sunShape) * moonShapeInv * totalFex * __cStarsColor;
      float3 starsBlend = lerp(__luminance(txStarsValue), txStarsValue, __cStarsSaturation);
      return totalSky * __cBrightnessMult + pow(abs(starsBlend), __cStarsExponent) * __cStarsBrightness;
    } else {
      return totalSky * __cBrightnessMult;
    }
  }

  float3 ApplyFog(float3 color) {
    float fogMult = __cFogMult + __cFogMult2 * pow(saturate(cFogRange - __dir.y * cFogRange), __cFogMultExp);
    return __fog(color, fogMult) + __pin.GetDithering();
  }

  // Private members (please do not use them):
  PS_IN __pin;
  float3 __dir;

  float __sunPoint(float dotV){
    return saturate(dotV * __cSunSize - 100000);
  }

  float __moonPoint(float dotV){
    return saturate(dotV * __cMoonSize - 100000);
  }

  void __gradient(ExtraGradient g, float3 dir, inout float3 color){
    float dotV = dot(g.directionX, dir);
    float dotT = saturate(dotV + g.sizeY);
    float smooth = pow(dotT * dotT * (3 - 2 * dotT), f16tof32(g.isAdditive_expValue >> 16));
    float3 colorSmoothed = g.color * smooth;
    if (g.isAdditive_expValue & 1){
      color += colorSmoothed;
    } else {
      color *= 1 - smooth + colorSmoothed;
    }
  }

  void __gradients(float3 dir, inout float3 color){
    for (uint i = 0; i < __cExtraGradientsCount; i++){
      __gradient(__extraGradients[i], dir, color);
    }
  }

  float3 __fog(float3 baseResult, float fogMult) {
    float3 dir = __dir;
    if (abs(dir.y) < 0.001) dir.y = 0.001;
    float buggyPart = (1 - exp(-30000 * dir.y / gFogLinear)) / dir.y;
    float fog = gFogBlend * pow(saturate(gFogConstantPiece * buggyPart), gFogExp);    
    float sunAmount = saturate(dot(-dir, gLightDirection.xyz));
    float3 fogColor = gFogColor + gLightColor.xyz * pow(sunAmount, gFogBacklitExp) * gFogBacklitMult;
    return lerp(baseResult.rgb, fogColor, saturate(fog * fogMult));
  }
};

SkyUtils initSkyUtils(PS_IN pin) {
  SkyUtils ret;
  ret.__pin = pin;
  ret.__dir = normalize(pin.PosC);
  return ret;
}

void SkyParams::calculate(float3 dir, out float3 sky, out float3 sun, out float3 fex){
  // Rayleigh coefficient
  float3 betaR = getBetaR(__cSunDirection);
  
  // Mie coefficient
  float3 betaM = gBetaM;
  
  // Adjusted Y components of directions
  float dirY = saturate(dir.y * gYScale + gYOffset);
  float sunY = saturate(__cSunDirection.y * gYScale + gYOffset);

  // Optical length, cutoff angle at 90 to avoid singularity
  float denom = getDenom(dirY);
  float sR = gRayleighZenithLength / denom;
  float sM = gMieZenithLength / denom;
  
  // Combined extinction factor
  fex = exp(-(betaR * sR + betaM * sM));
  
  // In-scattering
  float sunDotV = dot(dir, __cSunDirection);
  float3 betaRTheta = betaR * rayleighPhase(sunDotV * 0.5 + 0.5);
  float3 betaMTheta = betaM * henyeyGreensteinPhase(sunDotV);
  float sunE = sunIntensity(sunY);

  float3 Lbase = (betaRTheta + betaMTheta) / (betaR + betaM);
  float3 Lin = pow(max(sunE * Lbase * (1 - fex), 0), 1.5);
  Lin *= lerp(1, pow(max(sunE * Lbase * fex, 0), 0.5), pow(1 - sunY, 5));
  
  // Composition + solar disc
  sky = Lin + gBackgroundLight * fex;
  sky *= gLuminance;

  float sat = 1 - min(sky.r, min(sky.g, sky.b)) / (max(sky.r, max(sky.g, sky.b)) + 0.01);
  sky = max(0, lerp(__luminance(sky), sky, lerp(gSaturation, min(gSaturation, 1), pow(sat, 8))));
  sky = pow(max(sky, 0), gGammaInv);

  float2 sunMult_Saturation = float2(f16tof32(gSunShapeMult_Saturation), f16tof32(gSunShapeMult_Saturation >> 16));
	sun = sunE * max(0, lerp(__luminance(fex), fex, sunMult_Saturation.y)) * sunMult_Saturation.x;
}
