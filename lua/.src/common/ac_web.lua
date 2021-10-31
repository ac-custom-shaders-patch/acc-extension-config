__source 'lua/api_web.cpp'
__namespace 'web'

local function encodeHeaders(headers)
  if headers == nil then return nil end
  local ret = nil
  for key, value in pairs(headers) do
    ret = (ret ~= nil and ret..'\n' or '')..key..'='..value
  end
  return ret
end

local function parseHeaders(headers)
  local ret = {}
  for k, v in string.gmatch(headers, "([%a%d%-]+): ([%g ]+)\r\n") do
    ret[k:lower()] = v
  end
  return ret
end

local function requestCallback(callback)
  if callback == nil then return 0 end
  return __util.expectReply(function (err, status, headers, response)
    callback(err, { status = status, headers = parseHeaders(headers), body = response })
  end)
end

local function request(method, url, headers, data, callback)
  if url == nil then error('URL is required') end
  if ffi.C.lj_http_request__web(__util.str(method), __util.str(url), encodeHeaders(headers), 
      data ~= nil and tostring(data) or nil, requestCallback(callback)) == false then
    error('Invalid arguments')
  end
end

web = {}

web.get = function(url, headers, callback)
  if type(headers) == 'function' then headers, callback = nil, headers end -- get(url, callback)
  request('GET', url, headers, nil, callback)
end

web.post = function(url, headers, data, callback)
  if type(headers) == 'function' then headers, data, callback = nil, nil, headers -- post(url, callback)
  elseif type(headers) == 'string' then headers, data, callback = nil, headers, data -- post(url, data, callback)
  elseif type(data) == 'function' then data, callback = nil, data end -- post(url, headers, callback)
  request('POST', url, headers, data, callback)
end
