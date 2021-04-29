local yield = coroutine.yield

return {
  function ()
    Rocket:new{ }:chain(Twirl, { color = ColorGeneric })
    yield(1.5)
  end
}