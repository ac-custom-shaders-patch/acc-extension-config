if io ~= nil then
  function io.exists(filename)
    local f = io.open(filename, 'rb')
    return f ~= nil and io.close(f)
  end

  function io.load(filename, fallback)
    local file = io.open(filename, 'rb')
    if file then
      local content = file:read '*a'
      file:close()
      return content
    end
    return fallback
  end

  function io.save(filename, data)
    local file, err = io.open(filename, 'wb')
    if file then
      file:write(data)
      file:close()
    else
      error('Failed to save: ' .. err)
    end
  end
end
