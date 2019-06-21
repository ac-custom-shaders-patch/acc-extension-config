function ParseColor(v)
  if type(v) == "string" and v:sub(1, 1) == "#" then 
    if #v == 7 then 
      return { tonumber(v:sub(2, 3), 16) / 255, tonumber(v:sub(4, 5), 16) / 255, tonumber(v:sub(6, 7), 16) / 255 } 
    end
    if #v == 4 then 
      return { tonumber(v:sub(2, 2), 16) / 15, tonumber(v:sub(3, 3), 16) / 15, tonumber(v:sub(4, 4), 16) / 15 } 
    end
    error("Invalid color: "..v)
  end
  if type(v) == "table" and #v == 3 and ( v[1] > 1 or v[2] > 1 or v[3] > 1 ) then 
    return { v[1] / 255, v[2] / 255, v[3] / 255 } 
  end
  return v
end

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
