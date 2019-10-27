async function run(file){
  await $['D:/Applications/Cygwin/bin/magick.exe'](`${file}`, 
    '-fill', '#ffffff', '-colorize', '100%', '-resize', '64x64', `../${file}`);
  await $['D:/Applications/Cygwin/bin/optipng.exe']('-o7', '-clobber', '-strip', 'all', `../${file}`);
}

for (let file of $.glob(`*.png`).filter(x => x[0] != '_')){
  await run(file);
}
