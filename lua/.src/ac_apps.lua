__source 'extensions/lua_tools/ac_ext_lua_tools.cpp'
__allow 'luatools'

require './common/ac_audio'
require './common/ac_light'
require './common/ac_render'
require './common/ac_ray'
require './common/ac_positioning_helper'
require './common/ac_ui'
require './common/ac_apps'
require './common/ac_storage'
require './common/ac_scene'
require './common/ac_web'

function ui.drawVirtualMirror(pos, size, color)
  ui.drawImage('dynamic::mirror', pos, size, color, vec2(1, 0), vec2(0, 1))
end

-- automatically generated entries go here:
__definitions()

