# libpw

A Nushell module/library for fetching images tagged `#wallpaper` from a users bookmarks on Pixiv.

## Getting started
To get started using libpw you will need your Pixiv user id and refresh token. 

Getting your user id is easy; just go to your profile page and look at the URL: `https://www.Pixiv.net/en/users/109696718` these numbers are your user id.

Next we have to get your refresh token which is slightly more annoying. I recommend using [gppt](https://github.com/eggplants/get-Pixivpy-token) which will spit out a refresh token and an access token. We only need the refresh token because libpw grabs access tokens when needed.

We need the refresh token in order to run the `get-access-token` subcommand and the user id to run the `update-bookmarks` subcommand.

Before running any other commands you should run the `init` subcommand. Running `init` before any other commands is recommended in your scripts. `init` will by default create a cache directory named `.pw-cache/` in the module folder. This can be changed by reassigning `$env.PW_CACHEDIR` after importing the module.

## Usage

```
libpw get-access-token <refresh_token>

libpw update-bookmarks <user_id> <access_token>

libpw pick-wallpaper

libpw get-wallpaper <wallpaper_url> <access_token>
```

`get-access-token` is run with your refresh token and returns your access token. Your access token is fetched from Pixiv only if the one in the cache has expired or does not exist.

Once you have your access token you should run `update-bookmarks`. This will create a JSON file in the cache with all of your bookmarks tagged with #wallpaper. If you want to change the tag that is used you can simply change the parameter in the URL that is fetched.

`pick-wallpaper` will pick a random image from the cached bookmarks list. Keep in mind these will only be up to date if you run `update-bookmarks` first.

`get-wallpaper` will fetch the image URL you specify if its not in the cache and return the images path. This is important with Pixiv URLs because they require special headers to fetch the images.

### Additional URLs and blacklisted images
There are two environmental variables that affect what images are included in the bookmark URLs list when `pick-wallpaper` is run and then the image cache is pruned by `update-bookmarks`.

`$env.PW_BLACKLIST_IMAGES` specifies what images should not be on the list. This should just be a list of strings such as `["71244380_p2.jpg", "129776555_p0.jpg"]`

`$env.PW_INCLUDE_URLS` specifies URLs that should be appended to the list. These can be other image links or even `file://` links to images on your filesystem. These additional images will be cached and pruned just like Pixiv ones (except for `file://` ones because those are already stored locally)

Example script:
```
#!/usr/bin/env nu

const file_dir = (path self | path dirname)

use libpw

libpw init

$env.PW_INCLUDE_URLS = if (($file_dir)/pw_include_urls.txt | path exists) { (open ($file_dir)/pw_include_urls.txt | lines) } else { null }

$env.PW_BLACKLIST_IMAGES = if (($file_dir)/pw_blacklist.txt | path exists) { (open ($file_dir)/pw_blacklist.txt | lines | into int) } else { null }

let keys = (open ($file_dir)/pw-keys.json)

let access_token = libpw get-access-token $keys.refresh_token

def printGreen [text] {
    print -e $"(ansi green_bold)($text)(ansi reset)"
}

# fetch bookmarked images tagged with #wallpaper from pixiv using libpw
def main [
    --update-bookmarks (-u) # update the bookmarks cache
    --no-apply (-n) # don't apply wallpaper after updating bookmarks
    --verbose (-v) # print verbose output
    --print (-p) # print url instead of applying wallpaper
] {
    if $update_bookmarks {
        libpw update-bookmarks $keys.user_id $access_token
        if $verbose {
            printGreen "bookmarks updated !"
        }
    }

    if $no_apply {
        if $verbose {
            printGreen "exiting early..."
        }
        exit
    }

    let url = libpw pick-wallpaper
    if $verbose {
        printGreen $"wallpaper selected: ($url)"
    }

    let wallpaper = libpw get-wallpaper $url $access_token
    if $verbose {
        $wallpaper | if ($in | get fetched) { printGreen "wallpaper was fetched !" } else { printGreen "wallpaper was in cache !" }
    }

    if $print {
        print $wallpaper.path
        exit
    }

    $wallpaper | get path | do { matugen image $in; swww img --transition-type wave $in }
    if $verbose {
        printGreen "wallpaper applied !"
    }
}
```