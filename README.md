# Knee's Nushell Scripts

These are the nushell scripts that I use on a daily basis. Nushell is a very useful tool for developing quick workflow enhancers.

## libpw, pixiv-wallpaper, and auto-pw

This set of scripts has layers of abstraction over libpw.

**libpw** is a nushell module imported with `use libpw`. This module has functions for fetching a pixiv access key, fetching bookmarks with the #wallpaper tag on pixiv, and randomly selecting one of those wallpapers. **pixiv-wallpaper** is a shell script that uses libpw to pick and set a wallpaper (using swww) from pixiv. Finally, **auto-pw** is a shell script which loops every 30 minutes to run pixiv-wallpaper.

TODO:
- fix blacklist so that it instead of removing id's removes indivual images when getting bookmark urls

## protoner

`create` a proton prefix with a protonge version, `install` a game with a prefix, `run` a game with a prefix, and `add` a game to lutris.

## walker-rbw

log into the rbw bitwarden client and pick a login to copy in walker.

## bgrun

run apps detached from shell (for use with nushell because there is no disown).

## ss-edit

edit an image copied to the clipboard. (mostly for editing latest screenshot)

## monkeytype-url

launch monkeytype with a theme json in `~/.cache/monkeytype.json`.

## toggle-main-monitor 

script very specific to my setup that turns off and on my main monitor along with doing some other stuff as not to break anything when a monitor is disconnected.

## screen-tools

ocr and qr code with grim and slurp.

## niri-picker

make niri's color picker copy hex to the clipboard all natively in nushell using niri's json output so hopefully it never breaks.

## fwoomer

makes woomer open on the correct screen in niri.

## cc-stream

open my capture card with low latency and now ui in mpv.

## cc-audio

loopback the audio from my capture card to my headset.

TODO: 
- make it use wpctl instead of pactl

## waybar-hider

only show waybar when the niri overview is open.