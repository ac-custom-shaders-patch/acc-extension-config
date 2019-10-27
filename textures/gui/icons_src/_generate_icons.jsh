async function run(size){
  let icons = $.glob(`icons_${size}/*.png`);
  let args = ['-background', 'none', '-geometry', `${size - 2}x${size - 2}>+1+1`];
  [].push.apply(args, icons);
  args.push(`icons_${size}.png`);
  await $['D:/Applications/Cygwin/bin/magick.exe']['montage'].apply(null, args);
  await $['D:/Applications/Cygwin/bin/magick.exe'](`icons_${size}.png`, 
    '-fill', '#ffffff', '-colorize', '100%', `../icons_${size}.png`);
  await $['D:/Applications/Cygwin/bin/optipng.exe']('-o7', '-clobber', '-strip', 'all', `../icons_${size}.png`);
  return { size: size, icons: icons };
}

let icons = [];
for (let size of $.glob(`icons_*`).map(x => /_(\d+)$/.test(x) ? RegExp.$1 : null).filter(x => x)){
  icons.push(await run(size));
}

const tile = {
  '1': { x: 1, y: 1 },
  '2': { x: 2, y: 1 },
  '3': { x: 3, y: 1 },
  '4': { x: 2, y: 2 },
  '5': { x: 3, y: 2 },
  '6': { x: 3, y: 2 },
  '7': { x: 4, y: 2 },
  '8': { x: 4, y: 2 },
  '9': { x: 3, y: 3 },
  '10': { x: 4, y: 3 },
  '11': { x: 4, y: 3 },
  '12': { x: 4, y: 3 },
  '13': { x: 5, y: 3 },
  '14': { x: 5, y: 3 },
  '15': { x: 5, y: 3 },
  '16': { x: 5, y: 4 },
  '17': { x: 5, y: 4 },
  '18': { x: 5, y: 4 },
  '19': { x: 5, y: 4 },
  '20': { x: 5, y: 4 },
  '21': { x: 6, y: 4 },
  '22': { x: 6, y: 4 },
  '23': { x: 6, y: 4 },
  '21': { x: 6, y: 4 },
  '25': { x: 5, y: 5 },
  '26': { x: 6, y: 5 },
  '27': { x: 6, y: 5 },
  '28': { x: 6, y: 5 },
  '29': { x: 6, y: 5 },
  '30': { x: 6, y: 5 },
  '31': { x: 7, y: 5 },
  '32': { x: 7, y: 5 },
  '33': { x: 7, y: 5 },
  '34': { x: 7, y: 5 },
  '35': { x: 7, y: 5 },
  '36': { x: 6, y: 6 },
  '37': { x: 7, y: 6 },
  '38': { x: 7, y: 6 },
  '39': { x: 7, y: 6 },
  '40': { x: 7, y: 6 },
  '41': { x: 7, y: 6 },
  '42': { x: 7, y: 6 },
  '43': { x: 8, y: 6 },
  '44': { x: 8, y: 6 },
  '45': { x: 8, y: 6 },
  '46': { x: 8, y: 6 },
  '47': { x: 8, y: 6 },
  '48': { x: 8, y: 6 },
};

function getUV(a, b){
  if (a == 0) return '0.f';
  if (a == b) return '1.f';
  if (b == 2 || b == 4) {
    let ret = `${a / b}`;
    return `${ret}${ret.indexOf('.') == -1 ? '.' : ''}f`;
  }
  return `${a}.f/${b}.f`;
}

function getIconsLineH(item){
  function getIconLineH(icon, index){
    const name = path.basename(icon, '.png');
    const res = path.dirname(icon);
    return `extern ImIcon ICON_${res.split('_')[1]}_${name.toUpperCase()};`;
  }
  return item.icons.map(getIconLineH).join('\n    ');
}

function getIconsLineCpp(item){
  function getIconLineCpp(icon, index){
    const t = tile[item.icons.length];
    const pos_x = index % t.x;
    const pos_y = (index / t.x) | 0;
    const name = path.basename(icon, '.png');
    const res = path.dirname(icon);
    return `ImIcon ICON_${res.split('_')[1]}_${name.toUpperCase()}{"textures/gui/${res}.png", `
      + `float2(${getUV(pos_x, t.x)}, ${getUV(pos_y, t.y)}), float2(${getUV(pos_x + 1, t.x)}, ${getUV(pos_y + 1, t.y)})};`;
  }
  return item.icons.map(getIconLineCpp).join('\n    ');
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
}`);

fs.writeFileSync(`C:/Development/acc-rendering-adv/source/imgui/icons.cpp`, `#include "stdafx.h"
#include "icons.h"

#include <hooks/ac_hooks.h>

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
}`);