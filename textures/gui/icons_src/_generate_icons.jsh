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
  let atlasSize = Math.pow(tileSize(+size), 2);
  for (let i = 0; i < icons.length; i += atlasSize) {
    let tile = getTile(icons.slice(i, i + atlasSize).length);
    let fill = params.group == 'flags' && size == 64;
    let args = ['-background', 'none', '-tile', `${tile.x}x${tile.y}`, '-geometry', `${size - 2}x${size - 2}${fill ? '^' : '>'}+1+1`];
    [].push.apply(args, icons.slice(i, i + atlasSize));
    args.push(`${params.group}_${size}_${i / atlasSize}.png`);
    await $['D:/Applications/Cygwin/bin/magick.exe']['montage'].apply(null, args);
    if (params.group == 'icons'){
      await $['D:/Applications/Cygwin/bin/magick.exe'](`${params.group}_${size}_${i / atlasSize}.png`, 
        '-fill', '#ffffff', '-colorize', '100%', `../${params.group}_${size}_${i / atlasSize}.png`);
    } else {
      $.cp(`${params.group}_${size}_${i / atlasSize}.png`, `../${params.group}_${size}_${i / atlasSize}.png`);
    }
    await $['D:/Applications/Cygwin/bin/optipng.exe']('-o7', '-clobber', '-strip', 'all', `../${params.group}_${size}_${i / atlasSize}.png`);
    ret.push({ size: size, type: groups[params.group], icons: icons.slice(i, i + atlasSize), file: `${params.group}_${size}_${i / atlasSize}.png` });
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

function useWideChar(type){
  return type == 'FLAG';
}

function useVariables(type){
  return type == 'ICON';
}

function useLowerCase(type){
  return type == 'SMILEY';
}

function getMapType(type){
  return type == 'ICON' || type == 'SMILEY' ? 'std::map' : 'std::unordered_map';
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

function getIconsLineCpp(items){
  let iconsData = items.map(item => item.icons.map((icon, index) => ({
    file: item.file,
    tile: getTile(item.icons.length),
    posX: index % getTile(item.icons.length).x,
    posY: (index / getTile(item.icons.length).x) | 0,
    res: path.dirname(icon).split('_')[1],
    type: getType(icon),
    name: getName(icon)
  }))).flat(1);
  let type = iconsData[0].type;
  let strType = useWideChar(type) ? 'std::wstring' : 'std::string';

  function getIconLineCpp(icon, index){
    return `ImIcon ${icon.type}_${icon.res}_${icon.name}{"textures/gui/${icon.file}", `
      + `float2(${getUV(icon.posX, icon.tile.x)}, ${getUV(icon.posY, icon.tile.y)}), float2(${getUV(icon.posX + 1, icon.tile.x)}, ${getUV(icon.posY + 1, icon.tile.y)})};`;
  }

  if (useVariables(type)){
  return iconsData.map(getIconLineCpp).join('\n    ') + `\n    static ${getMapType(type)}<${strType}, ImIcon*> ${type.toLowerCase()}s_${iconsData[0].res} = {
        ${iconsData.map(icon => `{ ${useWideChar(type) ? 'L' : ''}${JSON.stringify(useLowerCase(type) ? icon.name.toLowerCase() : icon.name)}, &${icon.type}_${icon.res}_${icon.name} }`).join(',\n        ')}
    };\n`;
  } else {
    return `static ${getMapType(type)}<${strType}, ImIcon*> ${type.toLowerCase()}s_${iconsData[0].res} = {
          ${iconsData.map(icon => `{ ${useWideChar(type) ? 'L' : ''}${JSON.stringify(useLowerCase(type) ? icon.name.toLowerCase() : icon.name)}, new ImIcon{"textures/gui/${icon.file}", `
          + `float2(${getUV(icon.posX, icon.tile.x)}, ${getUV(icon.posY, icon.tile.y)}), float2(${getUV(icon.posX + 1, icon.tile.x)}, ${getUV(icon.posY + 1, icon.tile.y)})} }`).join(',\n        ')}
    };\n`;
  }
}

function getIconGetterH(name, type){
  return icons.filter(x => x.type == type).map(x => x.size).unique()
    .map(x => `utils::nullable<ImIcon> Get${name}${x}(const ${useWideChar(type) ? 'std::wstring' : 'std::string'}& id);`).join('\n    ');
}

function getIconsGetterH(name, type){
  return icons.filter(x => x.type == type).map(x => x.size).unique()
    .map(x => `const ${getMapType(type)}<${useWideChar(type) ? 'std::wstring' : 'std::string'}, ImIcon*>& Get${name}s${x}();`).join('\n    ');
}

function getIconGetterCpp(name, type){
  return icons.filter(x => x.type == type).map(x => x.size).unique()
  .map(size => `utils::nullable<ImIcon> Get${name}${size}(const ${useWideChar(type) ? 'std::wstring' : 'std::string'}& id)
    {
        const auto f = ${type.toLowerCase()}s_${size}.find(id);
        return f != ${type.toLowerCase()}s_${size}.end() ? f->second : nullptr;
    }`).join('\n\n    ') + '\n    ';
}

function getIconsGetterCpp(name, type){
  return icons.filter(x => x.type == type).map(x => x.size).unique()
  .map(size => {
    let list = icons.filter(x => x.size == size && x.type == type).map(x => x.icons).flat(1);
    return `const ${getMapType(type)}<${useWideChar(type) ? 'std::wstring' : 'std::string'}, ImIcon*>& Get${name}s${size}() { return ${type.toLowerCase()}s_${size}; }`}).join('\n    ');
}

fs.writeFileSync(`C:/Development/acc-rendering-adv/source/imgui/icons.h`, `#pragma once
#include <math/vector_math.h>

namespace ImGui 
{
    using namespace math;

    struct ImIcon
    {
        const char* filename{};
        float2 uv0, uv1;
        bool loaded{};
        ID3D11ShaderResourceView* view{};
  
        ImIcon(ID3D11ShaderResourceView* view) : uv0(0.f), uv1(1.f), loaded(true), view(view) {}
        ImIcon(const char* filename, float2 uv0, float2 uv1) : filename(filename), uv0(uv0), uv1(uv1) {}
        ID3D11ShaderResourceView* get();
  
        ImIcon* ptr() { return this; }
    };

    ${icons.filter(x => x.type == 'ICON').map(getIconsLineH).join('\n    ')}
    ${getIconGetterH('Icon', 'ICON')}
    ${getIconGetterH('Smiley', 'SMILEY')}
    ${getIconGetterH('Flag', 'FLAG')}
    ${getIconsGetterH('Icon', 'ICON')}
    ${getIconsGetterH('Smiley', 'SMILEY')}
    ${getIconsGetterH('Flag', 'FLAG')}
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
                get_special_folder_path(utils::special_folder::ac_ext) / filename);
            view = tex ? tex->view : nullptr;
        }
        return view;
    }

    ${Object.values(icons.filter(x => x.type == 'ICON').groupBy(x => x.size)).map(getIconsLineCpp).join('\n    ')}
    ${Object.values(icons.filter(x => x.type == 'SMILEY').groupBy(x => x.size)).map(getIconsLineCpp).join('\n    ')}
    ${Object.values(icons.filter(x => x.type == 'FLAG').groupBy(x => x.size)).map(getIconsLineCpp).join('\n    ')}
    ${getIconGetterCpp('Icon', 'ICON')}  
    ${getIconGetterCpp('Smiley', 'SMILEY')}
    ${getIconGetterCpp('Flag', 'FLAG')}  
    ${getIconsGetterCpp('Icon', 'ICON')}
    ${getIconsGetterCpp('Smiley', 'SMILEY')}
    ${getIconsGetterCpp('Flag', 'FLAG')}
}`);