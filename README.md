# acc-extension-config
### Configuration files for Assetto Corsa Custom Shaders Patch

## the good side of this
*most of the stuff is adjustable with ini files*
live, saving a car/track-config take effect immediately during gameplay

wiki: https://github.com/ac-custom-shaders-patch/acc-extension-config/wiki 

## downloads:
 
 - Assetto Corsa Content Manager - required to run Assetto Corsa with the shaders patch
   https://acstuff.ru/app/

 - Custom Shaders Patch 
   Stable builds:
     - https://trello.com/c/6em3uuLJ/22-stable-builds
   or on this discord channel under #updates-download:
     - https://discord.gg/2NCVWvk

## content of this repo:
 - car light configs: https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/config/cars
 - track light configs: https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/config/tracks
 - vao-patches (prebaked shadows): https://github.com/ac-custom-shaders-patch/acc-extension-config/tree/master/vao-patches

## destination folders: 
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
Be aware, that sometimes the cfg-maker did not name files properly, i.e. for this track-light-config:

```  
  assettocorsa\extension\config\tracks\ks_nurburgring.ini
``` 

all these files are required too:
```
  nurbAllGlass.kn5
  nurbSpots.kn5
  nurbSpotsPad.kn5
  nurbpitglass2.kn5
```
