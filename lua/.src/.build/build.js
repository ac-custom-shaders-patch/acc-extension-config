#!node -r shelljs-wrap

// Options:
const minifyFfiDefinitions = true;

// Data:
const enumTypes = {};
const luaTypes = {};
const knownTypes = { 
  regex: /^(void|char|int|u?int\d+_t|size_t|float|double|bool|vec[234]|mat3x3|rgbm?)$/, 
  ffiStructs: {},
  referencedTypes: {},
  ffiFunctions: {},
  referencedFunctions: {}
}

// Checking types to detect errors early:
function resetTypes(){
  knownTypes.ffiStructs = {};
  knownTypes.referencedTypes = {};
  knownTypes.ffiFunctions = {};
  knownTypes.referencedFunctions = {};
}

function checkTypes(){  
  function knownType(luaType){
    if (knownTypes.regex.test(luaType)) return true;
    if (knownTypes.ffiStructs.hasOwnProperty(luaType)) return true;
    return false;
  }

  function knownFunction(luaFunction){
    if (knownTypes.ffiFunctions.hasOwnProperty(luaFunction)) return true;
    return false;
  }

  for (let k in knownTypes.referencedTypes){
    if (!knownType(k)){
      $.echo(β.yellow(`Possibly unknown type: ${k} (cpp: ${knownTypes.referencedTypes[k]})`))
    }
  }

  for (let k in knownTypes.referencedFunctions){
    if (!knownFunction(k)){
      $.echo(β.yellow(`Possibly unknown function: ${k}`))
    }
  }
}

// Rules:
function notForExport(t) {
  if (/^(lj_memmove|lj_malloc|lj_calloc|lj_realloc|lj_free)$/.test(t)) return true;
  if (/lj_[^_]+_[^_]/.test(t)) return true;
  return false;
}

function baseTypeToLua(t){
  if (/^float(\d)$/.test(t)) return `vec${RegExp.$1}`;
  if (t === 'uint') return 'uint32_t';
  if (t === 'size_t') return 'uint64_t';
  if (enumTypes.hasOwnProperty(t)) return enumTypes[t].underlyingType || 'int';
  if (luaTypes.hasOwnProperty(t)) return luaTypes[t];
  if (/_array$/.test(t)) return 'void';
  return t;
}

function typeToLua(t) {
  let m = 0;
  t = t.replace(/^(const\s*)?([\w:]+)([&*])?$/, (_, p, v, x) => {
    ++m;
    const y = baseTypeToLua(v);
    knownTypes.referencedTypes[y] = v;
    return (p || '') + y + (x || '');
  });
  if (m !== 1){
    $.fail(`Unexpected type: ${t}`);
  }
  return t;
}

function crunchC(code) {
  code.replace(/\}\s+(\w+)\b/g, (_, n) => knownTypes.ffiStructs[n] = true);
  code.replace(/\b(lj_\w+)\b/g, (_, n) => knownTypes.ffiFunctions[n] = true);
  return code.replace(/--.+/g, '').replace(/\s([\w:]+)\s+(\w+);/g, (_, n, v) => {
    const l = typeToLua(n);
    if (l !== n) {
      return ` ${l} ${v};`
    }
    if (/:/.test(n)){
      $.fail(`unknown type: ${n}`);
    }
    return _;
  }).replace(/\/\/.+/g, '').trim().replace(/\t+/g, '').replace(/([{;,*&])\s+/g, '$1').replace(/ ([{])/g, '$1');
}

function defaultValueToLua(t) {
  if (!t) return null;
  return t.replace(/[{}]/g, _ => _ == '{' ? '(' : ')').replace(/\d\.?f\b/g, _ => _[0]);
}

const isVectorType = (() => {
  function createType(type) {
    function poolName(arg, localDefines) {
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
    mat3x3: createType('mat3x3'),
  };

  return type => vectorTypes[type];
})();

function getTypeInfo(type, customTypes) {
  if (type === 'const char*') {
    return {
      name: 'string',
      default: '""',
      prepare: arg => `tostring(${arg.name})`
    };
  }

  if (type === 'float' || type === 'int' || type === 'uint') {
    return {
      name: 'number',
      default: null,
      prepare: arg => `tonumber(${arg.name}) or ${arg.default || 0}`
    };
  }

  if (type === 'bool') {
    return {
      name: 'boolean',
      default: null,
      prepare: arg => arg.default == 'true' ? `(${arg.name} or ${arg.name} == nil) and true or false` : `${arg.name} and true or false`
    };
  }

  const enumType = enumTypes[type];
  if (enumType != null) {
    return {
      name: enumType.name,
      default: null,
      prepare: enumType.passThrough 
        ? arg => `tonumber(${arg.name}) or ${enumType.default}`
        : arg => `__util.cast_enum(${arg.name}, ${enumType.min}, ${enumType.max}, ${enumType.default})`
    };
  }

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

  return {
    name: toDocName(luaType, customTypes),
    default: valueRequired ? null : 'nil',
    prepare: arg => { $.echo(β.red(`Prepare function is missing for ${type}`)); return '' }
  };
}

function toDocName(luaType, customTypes){
  if (luaType === 'uint64_t') return 'uint64';

  const knownType = /^state_/.test(luaType);
  if (!knownType){
    // $.echo(`Unknown type: ${luaType}`);
    return '<' + luaType + '>';
  }

  return knownType ? toNiceName(luaType) : '?';
}

function isStatementPrepare(x){
  return / = |\n/.test(x);
}

function prepareParam(arg, wrapDefault, localDefines) {
  if (arg.typeInfo.default == null) {
    return arg.typeInfo.prepare(arg, localDefines);
  }

  let localPrepare = arg.typeInfo.prepare(arg, localDefines);
  if (!isStatementPrepare(localPrepare)){
    localPrepare = `${arg.name} = ${localPrepare}`;
  }

  return `if ${arg.name} ~= nil then 
    ${localPrepare} 
  else
    ${arg.name} = ${wrapDefault(arg.default || arg.typeInfo.default)} 
  end`;
}

function toNiceName(name) {
  return name.replace(/_([a-z])/g, (_, a) => a.toUpperCase());
}

function wrapParamDefinition(arg) {
  if (arg.typeInfo.name === '?') $.echo(β.yellow(`Unknown type: ${arg.type}`));
  return arg.default ? `${arg.niceName}: ${arg.typeInfo.name} = ${arg.default}` : `${arg.niceName}: ${arg.typeInfo.name}`;
}

function wrapReturnDefinition(arg, customTypes) {
  if (arg === 'void') return '';
  return `: ${getTypeInfo(arg, customTypes).name}`;
}

function needsWrappedResult(type) {
  if (/const char\*/.test(type)) return true;
  return false;
}

function wrapResult(type) {
  if (type == 'void') return x => x;
  if (/const char\*/.test(type)) return x => `return ffi.string(${x})`;
  return x => `return ${x}`;
}

function extendArg(arg, fnName, allArgs, customTypes) {
  arg.niceName = toNiceName(arg.name);
  arg.typeInfo = getTypeInfo(arg.type, customTypes);
  arg.allArgs = allArgs;
}

// Actual processing
const parser = require('./utils/luaparse');
const luamax = require('./utils/luamax');

const defBr = { '[': ']', '{': '}', '(': ')', '<': '>' };
const baseBr = { '(': ')' };
const cspSource = `${process.env['CSP_ROOT']}/source`;

function brackets(s, reg, br, cb) {
  for (var i, r = '', m, o, f, b = br || defBr; m = reg.exec(s); s = s.substr(i + 1)) {
    r += s.substr(0, m.index);
    for (i = m.index + m[0].length, o = []; i < s.length; i++) {
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

function split(s, sep, br) {
  for (var r = [], o = [], l = 0, b = br || defBr, i = 0; i < s.length; i++) {
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
      if (n == 'LUATYPEDEF') return;
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

const stateDefinitionsUpdated = {};

function getLuaCode(opts, definitionsCallback) {
  const ffiDefinitions = [];
  const ffiStructures = [];
  const localDefines = {};
  const exportEntries = [];
  const docDefinitions = [];

  const data = opts.sources.map(x => $.readText(`${cspSource}/${x}`)).join('\n\n').replace(/,\s*\r?\n\s*/g, ', ');
  const prepared = processMacros(data);
  prepared.replace(/LUATYPEDEF\(\s*([\w:]+)\s*,\s*(\w+)\s*\)/g, (_, k, v) => luaTypes[k] = v);

  function splitArgs(name, args) {
    let defaultMap = {};
    args = args.replace(/\(.+?\)|\{.+?\}/g, _ => {
      const key = Math.random().toString(32).substr(2);
      defaultMap[key] = _;
      return key;
    });
    const unwrap = x => {
      for (let k in defaultMap) {
        x = x.replace(k, defaultMap[k]);
      }
      return x;
    };

    const ret = args.split(',')
      .map((x, i) => /^([^=]+)\s+(\w+)(?:\s*=\s*(.+))?$/.test(x) ? { index: i, type: RegExp.$1.trim(), name: RegExp.$2, default: defaultValueToLua(unwrap(RegExp.$3.trim())) } : null)
      .filter(x => x);
    ret.forEach(x => extendArg(x, name, ret, opts.customTypes));
    return ret;
  }

  function wrapDefault(value) {
    if (/\(/.test(value)) {
      const i = localDefines[value];
      return i ? i.key : (localDefines[value] = { key: `__def_${value.replace(/\W+/g, '')}`, value }).key;
    }
    return value;
  }

  prepared.replace(/\bLUAEXPORT\s+((?:const\s+)?\w+\*?)\s+(lj_\w+)\s*\((.*)/g, (_, resultType, name, argsLine) => {
    let ns = 'ac';
    if (/__(\w+)$/.test(name) && !opts.allows.includes(RegExp.$1)) {
      if (opts.namespaces.includes(RegExp.$1)) {
        ns = RegExp.$1;
      } else {
        return;
      }
    }

    const args = splitArgs(name, argsLine.split(/\)\s*(\{|$)/)[0].trim());
    ffiDefinitions.push(`${typeToLua(resultType)} ${name}(${args.map(x => `${typeToLua(x.type)} ${x.name}`).join(', ')});`);
    if (notForExport(name)) return;

    const cleanName = name.replace(/^lj_|__\w+$/g, '');
    if (args.length > 0 || needsWrappedResult(resultType)) {
      const prepared = args.map(x => prepareParam(x, wrapDefault, localDefines)).map(x => ({ x, i: !isStatementPrepare(x) }));
      exportEntries.push(`${ns}.${cleanName} = function(${args.map(x => x.name).join(', ')}) 
        ${prepared.filter(x => !x.i).map(x => x.x).join(' ')} 
        ${wrapResult(resultType)(`ffi.C.${name}(${args.map((x, i) => prepared[i].i ? prepared[i].x : x.name).join(', ')})`)} 
      end`);
      docDefinitions.push(`${ns}.${cleanName}(${args.map(x => wrapParamDefinition(x)).join(', ')})${wrapReturnDefinition(resultType, opts.customTypes)}`);
    } else {
      exportEntries.push(`${ns}.${cleanName} = ffi.C.${name}`);
      docDefinitions.push(`${ns}.${cleanName}()${wrapReturnDefinition(resultType, opts.customTypes)}`);
    }
  });

  if (opts.states.length > 0) {
    for (let name of opts.states) {
      stateExtras = '';
      $.readText(`${cspSource}/${name}`).replace(/\bLUASTRUCT\s+(\w+)([\s\S]+?)\n(?:\t| {4})\};/g, (_, name, content) => {
        const fields = [];
        const cppStatic = [];
        const cppUpdate = [];
        content.replace(/\bLUA(\w+)\((.+)/g, (_, keys, data) => {
          let comment = '';
          if (/^(.+)\/\/\s*(.+)$/.test(data)) {
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

        if (!stateDefinitionsUpdated.hasOwnProperty(name)) {
          if (/void init\((.*?)\)/.test(content)) {
            const args = RegExp.$1 ? RegExp.$1.split(',').map(x => x.trim()) : [];
            const argNames = args.map(x => x.split(' ')[1]);
            stateExtras += `\n\tvoid ${name}::init(${args})\n\t{\n\t\tconst init_ctx c{${argNames}};\n\t\t${cppStatic.join('\n\t\t')}\n\t}\n`
          }

          if (/void update\((.*?)\)/.test(content)) {
            const args = RegExp.$1 ? RegExp.$1.split(',').map(x => x.trim()) : [];
            const argNames = args.map(x => x.split(' ')[1]);
            if (cppStatic.length > 0) {
              stateExtras += `\n\tvoid ${name}::update(${args})\n\t{\n\t\tif (needs_initialization()) init(${argNames});\n\t\tconst ctx c{${argNames}};\n\t\t${cppUpdate.join('\n\t\t')}\n\t}\n`
            } else {
              stateExtras += `\n\tvoid ${name}::update(${args})\n\t{\n\t\tconst ctx c{${argNames}};\n\t\t${cppUpdate.join('\n\t\t')}\n\t}\n`
            }
          }
        }
      });

      if (stateExtras) {
        $.echo(β.grey(`  State definitions updated: ${name}`));
        fs.writeFileSync(`${cspSource}/${name}`, 
          $.readText(`${cspSource}/${name}`).split('// Generated automatically:')[0].trim() 
          + `\n\n// Generated automatically:\nnamespace lua\n{${stateExtras}\n}\n`);
        stateDefinitionsUpdated[name] = true;
      }
    }
  }

  var gets = {};
  data.replace(/\bLUAGETSET\w*\(([^,]+), (\w+?)_(\w+)/g, (_, type, group, name) => {
    (gets[group] || (gets[group] = [])).push(name);
  });

  for (var n in gets) {
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

  if (definitionsCallback) {
    definitionsCallback(docDefinitions.join('\n'));
  }

  const localDefineKeys = Object.values(localDefines);
  localDefineKeys.sort((a, b) => a.key > b.key ? 1 : -1);

  return `ffi.cdef [[ DEFINITIONS ]] EXPORT`
    .replace(/\bDEFINITIONS\b/, '\n' + ffiStructures.join('\n') + ffiDefinitions.join('\n') + '\n')
    .replace(/\bEXPORT\b/, localDefineKeys.map(x => `local ${x.key} = ${x.value}`).join('\n') + exportEntries.join('\n'));
}

function resolveRequires(code, filename, context = null) {
  const refDir = filename ? filename.replace(/[\/\\][^\/\\]+$/, '') : null;

  let ast;
  try {
    ast = parser.parse(code);
  } catch (e){
    fs.writeFileSync('.out/failed.lua', code);
    throw e;
  }

  const mainNode = context == null;
  if (mainNode) {
    resetTypes();
    context = {
      toInsert: [],
      processed: {},
      definitions: {
        sources: [],
        states: [],
        allows: [],
        namespaces: [],
        customTypes: {},
      }
    };
    context.specialCalls = {
      __source: context.definitions.sources,
      __states: context.definitions.states,
      __allow: context.definitions.allows,
      __namespace: context.definitions.namespaces,
    };
  }

  function requireFnName(callRequire){
    const filename = refDir + '/' + callRequire + '.lua';
    // $.echo(β.grey(`  Include: ${filename}`));
    if (fs.existsSync(filename)) {
      const fnName = '__' + callRequire.replace(/.+[\\//]/, '').replace(/\W+/g, '');
      if (context.processed[fnName]) return null;
      context.processed[fnName] = true;
      return {fnName, filename};
    } else {
      $.fail('Not found: ' + filename);
    }
  }

  function isStringCallExpression(p, nameTest) {
    if (p.base && p.base.type == 'Identifier' && nameTest(p.base.name)
      && (p.type == 'StringCallExpression' && p.argument.type == 'StringLiteral'
        || p.type == 'CallExpression' && p.arguments.length == 1 && p.arguments[0].type == 'StringLiteral')) {
      return (p.argument || p.arguments[0]).value;
    }
    return false;
  }

  function processStatement(p) {
    function isStringCall(nameTest) {
      if (p.type === 'CallStatement' && p.expression && isStringCallExpression(p.expression, nameTest)) {
        return (p.expression.argument || p.expression.arguments[0]).value;
      }
      return false;
    }

    if (p.type === 'CallStatement' && p.expression && p.expression.base && p.expression.base.name === '__definitions') {
      if (context.definitions == null) $.fail(`definitions are processed already (__definitions, ${filename})`);
      const code = getLuaCode(context.definitions, definitions => {
        fs.writeFileSync(`.definitions/${path.basename(filename, '.lua')}.txt`, definitions)
      });
      context.definitions = null;
      return resolveRequires(code, null, context).body;
    }

    if (p.type == 'AssignmentStatement'
      && p.variables.length === 1 && p.variables[0].type === 'MemberExpression'
      && p.init.length === 1 && p.init[0].type === 'CallExpression' && p.init[0].base.type === 'MemberExpression'
      && p.init[0].base.base.name === 'ffi' && p.init[0].base.identifier.name === 'metatype') {
      if (context.definitions == null) $.fail(`definitions are processed already (ffi.metatype, ${filename})`);
      const typeName = p.variables[0].base.name + p.variables[0].indexer + p.variables[0].identifier.name;
      const typeValue = p.init[0].arguments[0].value;
      context.definitions.customTypes[typeValue] = typeName;
    }

    if (p.type == 'AssignmentStatement'
      && p.variables.length === 1 && p.variables[0].type === 'MemberExpression'
      && p.init.length === 1 && p.init[0].type === 'CallExpression' && p.init[0].base.type === 'Identifier'
      && p.init[0].base.name === '__enum' && p.init[0].arguments.length == 2) {
        const args = p.init[0].arguments.map(x => x.fields.reduce((a, b) => (a[b.key.name] = b.value.value, a), {}));
        if (args[0].name == null) args[0].name = p.variables[0].base.name + p.variables[0].indexer + p.variables[0].identifier.name;
        if (args[0].min == null) args[0].min = Object.values(args[1]).reduce((a, b) => Math.min(a, b), Number.POSITIVE_INFINITY);
        if (args[0].max == null) args[0].max = Object.values(args[1]).reduce((a, b) => Math.max(a, b), Number.NEGATIVE_INFINITY);
        if (args[0].default == null) args[0].default = Object.values(args[1])[0];
        if (args[0].underlyingType == null) args[0].underlyingType = 'int';
        enumTypes[args[0].cpp] = args[0];
        p.init[0] = p.init[0].arguments[1];
        return p;
    }

    let callSpecialName = null;
    const callSpecialArg = isStringCall(x => /^__/.test(callSpecialName = x));
    const callSpecialList = context.specialCalls[callSpecialName];
    if (callSpecialList != null) {
      if (context.definitions == null) $.fail(`definitions are processed already (${callSpecialName}, ${callSpecialArg}, ${filename})`);
      if (!callSpecialList.includes(callSpecialArg)) {
        callSpecialList.push(callSpecialArg);
      }
      return null;
    }

    const callRequire = isStringCall(x => x === 'require');
    if (callRequire) {
      if (callRequire == 'ffi') return;
      const ready = requireFnName(callRequire);
      return ready ? resolveRequires($.readText(ready.filename), ready.filename, context).body : null;
    }
  }

  function processPiece(p) {
    if (minifyFfiDefinitions && p.base && p.base.type == 'MemberExpression' && p.base.indexer == '.' && p.base.identifier.name == 'cdef'
      && p.base.base.name == 'ffi' && (p.type == 'StringCallExpression' && p.argument.type == 'StringLiteral'
        || p.type == 'CallExpression' && p.arguments.length == 1 && p.arguments[0].type == 'StringLiteral')) {
      (p.argument || p.arguments[0]).raw = JSON.stringify(crunchC((p.argument || p.arguments[0]).value));
      return true;
    }

    const callRequire = isStringCallExpression(p, x => x === 'require');
    if (callRequire) {
      if (callRequire == 'ffi') return;
      if (callRequire == './ac_common') {
        (p.argument || p.arguments[0]).raw = JSON.stringify('extension/lua/ac_common');
        return true;
      }

      const ready = requireFnName(callRequire);
      if (ready == null) return null;

      const resolved = resolveRequires($.readText(ready.filename), ready.filename, context);
      context.toInsert.push({
        type: 'FunctionDeclaration',
        identifier: { type: 'Identifier', name: ready.fnName, isLocal: true },
        isLocal: true,
        parameters: [],
        body: resolved.body
      });
      return {
        type: 'CallExpression',
        base: { type: 'Identifier', name: ready.fnName, isLocal: true },
        arguments: []
      };
    }
  }

  function resolve(piece, forceExpressionMode) {
    if (!Array.isArray(piece) || forceExpressionMode) {
      for (let n in piece) {
        const p = piece[n];
        if (!piece[n] || typeof piece[n] !== 'object') continue;

        const r = processPiece(p);
        if (r) {
          if (r !== true) piece[n] = r;
        } else if (r === null || resolve(p, n !== 'body') === false) {
          return false;
        }
      }
    } else {
      for (let i = 0; i < piece.length; ++i) {
        const p = piece[i];
        const r = processStatement(p);
        if (r) {
          if (r !== true) {
            const j = Array.isArray(r) ? r : [r];
            piece.splice(i, 1, ...j);
            i += j.length - 1;
          }
        } else if (r === null || resolve(p) === false) {
          piece.splice(i--, 1);
        }
      }
    }
  }

  resolve(ast);
  if (mainNode) {
    ast.body = context.toInsert.concat(ast.body);
  }

  return ast;
}

const luaJit = $[process.env['LUA_JIT']];

async function precompileLua(name, script) {
  fs.writeFileSync(`.out/${name}.lua`, script);
  await luaJit('-bgn', name, `${name}.lua`, `${name}.raw`, { cwd: '.out' });
  return fs.readFileSync(`.out/${name}.raw`);
}

function processTarget(filename) {
  $.echo(`Processing Lua: ${filename}`);
  const ast = resolveRequires($.readText(filename), filename);
  const code = luamax.maxify(ast);
  code.replace(/ffi\.C\.(\w+)/g, (_, f) => knownTypes.referencedFunctions[f] = true);
  code.replace(/ffi\.typeof\(['"](?!struct)(\w+)/g, (_, f) => knownTypes.referencedTypes[f] = true);
  checkTypes();
  return code;
}

const packedPieces = [];
if (process.env['INI_STD_BINARY']) {
  packedPieces.push({ key: 'ini_std', data: fs.readFileSync(process.env['INI_STD_BINARY']) });
}
for (let filename of $.glob(`./ac_*.lua`)) {
  // for (let filename of $.glob(`./ac_wfx_i*.lua`)){
  const name = path.basename(filename, '.lua');
  packedPieces.push({ key: name, data: await precompileLua(name, processTarget(filename)) });
}
await $.zip(packedPieces, { to: '../std.zip' });
