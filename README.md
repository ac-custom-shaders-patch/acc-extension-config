# Custom Shaders Patch configs

[![Cars configs status](https://acstuff.ru/patch/cars-configs/warnings/icon)](https://acstuff.ru/patch/cars-configs/warnings/list)
[![Cars textures status](https://acstuff.ru/patch/cars-textures/warnings/icon)](https://acstuff.ru/patch/cars-textures/warnings/list)
[![Track configs status](https://acstuff.ru/patch/tracks-configs/warnings/icon)](https://acstuff.ru/patch/tracks-configs/warnings/list)
[![Track VAO status](https://acstuff.ru/patch/tracks-vao/warnings/icon)](https://acstuff.ru/patch/tracks-vao/warnings/list)
[![More information: https://trello.com/b/xq54vHsX/ac-patch](https://img.shields.io/badge/trello-more%20info-brightgreen.svg)](https://trello.com/b/xq54vHsX/ac-patch) 
[![Join the chat in Discord: https://discord.gg/buxkYNT](https://img.shields.io/badge/discord-join%20chat-brightgreen.svg)](https://discord.gg/W2KQCMH)

Configuration files and resources for Custom Shaders Patch for Assetto Corsa. Define things like track lights, specific car settings, additional tyres textures and so on. There is a server somewhere pulling it from time to time (with 5 minutes interval) and converting it into a format that can be downloaded automatically with AC Content Manager (or any other launcher, API for that is really simple).

## The good side of this

Most of the stuff is adjustable with ini files: live, saving a car/track-config take effect immediately during gameplay

## Links

- [Some documentation](https://github.com/ac-custom-shaders-patch/acc-extension-config/wiki);
- [Custom Shaders Patch webpage](https://acstuff.ru/patch/);
- [Trello board with more details](https://trello.com/b/xq54vHsX/ac-patch);
- [Shaders used by Shaders Patch](https://gitlab.com/ac-custom-shaders-patch/public/acc-shaders/tree/master).

## How to use it

If you’re using [AC Content Manager](https://acstuff.ru/app/) (lite version would work just as well), go to “Settings/Custom Shaders Patch”. From there, app would offer you to install or update the patch, as well as download configs. But, at the same time, you don’t have to worry about downloading configs: by default, Content Manager would download them automatically once needed.

If you’re not using Content Manager, you can always get any version of Shaders Patch [here](https://acstuff.ru/patch/). Then, either move files from “MODS/Shaders Lights Patch” to AC root folder (so “dwrite.dll” would end up next to “acs.exe”, that’s the patch itself), or use [JSGME](https://www.racedepartment.com/downloads/jsgme-mod-enabler.13803/) to enable it. And, with manual approach, you would have to download configs automatically. Simply download the whole repo in a ZIP file (there is that green button in the upper right corner right here) and extract it so folder “tzdata” would end up in “assettocorsa/extension”.

## Content of this repo
 - [Car light configs](https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/config/cars);
 - [Track light configs](https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/config/tracks);
 - [Vao-patches (prebaked shadows)](https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/vao-patches);

## Destination folders:
```
c:\Steam\steamapps\common\assettocorsa\extension\ or
c:\Progam Files\Steam\steamapps\common\assettocorsa\extension\ or 
%userprofile%\Documents\Assetto Corsa\cfg\extension\
\---extension
    +---config
    |   +---cars
    |   |   +---common
    |   |   +---kunos
    |   |   \---mods
    |   |       +---acclub
    |   |       +---acfl
    |   |       +---fo
    |   |       \---rss
    |   \---tracks
    |       \---common
    \---vao-patches
```
Be aware, that sometimes the cfg-maker did not name files properly, i.e. for this track-light-config — “config\tracks\ks_nurburgring.ini” — all these files are required too:

```
  nurbAllGlass.kn5
  nurbSpots.kn5
  nurbSpotsPad.kn5
  nurbpitglass2.kn5
```
