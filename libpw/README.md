# libpw

A nushell module/library for fetching images tagged `#wallpaper` from a users bookmarks.

## Getting started
To get started using libpw you will need your pixiv user id and refresh token. 

Getting your user id is easy; just go to your profile page and look at the url: `https://www.pixiv.net/en/users/109696718` these numbers are your user id.

Next we have to get your refresh token which is slightly more annoying. I recommend using [gppt](https://github.com/eggplants/get-pixivpy-token) which will spit out a refresh token and an access token. We only need the refresh token because libpw grabs access tokens when needed.

We need the refresh token in order to run the `get-access-token` subcommand and the user id to run the `update-bookmarks` subcommand.

Before running any other commands you should run the `init` subcommand. By default a cache directory named `.pw-cache/` is created in the module folder. This can be changed by reassigning `$env.PW_CACHEDIR` after importing the module, but before running any commands.

## Usage

`get-access-token` is run with your refresh token and returns your access token. Your access token is fetched from pixiv only if the one in the cache has expired or does not exist.

Once you have your access token you should run `update-bookmarks`. This will create a json file in the cache with all of your bookmarks tagged with #wallpaper. If you want to change the tag that is used you can simply change the parameter in the url that is fetched.
