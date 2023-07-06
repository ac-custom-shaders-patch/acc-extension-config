
float4 main(PS_IN pin) {
  float depthValue = txDepth.SampleLevel(samPointClamp, pin.Tex, 0);
  // float linearDepth = linearizeDepth(depthValue);
  float t = delinearizeDepth(1.3);
  if (depthValue < t) return txInput.SampleLevel(samPointClamp, pin.Tex, 0);

  float2 texBase = (pin.Tex.xy - gRegion.xy) / gRegion.zw;
  float4 posW = mul(float4(texBase, depthValue, 1), gTexToCamera);
  posW.xyz /= posW.w;
  float4 newUV = mul(posW, gPreviousCameraToTex);
  newUV /= newUV.w;
  newUV.xy = gRegion.xy + gRegion.zw * newUV.xy;

  float2 delta = (newUV.xy - pin.Tex) * (1 + pow(pin.Tex * 2 - 1, 2));
  delta = delta / (1 + delta);
  float4 r = float4(txInput.SampleLevel(samPointClamp, pin.Tex, 0).rgb, 1) * 0.01;
  float noise = txNoise.Load(int3(pin.PosH.xy % 32, 0)).x;
  for (int i = 0; i < 10; ++i){
    float2 uv = pin.Tex + delta * ((i + noise) / 10.);
    float mult = saturate((txDepth.SampleLevel(samPointClamp, uv, 0) - t) * 1e6);
    r += float4(txInput.SampleLevel(samPointClamp, uv, 0).rgb, 1) * mult;
  }
  return r / r.w;
}