#!node -r shelljs-wrap

// Options
var minifyFfiDefinitions = true;

// Rules
function notForExport(t){
  if (/^(lj_memmove|lj_malloc|lj_calloc|lj_realloc|lj_free)$/.test(t)) return true;
  if (/lj_[^_]+_[^_]/.test(t)) return true;
  // if (/getTrackCoordinates/.test(t)) return true;
  return false;
}

function typeToLua(t){
  t = t.replace(/\bcolor_correction_/g, 'cc_');
  t = t.replace(/\blua_audio_event\b/g, 'audioevent');
  t = t.replace(/\b\w+_array\b/g, 'void');
  t = t.replace(/\bfloat(\d)\b/g, 'vec$1');
  t = t.replace(/\buint\b/g, 'uint32_t');
  t = t.replace(/\b(utils::)?special_folder\b/g, 'int');
  t = t.replace(/\bweather_type\b/g, 'char');
  t = t.replace(/\bgeo_coords\b/g, 'vec2');
  t = t.replace(/\bdx_perlinworley::pw_settings\b/g, 'cloud_map_settings');
  return t;
}

function defaultValueToLua(t){
  if (!t) return null;
  return t.replace(/[{}]/g, _ => _ == '{' ? '(' : ')').replace(/\d\.?f\b/g, _ => _[0]);
}

const isVectorType = (() => {
  function createType(type){
    function poolName(arg, localDefines){
      const typeIndex = `__tmp_${type}${arg.allArgs.filter(x => x.typeInfo.name == arg.typeInfo.name && x.index < arg.index).length}`;
      if (!localDefines[typeIndex]) localDefines[typeIndex] = { key: typeIndex, value: `${type}()` };
      return typeIndex;
    }

    return {
      createNew: (arg, localDefines) => `${arg.name} = __util.cast_${type}(${poolName(arg, localDefines)}, ${arg.name})`
    };
  }

  const vectorTypes = {
    vec2: createType('vec2'),
    vec3: createType('vec3'),
    vec4: createType('vec4'),
    rgb: createType('rgb'),
    rgbm: createType('rgbm'),
  };

  return type => vectorTypes[type];
})();

function getTypeInfo(type, customTypes){
  if (type === 'const char*') return { name: 'string', default: '""', prepare: arg => `${arg.name} = tostring(${arg.name})` };
  if (type === 'float' || type === 'int' || type === 'uint') return { name: 'number', default: null, prepare: arg => `${arg.name} = tonumber(${arg.name}) or ${arg.default || 0}` };
  if (type === 'bool') return { name: 'boolean', default: null, prepare: arg => `${arg.name} = ${arg.name} and true or false` };
  if (type === 'special_folder') return { name: 'ac.FolderId', default: 0, prepare: arg => `${arg.name} = tonumber(${arg.name}) or 0` };

  const luaType = typeToLua(/([\w:]+)[*&]?$/.test(type) ? RegExp.$1 : type);
  const vectorType = isVectorType(luaType);
  if (vectorType != null) {
    return { 
      name: luaType, 
      default: `${luaType}()`, 
      prepare: (arg, localDefines) => `if ffi.istype('${luaType}', ${arg.name}) == false then ${vectorType.createNew(arg, localDefines)} end` 
    };
  }

  const valueRequired = !/\*$/.test(type);
  const customType = customTypes[luaType];
  if (customType != null) {
    return { 
      name: customType, 
      default: valueRequired ? null : 'nil', 
      prepare: arg => valueRequired 
        ? `if ffi.istype('${luaType}', ${arg.name}) == false then 
          if ${arg.name} == nil then error("Required argument '${arg.niceName}' is missing") end 
          error("Argument '${arg.niceName}' requires a value of type ${customType}") 
        end` 
        : `if ffi.istype('${luaType}', ${arg.name}) == false then 
          error("Argument '${arg.niceName}' requires a value of type ${customType}") 
        end` 
    };
  }

  const knownType = /^state_/.test(luaType);
  return { 
    name: knownType ? toNiceName(luaType) : '?', 
    default: valueRequired ? null : 'nil', 
    prepare: arg => { $.echo(β.red(`Prepare function is missing for ${type}`)); return '' } 
  };
}

function prepareParam(arg, wrapDefault, localDefines){
  if (arg.typeInfo.default == null){
    return arg.typeInfo.prepare(arg, localDefines);
  }

  return `if ${arg.name} ~= nil then 
    ${arg.typeInfo.prepare(arg, localDefines)} 
  else
    ${arg.name} = ${wrapDefault(arg.default || arg.typeInfo.default)} 
  end`;
}

function toNiceName(name){
  return name.replace(/_([a-z])/, (_, a) => a.toUpperCase());
}

function wrapParamDefinition(arg){
  if (arg.typeInfo.name === '?') $.echo(β.yellow(`Unknown type: ${arg.type}`)); 
  return arg.default ? `${arg.niceName}: ${arg.typeInfo.name} = ${arg.default}` : `${arg.niceName}: ${arg.typeInfo.name}`;
}

function wrapReturnDefinition(arg, customTypes){
  if (arg === 'void') return '';
  return `: ${getTypeInfo(arg, customTypes).name}`;
}

function needsWrappedResult(type){
  if (/const char\*/.test(type)) return true;
  return false;
}

function wrapResult(type){
  if (type == 'void') return x => x;
  if (/const char\*/.test(type)) return x => `return ffi.string(${x})`;
  return x => `return ${x}`;
}

function extendArg(arg, fnName, allArgs, customTypes){
  arg.niceName = toNiceName(arg.name);
  arg.typeInfo = getTypeInfo(arg.type, customTypes);
  arg.allArgs = allArgs;
}

// Code
const parser = require('./utils/luaparse');
const luamax = require('./utils/luamax');

const defBr = { '[': ']', '{': '}', '(': ')', '<': '>' };
const baseBr = { '(': ')' };
const cspSource = `${process.env['CSP_ROOT']}/source`;

function brackets(s, reg, br, cb){
  for (var i, r = '', m, o, f, b = br || defBr; m = reg.exec(s); s = s.substr(i + 1)){
    r += s.substr(0, m.index);
    for (i = m.index + m[0].length, o = []; i < s.length; i++){
      if (b.hasOwnProperty(s[i])) { if (!o.length) f = i; o.push(b[s[i]]); continue; }
      else if (s[i] == o[0] && (o.shift(), !o.length)) r += cb(m, s.substring(f + 1, i));
      else if (o.length == 0 && s[i] != ' ' && s[i] != '\t' && s[i] != '\n' && s[i] != '\r') {
        r += cb(m, '');
        i = m.index + m[0].length - 1;
      }
      else continue; 
      break;
    }
  }
  return r + s;
}

function split(s, sep, br){
  for (var r = [], o = [], l = 0, b = br || defBr, i = 0; i < s.length; i++){
    if (b.hasOwnProperty(s[i])) o.push(b[s[i]]);
    else if (s[i] == o[0]) o.shift();
    else if (o.length == 0 && s[i] == sep) { r.push(s.substring(l, i)); l = i + 1; }
  }
  return r.concat(s.substring(l));
}

const processMacros = (src => {
  // list of macroses:
  let ms = [];

  // parse all defines into a neat list of functions
  $.readText(src).replace(
    /\n#define (\w+)\(((?:\w+|\.\.\.)(?:,\s*(?:\w+|\.\.\.))*)\)\s*((.+|(?!\n#define)[\s\S])+)/g, 
    (_, n, a, b) => {
      // if (n == 'LUAGETSET') return;
      const args = a.split(',').map(x => x.trim().replace('...', '')).map(x => [
        eval('/(##?|\\b)' + (x || '__VA_ARGS__') + '(##|\\b)/g'),
        i => ((r, v) => v[0] == '#' && v[1] != '#' ? JSON.stringify(r) : r).bind(0, x ? i.shift() : i.join(', '))
      ]).map(a => (x, i) => x.replace(a[0], a[1](i)));
      ms.push(s => brackets(s, eval('/\\b' + n + '\\b/'), baseBr, 
        (_, a) => args.reduce(((i, a, b) => b(a, i)).bind(0, split(a, ',').map(x => x.trim())), b.replace(/\\\n/g, '\n'))));
    });

  // flipping list
  ms = ms.concat(x => x.replace(/\/\/.+/g, '').replace(/\n\s*(?=\n)/g, '')).reverse();

  // returning function reading file and returning it processed
  return x => ms.reduce((a, b) => b(a), x);
})(`${cspSource}/lua/api_macro.h`);

function getLuaCode(filenames, stateDestination, mode, base, definitionsCallback){
  const ffiDefinitions = [];
  const ffiStructures = [];
  const localDefines = {};
  const exportEntries = [];
  const docDefinitions = [];
  
  const customTypes = {};
  base.replace(/(?<=\n)require '\.\/(?!deps\/)(.+)'/g, (_, name) => {
    $.readText(`${name}.lua`).replace(/(\bac\.\w+)\s*=\s*ffi\.metatype\('(\w+)'/g, (_, lua, c) => customTypes[c] = lua);
  });

  const data = filenames.map(x => $.readText(x)).join('\n\n').replace(/,\s*\r?\n\s*/g, ', ');
  const prepared = processMacros(data);

  function splitArgs(name, args){
    let defaultMap = {};
    args = args.replace(/\(.+?\)|\{.+?\}/g, _ => {
      const key = Math.random().toString(32).substr(2);
      defaultMap[key] = _;
      return key;
    });
    const unwrap = x => {
      for (let k in defaultMap){
        x = x.replace(k, defaultMap[k]);
      }
      return x;
    };

    const ret = args.split(',')
      .map((x, i) => /^([^=]+)\s+(\w+)(?:\s*=\s*(.+))?$/.test(x) ? { index: i, type: RegExp.$1.trim(), name: RegExp.$2, default: defaultValueToLua(unwrap(RegExp.$3.trim())) } : null)
      .filter(x => x);
    ret.forEach(x => extendArg(x, name, ret, customTypes));
    return ret;
  }

  function wrapDefault(value){
    if (/\(/.test(value)){
      const i = localDefines[value];
      return i ? i.key : (localDefines[value] = { key: `__def_${value.replace(/\W+/g, '')}`, value }).key;
    }
    return value;
  }
  
  prepared.replace(/\bLUAEXPORT\s+((?:const\s+)?\w+\*?)\s+(lj_\w+)\s*\((.*)/g, (_, resultType, name, argsLine) => {
    if (/__(\w+)$/.test(name) && RegExp.$1 != mode) return;

    const args = splitArgs(name, argsLine.split(/\)\s*(\{|$)/)[0].trim());
    ffiDefinitions.push(`${typeToLua(resultType)} ${name}(${args.map(x => `${typeToLua(x.type)} ${x.name}`).join(', ')});`);
    if (notForExport(name)) return;

    const cleanName = name.replace(/^lj_|__\w+$/g, '');
    if (args.length > 0 || needsWrappedResult(resultType)){
      exportEntries.push(`ac.${cleanName} = function(${args.map(x => x.name).join(', ')}) 
        ${args.map(x => prepareParam(x, wrapDefault, localDefines)).join(' ')} 
        ${wrapResult(resultType)(`ffi.C.${name}(${args.map(x => x.name).join(', ')})`)} 
      end`);
      docDefinitions.push(`ac.${cleanName}(${args.map(x => wrapParamDefinition(x)).join(', ')})${wrapReturnDefinition(resultType, customTypes)}`);
    } else {
      exportEntries.push(`ac.${cleanName} = ffi.C.${name}`);
      docDefinitions.push(`ac.${cleanName}()${wrapReturnDefinition(resultType, customTypes)}`);
    }
  });

  if (stateDestination) {
    stateExtras = '';
    data.replace(/\bLUASTRUCT\s+(\w+)([\s\S]+?)\n(?:\t| {4})\};/g, (_, name, content) => {
      const fields = [];
      const cppStatic = [];
      const cppUpdate = [];
      content.replace(/\bLUA(\w+)\((.+)/g, (_, keys, data) => {
        let comment = '';
        if (/^(.+)\/\/\s*(.+)$/.test(data)){
          data = RegExp.$1;
          comment = ' // ' + RegExp.$2;
        }

        const isStatic = /STATIC/.test(keys);
        const isArray = /ARRAY/.test(keys);
        let match = data.trim().match(isArray ? /(\w+), (\d+), (\w+), (.+)\)$/ : /(\w+), (\w+), (.+)\)$/);
        if (!match && !isArray) match = data.trim().match(/(\w+), (\w+), \[&]\{$/);
        if (!match) $.fail(`Failed to match field data: “${data}”`);

        fields.push(isArray ? `${match[1]} ${match[3]}[${match[2]}];${comment}` : `${match[1]} ${match[2]};${comment}`);
        (isStatic ? cppStatic : cppUpdate).push(`${match[isArray ? 3 : 2]}_set(c);`);
      });

      docDefinitions.push(`\nstruct ${toNiceName(name)} {\n\t${fields.join('\n\t')}\n}`);
      ffiStructures.push(`typedef struct {\n\t${fields.join('\n\t')}\n} ${name};`);

      if (/void init\((.*?)\)/.test(content)){
        const args = RegExp.$1 ? RegExp.$1.split(',').map(x => x.trim()) : [];
        const argNames = args.map(x => x.split(' ')[1]);
        stateExtras += `\n\tvoid ${name}::init(${args})\n\t{\n\t\tconst init_ctx c{${argNames}};\n\t\t${cppStatic.join('\n\t\t')}\n\t}\n`
      }

      if (/void update\((.*?)\)/.test(content)){
        const args = RegExp.$1 ? RegExp.$1.split(',').map(x => x.trim()) : [];
        const argNames = args.map(x => x.split(' ')[1]);
        if (cppStatic.length > 0){
          stateExtras += `\n\tvoid ${name}::update(${args})\n\t{\n\t\tif (needs_initialization()) init(${argNames});\n\t\tconst ctx c{${argNames}};\n\t\t${cppUpdate.join('\n\t\t')}\n\t}\n`
        } else {
          stateExtras += `\n\tvoid ${name}::update(${args})\n\t{\n\t\tconst ctx c{${argNames}};\n\t\t${cppUpdate.join('\n\t\t')}\n\t}\n`
        }
      }
    });

    if (stateExtras){
      fs.writeFileSync(stateDestination, $.readText(stateDestination).split('// Generated automatically:')[0].trim() + `\n\n// Generated automatically:\nnamespace lua\n{${stateExtras}\n}\n`);
    }
  }

  var gets = {};
  data.replace(/\bLUAGETSET\w*\(([^,]+), (\w+?)_(\w+)/g, (_, type, group, name) => {
    (gets[group] || (gets[group] = [])).push(name);
  });

  for (var n in gets){
    exportEntries.push(`ac.${n} = {}
    setmetatable(ac.${n}, {
      __index = function (self, k) 
        ${gets[n].map(x => `if k == '${x}' then return ffi.C.lj_get${n}_${x}() else`).join('')}
        error('${n} does not have an attribute \`'..k..'\`') end
      end,
      __newindex = function (self, k, v) 
        ${gets[n].map(x => `if k == '${x}' then ffi.C.lj_set${n}_${x}(v) else`).join('')}
        error('${n} does not have an attribute \`'..k..'\`') end
      end,
    })`);
  }

  if (definitionsCallback){
    definitionsCallback(docDefinitions.join('\n'));
  }

  const localDefineKeys = Object.values(localDefines);
  localDefineKeys.sort((a, b) => a.key > b.key ? 1 : -1);

  return base
    .replace(/\bDEFINITIONS\b/, '\n' + ffiStructures.join('\n') + ffiDefinitions.join('\n') + '\n')
    .replace(/\bEXPORT\b/, localDefineKeys.map(x => `local ${x.key} = ${x.value}`).join('\n') + exportEntries.join('\n'));
}

function crunchC(code){
  return code.replace(/\/\/.+/g, '').trim().replace(/\t+/g, '').replace(/([{;,*&])\s+/g, '$1').replace(/ ([{])/g, '$1');
  // return code.replace(/^\s+|\s*\n\s*/g, '').replace(/\s+(?=\{)|([{},*;])\s+/g, '$1');
}

function resolveRequires(code, filename, toInsert = null, processed = {}){
  var refDir = filename.replace(/[\/\\][^\/\\]+$/, '');
  var ast = parser.parse(code);

  var mainNode = toInsert == null;
  if (mainNode) toInsert = [];
  function resolve(piece){
    for (var n in piece){
      var p = piece[n];
      if (!p || typeof p != 'object') continue;
      if (minifyFfiDefinitions && p.base && p.base.type == 'MemberExpression' && p.base.indexer == '.' && p.base.identifier.name == 'cdef' 
        && p.base.base.name == 'ffi' && (p.type == 'StringCallExpression' && p.argument.type == 'StringLiteral' 
          || p.type == 'CallExpression' && p.arguments.length == 1 && p.arguments[0].type == 'StringLiteral')){
        (p.argument || p.arguments[0]).raw = JSON.stringify(crunchC((p.argument || p.arguments[0]).value));
      } else if (p.base && p.base.type == 'Identifier' && p.base.name == 'require' 
        && (p.type == 'StringCallExpression' && p.argument.type == 'StringLiteral' 
          || p.type == 'CallExpression' && p.arguments.length == 1 && p.arguments[0].type == 'StringLiteral')){
        var e = (p.argument || p.arguments[0]).value;
        if (e == 'ffi') continue;
        if (e == './ac_common'){
          (p.argument || p.arguments[0]).raw = JSON.stringify('extension/lua/ac_common');
          continue;
        }
        var a = refDir + '/' + e + '.lua';
        if (fs.existsSync(a)){
          var m = resolveRequires($.readText(a), a, toInsert, processed);
          var q = '__' + e.replace(/.+[\\//]/, '').replace(/\W+/g, '');
          if (processed[q]) $.fail('Already added: ' + e + ' (file: ' + filename + ')');
          processed[q] = true;
          toInsert.push({
            type: 'FunctionDeclaration',
            identifier: { type: 'Identifier', name: q, isLocal: true },
            isLocal: true,
            parameters: [],
            body: m.body
          });
          piece[n] = {
            type: 'CallExpression',
            base: { type: 'Identifier', name: q, isLocal: true },
            arguments: []
          };
        } else {
          $.fail('Not found: ' + a)
        }
      } else resolve(piece[n]);
    }
  }
  resolve(ast);
  if (mainNode){
    ast.body = toInsert.concat(ast.body);
  }
  return ast;
}

const luaJit = $[process.env['LUA_JIT']];

async function precompileLua(name, script){
  fs.writeFileSync(`.out/${name}.lua`, script);
  await luaJit('-bgn', name, `${name}.lua`, `${name}.raw`, { cwd: '.out' });
  return fs.readFileSync(`.out/${name}.raw`);
}

function processTarget(filename){
  $.echo(β.grey(`Processing Lua: ${filename}`));

  const base = $.readText(filename);
  const source = []; base.replace(/--\s+source:\s+(\S+)/g, (_, g) => source.push(g));
  const filter = /--\s+namespace:\s+(\S+)/.test(base) ? RegExp.$1 : '';
  const state = /--\s+states:\s+(\S+)/.test(base) ? RegExp.$1 : '';
  if (state) source.push(state);
  const code = getLuaCode(source.map(x => `${cspSource}/${x}`), state ? `${cspSource}/${state}` : null, filter, base, definitions => {
    fs.writeFileSync(`.definitions/${path.basename(filename, '.lua')}.txt`, definitions)
  });
  let ast = null;
  try {
    ast = resolveRequires(code, filename);
  } catch (e){
    fs.writeFileSync(`.out/failed.lua`, code)
    throw e;
  }
  return luamax.maxify(ast);
}

const packedPieces = [];
if (process.env['INI_STD_BINARY']){
  packedPieces.push({ key: 'ini_std', data: fs.readFileSync(process.env['INI_STD_BINARY']) });
}
for (let filename of $.glob(`./ac_*.lua`)){
  const name = path.basename(filename, '.lua');
  packedPieces.push({ key: name, data: await precompileLua(name, processTarget(filename)) });
}
await $.zip(packedPieces, { to: '../std.zip' });

// for (let filename of $.glob(`./ac_common*.lua`)){
//   const name = path.basename(filename, '.lua');
//   processTarget(filename);
// }
