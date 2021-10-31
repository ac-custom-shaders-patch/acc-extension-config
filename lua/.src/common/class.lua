--[[

Custom class() implementation set to run with as little overhead as possible. Works similar to middleclass, but there are 
few differences. Feel free to use its docs (https://github.com/kikito/middleclass), but don’t forget to check the list of differences below.

Usage:

  local MyClass = class('MyClass')

  function MyClass:initialize(arg1, arg2)
    -- constructor
    self.myField = arg1 + arg2
  end

  function MyClass:doMyThing()
    print(self.myField)
  end

  local instance = MyClass(1, 2)
  instance:doMyThing()

For better performance, a custom allocate method could be used instead of “:initialize()”, gives about 15% increase in speed
when creating an object with two fields:

  function MyClass.allocate(arg1, arg2)  -- notice . instead of :
    return { myField = arg1 + arg2 }     -- also notice, methods are not available at this stage
  end

Key differences comparing to middleclass:

  1. Class name is stored in class.__className instead of class.name

  2. There is no .static subobject, all static fields and methods are instead stored in main class
    table and thus are available as instance fields and methods as well (that’s why class.name was
    renamed to class.__className, to avoid possible confusion with a common field name). Personally,
    I find idea of .static to sort of go against common agreements.

  3. Overloading __tostring and __call works well, including inheritance. For some reason it’s impossible
    to overload __len though, and the rest of operators wouldn’t get inherited. Not sure if I’d recommend
    to mix inheritance and operators overloading to begin with.

  4. Method “allocate()” works differently here and is used to create a simple table which will be 
    passed to “setmetatable()”. Using it allows to get better performance in case objects would be created
    often.

Everything else should work the same, including inheritance and mixins. As for performance, some simple
tests show 30% faster objects creation with 70% less garbage for GC to clean up.

]]

return function (name, super)
  if type(name) ~= 'string' then error('Name of a class should be a string') end
  local classTable
  classTable = setmetatable({
    __className = name,
    super = super,
    allocate = function() return {} end,
    new = function (_, ...) return _ == classTable and classTable(...) or classTable(_, ...) end,
    subclass = function (self, name) return self == classTable and class(self, name) or class(classTable, self) end,
    isSubclassOf = function (self, parent)
      while self ~= nil do
        local mt = getmetatable(self)
        self = mt and mt.__index
        if self == (parent or classTable) then return true end
      end
      return false
    end,
    isInstanceOf = function (self, parent) return self ~= nil and (self.__index == (parent or classTable) or self.__index:isSubclassOf(parent or classTable)) end,
    include = function (self, mixin)
      if self ~= classTable then self, mixin = classTable, self end
      for key, value in pairs(mixin) do
        if key == 'included' then value(self) else self[key] = value end
      end
      return self
    end,
    __tostring = super ~= nil and super.__tostring or function (self) return 'instance of class '..self.__index.__className end,
    __call = super and super.__call
  }, {
    __call = function(self, ...)
      local newInstance = setmetatable(self.allocate(...), self)
      if newInstance.initialize ~= nil then newInstance:initialize(...) end
      return newInstance
    end,
    __index = super,
    __tostring = function (self) return 'class '..self.__className end
  })
  classTable.__index = classTable
  classTable.class = classTable
  if super ~= nil and super.subclassed ~= nil then super.subclassed(classTable) end
  return classTable
end
