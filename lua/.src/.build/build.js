#!node -r shelljs-wrap

// options
var saneChecks = true;
var minify = !true;

function notForExport(t){
  if (/^(lj_memmove|lj_malloc|lj_calloc|lj_realloc|lj_free)$/.test(t)) return true;
  if (/lj_[^_]+_[^_]/.test(t)) return true;
  // if (/getTrackCoordinates/.test(t)) return true;
  return false;
}

function mapTypes(t){
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

// code
const parser = require('./utils/luaparse');
const luamin = require('./utils/luamin');
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

function clean(x){
  return x.split('\n').filter(x => /^\s*(?!--)\S/.test(x)).join('\n');
}

var processMacros = (src => {
  // list of macroses:
  var ms = [];

  // parse all defines into a neat list of functions
  $.readText(src).replace(
    /\n#define (\w+)\(((?:\w+|\.\.\.)(?:,\s*(?:\w+|\.\.\.))*)\)\s*((.+|(?!\n#define)[\s\S])+)/g, 
    (_, n, a, b) => {
      // if (n == 'LUAGETSET') return;
      var args = a.split(',').map(x => x.trim().replace('...', '')).map(x => [
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

var sanePiece = ``;

function getDefaultValue(x){
  return x.replace(/(\d)f\b/, '$1');
}

function getLuaCode(filename, mode, base){
  var defs = [];
  var exps = [];

  var data = $.readText(filename);
  processMacros(data).replace(/\bLUAEXPORT\s+((?:const\s+)?\w+\*?)\s+(lj_\w+)\s*\((.*?)\)/g, (_, resultType, name, args) => {
    if (/__(\w+)$/.test(name) && RegExp.$1 != mode) return;
    defs.push(mapTypes(resultType) + ' ' + name + '(' + mapTypes(args.split(',').map(x => x.split('=')[0].trim()).join(', ')) + ');');

    if (notForExport(name)) return;
    if (/const char\*|\brgb\b/.test(args) || /const char\*/.test(resultType) || saneChecks && args){
      var names = args.split(',').map(x => x.split('=')[0].trim().match(/\S+$/)).filter(x => x);
      var sane = saneChecks ? x => `ac.__sane(${x})` : x => x;
      var defaultValues = args.split(',').map(x => x.indexOf('=') !== -1 ? getDefaultValue(x.split('=')[1]).trim() : null);
      var wrapped = args.split(',').map(x => x.split('=')[0].trim()).filter(x => x).map((x, i) => 
        /const char\*/.test(x) ? `${names[i]} ~= nil and tostring(${names[i]}) or nil` :
        /\brgb\b/.test(x) ? `ac.__sane_rgb(${names[i]})` :
        names[i]).map((x, i) => /\b(tostring|__sane_\w+)\(/.test(x) ? x : sane(defaultValues[i] ? `${x} or ${defaultValues[i]}` : x)).join(', ');
      var returnPrefix = resultType == 'void' ? '' : 'return ';
      var resultWrap = /const char\*/.test(resultType) ? x => `ffi.string(${x})` : x => x;
      exps.push(`ac.${name.replace(/^lj_|__\w+$/g, '')} = function(${names.join(', ')}) ${returnPrefix}${resultWrap(`ffi.C.${name}(${wrapped})`)} end`)
    } else {
      exps.push(`ac.${name.replace(/^lj_|__\w+$/g, '')} = ffi.C.${name}`)
    }
  });

  var gets = {};
  data.replace(/\bLUAGETSET\w*\(([^,]+), (\w+?)_(\w+)/g, (_, type, group, name) => {
    (gets[group] || (gets[group] = [])).push(name);
  });

  for (var n in gets){
    exps.push(`ac.${n} = {}
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

  return base
    .replace(/\bDEFINITIONS\b/, defs.join('\n'))
    .replace(/\bEXPORT\b/, exps.join('\n'))
    .replace(/\bSANE\b/, saneChecks ? sanePiece : '');
}

function crunchC(code){
  return code.replace(/^\s+|\s*\n\s*/g, '').replace(/\s+(?=\{)|([},*;])\s+/g, '$1');
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
      if (minify && p.base && p.base.type == 'MemberExpression' && p.base.indexer == '.' && p.base.identifier.name == 'cdef' 
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
  const source = /--\s+source:\s+(\S+)/.test(base) ? RegExp.$1 : null;
  const filter = /--\s+namespace:\s+(\S+)/.test(base) ? RegExp.$1 : '';
  const code = getLuaCode(`${cspSource}/${source}`, filter, base);
  const ast = resolveRequires(code, filename);
  return minify ? luamin.minify(ast) : luamax.maxify(ast);
}

const packedPieces = [];
if (process.env['INI_STD_BINARY']){
  packedPieces.push({ key: 'ini_std', data: fs.readFileSync(process.env['INI_STD_BINARY']) });
}
for (let filename of $.glob(`./ac_*.lua`)){
  const name = path.basename(filename, '.lua');
  packedPieces.push({ key: name, data: await precompileLua(name, processTarget(filename)) });
}
await $.zip(packedPieces, { to: '../std.pak' });
