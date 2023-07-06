// Based on https://www.shadertoy.com/view/4lcSRn by Inigo Quilez

#define AA 0

float cross2d(float2 a, float2 b) { return a.x * b.y - a.y * b.x; }
static const int lut[4] = {1, 2, 0, 1};

float4 iCylinder_side(float3 ro, float3 rd, float3 pa, float3 pb, float ra) {
  float3  ba = pb - pa;
  float3  oc = ro - pa;

  float baba = dot(ba,ba);
  float bard = dot(ba,rd);
  float baoc = dot(ba,oc);
  
  float k2 = baba - bard * bard;
  float k1 = baba * dot(oc,rd) - baoc * bard;
  float k0 = baba * dot(oc,oc) - baoc * baoc - ra * ra * baba;
  
  float h = k1 * k1 - k2 * k0;
  if (h < 0.0) return -1;
  h = sqrt(h);
  float t = (-k1 - h) / k2;
  float y = baoc + t * bard;
  if (y > 0.0 && y < baba) return float4(t, ro + rd * t);
  return -1;
}

float2 iCylinder(inout float t0, float3 ro, float3 rd, float3 pa, float3 pb, float ra) {
  float4 ret = iCylinder_side(ro, rd, pa, pb, ra);
  float t = length(ret.yzw - ro);
  if (ret.x > 0.0 && t < t0) {
    float3 q = ret.yzw - pa;
    float angle = atan2(q.x, q.z);
    if (angle > -gCurvedAngle / 2 && angle < gCurvedAngle / 2){
      t0 = t;
      return float2(angle / gCurvedAngle + 0.5, (ret.yzw.y - pb.y) / (pa.y - pb.y) );
    }
  }

  float3 ro2 = ro + rd * 10;
  rd = -rd;
  ret = iCylinder_side(ro2, rd, pa, pb, ra);
  t = length(ret.yzw - ro);
  if (ret.x > 0.0 && t < t0) {
    float3 q = ret.yzw - pa;
    float angle = atan2(q.x, q.z);
    if (angle > -gCurvedAngle / 2 && angle < gCurvedAngle / 2){
      t0 = t;
      return float2(angle / gCurvedAngle + 0.5, (ret.yzw.y - pb.y) / (pa.y - pb.y) );
    }
  }
  return -1;
}

float iSphere(inout float t0, float3 ro, float3 rd, float3 sph, float rad) {
 	float3 oc = ro - sph;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - rad * rad;
  float t = b * b - c;
  if (t < 0) return -1;
  float r = -b - sqrt(t);
  if (r > t0) return -1;
  t0 = r;
  return r;
}

float3 quadIntersect(inout float t0, float3 ro, float3 rd, float3 v0, float3 v1, float3 v2, float3 v3, bool force = false) {
  // lets make v0 the origin
  float3 a = v1 - v0;
  float3 b = v3 - v0;
  float3 c = v2 - v0;
  float3 p = ro - v0;

  // intersect plane
  float3 nor = cross(a, b);
  float t = -dot(p, nor) / dot(rd, nor);
  if (t < 0.0 || t > t0) return -1;
  
  // intersection point
  float3 pos = p + t * rd;
    
  // select projection plane
  float3 mor = abs(nor);
  int id = (mor.x > mor.y && mor.x > mor.z) ? 0 : (mor.y > mor.z) ? 1 : 2;
  int idu = lut[id];
  int idv = lut[id + 1];
    
  // project to 2D
  float2 kp = float2(pos[idu], pos[idv]);
  float2 ka = float2(a[idu], a[idv]);
  float2 kb = float2(b[idu], b[idv]);
  float2 kc = float2(c[idu], c[idv]);
    
  // find barycentric coords of the quadrilateral
  float2 kg = kc - kb - ka;

  float k0 = cross2d(kp, kb);
  float k2 = cross2d(kc - kb, ka);
  float k1 = cross2d(kp, kg) - nor[id];
    
  // if edges are parallel, this is a linear equation
	float u, v;
  v = -k0 / k1;
  u = cross2d(kp, ka) / k1;
    
  if ((u < 0.0 || u > 1.0 || v < 0.0 || v > 1.0) && !force) return -1;    
  t0 = t;
  return float3(t, u, v);
}

float3 pattern(float2 uv) {
  if (uv.x == -1) return 0;
  float3 ret = txSource.SampleLevel(samLinearClamp, uv, 0).rgb;
  if (gHighlightMissingData && any(uv < 0 || uv > 1)){
    ret *= float3(1, 0.5, 0.5);
  }
  return ret;
}

float3 getOnscreenPos(float2 uv){
  #ifdef USE_SIDE_MONITORS
    if (uv.x < gFlatLeftShare){
      float3 p0 = lerp(gFlatLeft0, gFlatLeft1, uv.y);
      float3 p1 = lerp(gFlatLeft3, gFlatLeft2, uv.y);
      return lerp(p0, p1, uv.x / gFlatLeftShare);
    }
    if (uv.x > 1 - gFlatRightShare){
      float3 p0 = lerp(gFlatRight0, gFlatRight1, uv.y);
      float3 p1 = lerp(gFlatRight3, gFlatRight2, uv.y);
      return lerp(p1, p0, (1 - uv.x) / gFlatRightShare);
    }
    uv.x = (uv.x - gFlatLeftShare) * gFlatXMul;
  #endif

  float u = lerp(-gCurvedAngle / 2, gCurvedAngle / 2, uv.x);
  return gCurvedPos + float3(sin(u) * gCurvedRadius, (0.5 - uv.y) * gCurvedHeight, cos(u) * gCurvedRadius);
}

float2 reprojectCurved(float2 uv){
  float3 ro = gEyePos;
  float3 rd = normalize(getOnscreenPos(uv) - ro);
  float md = 1e9;

  #ifdef TRIPLE_MODE
    { float3 q = quadIntersect(md, ro, rd, gTripleCornerL0, gTripleCornerL1, gTripleCornerL2, gTripleCornerL3);
    if (q.x != -1){
      q.y = lerp(0, gTripleX0, q.y);
      return q.yz;
    } }
    { float3 q = quadIntersect(md, ro, rd, gTripleCornerR0, gTripleCornerR1, gTripleCornerR2, gTripleCornerR3);
    if (q.x != -1){
      q.y = lerp(gTripleX1, 1, q.y);
      return q.yz;
    } }
    { float3 q = quadIntersect(md, ro, rd, gTripleCornerC0, gTripleCornerC1, gTripleCornerC2, gTripleCornerC3, true);
    if (q.x != -1){
      q.y = lerp(gTripleX0, gTripleX1, q.y);
      return q.yz;
    } }
    return -1;
  #else
    return quadIntersect(md, ro, rd, gFlatCorner0, gFlatCorner1, gFlatCorner2, gFlatCorner3, true).yz;
  #endif
}

#ifdef DEBUG_VIEW
float2 iMonitorShape(inout float t0, float3 ro, float3 rd, out float highlight){
  const float3 capA = float3(0, -gCurvedHeight / 2, 0) + gCurvedPos;
  const float3 capB = float3(0, gCurvedHeight / 2, 0) + gCurvedPos;
  const float capR = gCurvedRadius;
  float2 ret = iCylinder(t0, ro, rd, capA, capB, capR);
  highlight = 1;
  #ifdef USE_SIDE_MONITORS
    highlight = gHoveredMiddle;
    ret.x = lerp(gFlatLeftShare, 1 - gFlatRightShare, ret.x);
    { float3 q = quadIntersect(t0, ro, rd, gFlatLeft0, gFlatLeft1, gFlatLeft2, gFlatLeft3); 
    if (q.x != -1) { ret = float2(lerp(0, gFlatLeftShare, q.y), q.z); highlight = gHoveredLeft; } }
    { float3 q = quadIntersect(t0, ro, rd, gFlatRight0, gFlatRight1, gFlatRight2, gFlatRight3); 
    if (q.x != -1) { ret = float2(lerp(1 - gFlatRightShare, 1, q.y), q.z); highlight = gHoveredRight; } }
  #endif
  return ret;
}

bool pointIsWithinMonitor(float3 pos){
  float maxDistance = 1e9;
  float highlight;
  return iMonitorShape(maxDistance, gEyePos, normalize(pos - gEyePos), highlight).y != -1;
}

void mainImage(out float4 fragColor, float2 fragCoord) {
  // camera movement	
	float an = gCamera.x;
  float2 xsc = float2(sin(gCamera.x), cos(gCamera.x));
  float2 ysc = float2(sin(gCamera.y), cos(gCamera.y));
  float dx = 1 - 0.8 * ysc.x;
  float dy = 0.8 * ysc.x;
	float3 ro = normalize(float3(xsc.y * dx, dy, xsc.x * dx)) * (3 + gCameraZoom * 1.5);
  float3 ta = float3(0, 0, 0.5);

  // camera matrix
  float3 ww = normalize(ta - ro);
  float3 uu = normalize(cross(ww, float3(0, 1, 0)));
  float3 vv = normalize(cross(uu, ww));
  float3 tot = 0;
    
  #if AA>1
  for (int m = 0; m < AA; m++)
  for (int n = 0; n < AA; n++) {
    // pixel coordinates
    float2 o = float2(float(m), float(n)) / float(AA) - 0.5;
    float2 p = (-iResolution.xy + 2 * (fragCoord + o)) / iResolution.y;
    #else    
    float2 p = (-iResolution.xy + 2 * fragCoord) / iResolution.y;
    #endif

    // create view ray
    float3 rd = normalize(p.x * uu + p.y * vv + 3.5 * ww);
    
    float3 col = 0.04 * (1 - 0.3 * length(p)) + 0.02 * rd.y;
    float maxDistance = 1e9;

    #ifdef TRIPLE_MODE
      float2 puv = -1;
      { float3 q = quadIntersect(maxDistance, ro, rd, gTripleCornerL0, gTripleCornerL1, gTripleCornerL2, gTripleCornerL3);
      if (q.x != -1){
        q.y = lerp(0, gTripleX0, q.y);
        puv = q.yz;
      } }
      { float3 q = quadIntersect(maxDistance, ro, rd, gTripleCornerC0, gTripleCornerC1, gTripleCornerC2, gTripleCornerC3);
      if (q.x != -1){
        q.y = lerp(gTripleX0, gTripleX1, q.y);
        puv = q.yz;
      } }
      { float3 q = quadIntersect(maxDistance, ro, rd, gTripleCornerR0, gTripleCornerR1, gTripleCornerR2, gTripleCornerR3);
      if (q.x != -1){
        q.y = lerp(gTripleX1, 1, q.y);
        puv = q.yz;
      } }
      if (puv.y != -1) {
        col = pattern(puv);
        if (!pointIsWithinMonitor(ro + rd * maxDistance)){
          col *= 0.4;
        }
        col *= float3(0.2, 0.9, 1);
      }
    #else
      float3 q = quadIntersect(maxDistance, ro, rd, gFlatCorner0, gFlatCorner1, gFlatCorner2, gFlatCorner3);
      if (q.x != -1){
        col = pattern(q.yz);
        if (!pointIsWithinMonitor(ro + rd * maxDistance)){
          col *= 0.4;
        }
        col *= float3(0.2, 0.9, 1);
      }
    #endif

    if (iSphere(maxDistance, ro, rd, gEyePos, 0.01) != -1){
      col = float3(1, 0, 0);
    }

    float highlight;
    float2 tnor = iMonitorShape(maxDistance, ro, rd, highlight);
    if (tnor.y != -1) {
      col = pattern(reprojectCurved(tnor)) * lerp(0.5, 1, highlight);
    }

    col = sqrt(col);	
    tot += col;
  #if AA>1
  }
  tot /= float(AA * AA);
  #endif

  // dither to remove banding in the background
  // tot += frac(sin(fragCoord.x * float3(13, 1, 11) + fragCoord.y * float3(1, 7, 5)) * 158.391832) / 255;
  fragColor = float4(tot, 1);
}
#endif

float4 main(PS_IN pin) {
  float4 ret;
  #ifdef DEBUG_VIEW
    mainImage(ret, (1 - pin.Tex) * iResolution);
    ret += pin.GetDithering();
  #else
    ret.rgb = pattern(reprojectCurved(pin.Tex));
    ret.w = 1;
  #endif
  return ret;
}
