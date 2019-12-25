

function saturate(v)
  if v > 1 then return 1 end
  if v < 0 then return 0 end
  return v
end

function clamp(v, min, max)
  if v > max then return max end
  if v < min then return min end
  return v
end
