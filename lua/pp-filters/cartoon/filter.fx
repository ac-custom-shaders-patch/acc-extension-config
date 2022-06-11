float edge(float2 uv){
  float edginess = 0;
  float base = 1 / (1 - 0.8 * txDepth.SampleLevel(samLinearSimple, uv, 0).x);
  [unroll] for (int x = -1; x <= 1; x += 2)
  [unroll] for (int y = -1; y <= 1; y += 2){
    edginess += saturate(10 * abs(1 / (1 - 0.8 * txDepth.SampleLevel(samLinearSimple, uv, 0, int2(x, y)).x) - base));
  }
  return edginess / 4;
}

#define EPSILON 1e-10

float3 hue2rgb(in float hue) {
  float3 rgb = abs(hue * 6. - float3(3, 2, 4)) * float3(1, -1, -1) + float3(-1, 2, 2);
  return clamp(rgb, 0., 1);
}

float3 rgb2hcv(in float3 rgb) {
  float4 p = (rgb.g < rgb.b) ? float4(rgb.bg, -1, 2 / 3.) : float4(rgb.gb, 0., -1 / 3.);
  float4 q = (rgb.r < p.x) ? float4(p.xyw, rgb.r) : float4(rgb.r, p.yzx);
  float c = q.x - min(q.w, q.y);
  float h = abs((q.w - q.y) / (6 * c + EPSILON) + q.z);
  return float3(h, c, q.x);
}

float3 hsv2rgb(in float3 hsv) {
  float3 rgb = hue2rgb(hsv.x);
  return ((rgb - 1) * hsv.y + 1) * hsv.z;
}

float3 hsl2rgb(in float3 hsl) {
  float3 rgb = hue2rgb(hsl.x);
  float c = (1 - abs(2 * hsl.z - 1)) * hsl.y;
  return (rgb - 0.5) * c + hsl.z;
}

float3 rgb2hsv(in float3 rgb) {
  float3 hcv = rgb2hcv(rgb);
  float s = hcv.y / (hcv.z + EPSILON);
  return float3(hcv.x, s, hcv.z);
}

float3 rgb2hsl(in float3 rgb) {
  float3 hcv = rgb2hcv(rgb);
  float z = hcv.z - hcv.y * 0.5;
  float s = hcv.y / (1 - abs(z * 2 - 1) + EPSILON);
  return float3(hcv.x, s, z);
}

float3 cartonify(float3 i){
  // return round(i * 12) / 12;
  float3 hsl = rgb2hsl(i);
  hsl.x = round(hsl.x * 12) / 12;
  hsl.y = round(hsl.y * 4) / 4;
  hsl.z = round(hsl.z * 10) / 10;
  return hsl2rgb(clamp(hsl, 0.000001, 0.99999));
}

float3 main(PS_IN pin) {
  // return edge(pin.Tex);
  float e = edge(pin.Tex);
  float h = length((float2)(pin.PosH.xy % 8) - 4) < 2
    || length((float2)((pin.PosH.xy + int2(4, -4)) % 8) - 4) < 2;
  float3 i = txInput.SampleLevel(samLinearSimple, pin.Tex, 0).rgb;
  i = lerp(0.5, i, 1 + h * 0.2);
  return lerp(lerp(0.1 * (1 - e), 1, cartonify(i)), 0, saturate(e * 2));
}
