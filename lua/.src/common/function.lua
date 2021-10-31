-- Extensions for functions

-- (function (arg1, arg2) end):bind(value for arg1, value for arg2)
-- this way calls should be faster than merging tables on-fly
debug.setmetatable(function()end, {
  __index = {
      bind = function(self, ...)
        local a = {...}
        if #a == 1 then return function(...) return self(a[1], ...) end end
        if #a == 2 then return function(...) return self(a[1], a[2], ...) end end
        if #a == 3 then return function(...) return self(a[1], a[2], a[3], ...) end end
        if #a == 4 then return function(...) return self(a[1], a[2], a[3], a[4], ...) end end
        if #a == 5 then return function(...) return self(a[1], a[2], a[3], a[4], a[5], ...) end end
        error('Not supported')
      end,
  },
})

