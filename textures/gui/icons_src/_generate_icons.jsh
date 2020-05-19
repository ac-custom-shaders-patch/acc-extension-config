function tileSize(resolution){
  if (resolution < 40) return 16;
  if (resolution < 120) return 8;
  if (resolution < 500) return 4;
  return 2;
}

let groups = {
  'icons': 'ICON',
  'emoticons': 'SMILEY',
  'flags': 'FLAG',
};

function getTile(count){
  let side = Math.ceil(Math.sqrt(count));
  let ret = { x: side, y: side };
  ret.y -= Math.floor((side * side - count) / side);
  return ret;
}

async function run(params){
  let size = params.size;
  let icons = $.glob(`${params.group}_${size}/*.png`);
  let ret = [];
  let atlas_size = Math.pow(tileSize(+size), 2);
  for (let i = 0; i < icons.length; i += atlas_size) {
    let tile = getTile(icons.slice(i, i + atlas_size).length);
    let args = ['-background', 'none', '-tile', `${tile.x}x${tile.y}`, '-geometry', `${size - 2}x${size - 2}>+1+1`];
    [].push.apply(args, icons.slice(i, i + atlas_size));
    args.push(`${params.group}_${size}_${i / atlas_size}.png`);
    await $['D:/Applications/Cygwin/bin/magick.exe']['montage'].apply(null, args);
    if (params.group == 'icons'){
      await $['D:/Applications/Cygwin/bin/magick.exe'](`${params.group}_${size}_${i / atlas_size}.png`, 
        '-fill', '#ffffff', '-colorize', '100%', `../${params.group}_${size}_${i / atlas_size}.png`);
    } else {
      $.cp(`${params.group}_${size}_${i / atlas_size}.png`, `../${params.group}_${size}_${i / atlas_size}.png`);
    }
    await $['D:/Applications/Cygwin/bin/optipng.exe']('-o7', '-clobber', '-strip', 'all', `../${params.group}_${size}_${i / atlas_size}.png`);
    ret.push({ size: size, type: groups[params.group], icons: icons.slice(i, i + atlas_size), file: `${params.group}_${size}_${i / atlas_size}.png` });
  }
  return ret;
}

for (let f of Object.keys(groups).map(x => [$.glob(`${x}_*_*.png`), $.glob(`../${x}_*_*.png`)]).flat(Infinity)) {
  $.rm(f);
}

let icons = [];
await Object.keys(groups).map(x => $.glob(`${x}_*`)).flat()
  .map(x => /^(\w+)_(\d+)$/.test(x) ? { group: RegExp.$1, size: RegExp.$2 } : null).filter(x => x)
  .parallel(async x => {
    [].push.apply(icons, await run(x));
  }, 8);
icons.sort((x, y) => +x.size - +y.size);
// return;

function getUV(a, b){
  if (a == 0) return '0.f';
  if (a == b) return '1.f';
  if (b == 2 || b == 4) {
    let ret = `${a / b}`;
    return `${ret}${ret.indexOf('.') == -1 ? '.' : ''}f`;
  }
  return `${a}.f/${b}.f`;
}

function getType(icon){
  let p = path.dirname(icon).split('_')[0];
  return groups[p] || $.fail('Unknown group: ' + p);
}

function getName(icon){
  return path.basename(icon, '.png').replace(/-/g, '_').toUpperCase();
}

function getIconsLineH(item){
  function getIconLineH(icon, index){
    const res = path.dirname(icon);
    const type = getType(icon);
    const name = getName(icon);
    return `extern ImIcon ${type}_${res.split('_')[1]}_${name};`;
  }
  return item.icons.map(getIconLineH).join('\n    ');
}

function getIconsLineCpp(item){
  function getIconLineCpp(icon, index){
    const t = getTile(item.icons.length);
    const pos_x = index % t.x;
    const pos_y = (index / t.x) | 0;
    const res = path.dirname(icon);
    const type = getType(icon);
    const name = getName(icon);
    return `ImIcon ${type}_${res.split('_')[1]}_${name}{"textures/gui/${item.file}", `
      + `float2(${getUV(pos_x, t.x)}, ${getUV(pos_y, t.y)}), float2(${getUV(pos_x + 1, t.x)}, ${getUV(pos_y + 1, t.y)})};`;
  }
  return item.icons.map(getIconLineCpp).join('\n    ');
}

function getIconGetterH(name, type, useWideChar){
  return icons.filter(x => x.type == type).map(x => x.size).unique()
    .map(x => `utils::nullable<ImIcon> Get${name}${x}(const ${useWideChar ? 'std::wstring' : 'std::string'}& id);`).join('\n    ');
}

function getIconGetterCpp(name, type, useWideChar){
  return icons.filter(x => x.type == type).map(x => x.size).unique()
  .map(size => `utils::nullable<ImIcon> Get${name}${size}(const ${useWideChar ? 'std::wstring' : 'std::string'}& id)
    {
        ${icons.filter(x => x.size == size && x.type == type).map(x => x.icons).flat(1).map(y => {
          return `if (id == ${useWideChar ? 'L' : ''}${JSON.stringify(getName(y))}) return &${getType(y)}_${size}_${getName(y)};`
        }).join('\n        ')}
        return nullptr;
    }`).join('\n\n    ');
}

fs.writeFileSync(`C:/Development/acc-rendering-adv/source/imgui/icons.h`, `#pragma once
#include <math/vector_math.h>

namespace ImGui 
{
    using namespace math;

    struct ImIcon 
    {
        const char* filename;
        float2 uv0, uv1;
        bool loaded{};
        ID3D11ShaderResourceView* view{};

        ImIcon(const char* filename, float2 uv0, float2 uv1)
            : filename(filename), uv0(uv0), uv1(uv1)
        {}

        ID3D11ShaderResourceView* get();
    };

    ${icons.map(getIconsLineH).join('\n    ')}
    ${getIconGetterH('Icon', 'ICON', false)}
    ${getIconGetterH('Flag', 'FLAG', true)}
}`);

fs.writeFileSync(`C:/Development/acc-rendering-adv/source/imgui/icons.cpp`, `#include "stdafx.h"
#include "icons.h"

#include <hooks/ac_hooks.h>
#include <settings/custom_textures.h>
#include <ac_classes/KGLTexture.h>

namespace ImGui 
{
    ID3D11ShaderResourceView* ImIcon::get()
    {
        if (!loaded)
        {
            loaded = true;
            const auto tex = hooks::ac_hooks_instance->get_custom_textures()->load_texture(
                utils::get_special_folder_path(utils::special_folder::ac_ext) / filename);
            view = tex ? tex->view : nullptr;
        }
        return view;
    }

    ${icons.map(getIconsLineCpp).join('\n    ')}

    ${getIconGetterCpp('Icon', 'ICON', false)}

    ${getIconGetterCpp('Flag', 'FLAG', true)}
}`);