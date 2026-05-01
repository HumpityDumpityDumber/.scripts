# Knee's Nushell Scripts

These are the nushell scripts that I use on a daily basis. Nushell is a very useful tool for developing quick workflow enhancers.

## libpw, pixiv-wallpaper
This set of scripts has layers of abstraction over libpw.

**libpw** is a nushell module imported with `use libpw`. This module has functions for fetching a pixiv access key, fetching bookmarks with the #wallpaper tag on pixiv, and randomly selecting one of those wallpapers. **pixiv-wallpaper** is a shell script that uses libpw to pick and set a wallpaper (using swww) from pixiv. Finally, **auto-pw** is a shell script which loops every 30 minutes to run pixiv-wallpaper.

To use **pixiv-wallpaper** you have to place a keys file in `~/.config/pixiv-wallpaper` called `pw-keys.json` with `"user_id"` as an int and then `"refresh_token"` as a string.

## pixiv-token

for getting pixiv refresh token
 
## protoner

`create` a proton prefix with a protonge version, `install` a game with a prefix, `run` a game with a prefix, and `add` a game to lutris.

## bgrun

run apps detached from shell (for use with nushell because there is no disown).

## ss-edit

edit an image copied to the clipboard. (mostly for editing latest screenshot)

## toggle-main-monitor 

hacky way of disabling my monitor

## screen-tools

ocr and qr code with grim and slurp.

## niri-picker

make niri's color picker copy hex to the clipboard all natively in nushell using niri's json output so hopefully it never breaks.

## cc-stream

open my capture card with low latency and no ui in mpv.

## termexec

I use this instead of `ghostty -e <command>` so that if I ever switch terminals i dont have to update a bunch of configs

## cwalmv

a post script for cwal to give it a matugen like config

## toggle-sink

toggles default output device for pipewire with wpctl and pw-dump
