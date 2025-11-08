const mod_dir = (path self | path dirname)

export-env { $env.PW_CACHEDIR = ($mod_dir)/.pw-cache }

def getBookmarkUrls [] {
    open ($env.PW_CACHEDIR)/bookmarks-list.json |
    each { |page|
        if ($page.page_count | into int) > 1 {
            get meta_pages.image_urls.original | flatten
        } else {
            get meta_single_page.original_image_url
        }
    } | flatten |
    append ($env.PW_INCLUDE_URLS?) |
    where not (
        (
        $it |
        url parse |
        get path |
        path basename
        ) in (
        $env.PW_BLACKLIST_IMAGES? |
        default []
        )
    )
}

export def "main" [] {
    (
        print
        "libpw should be used in a script."
        "subcommands are:"
        ([
            init
            get-access-token
            update-bookmarks
            pick-wallpaper
            get-wallpaper
        ] | grid)
        "run libpw <subcommand> --help for more information on how to use each subcommand"
    )
}

# create cache folder
export def "init" [] {
    if not (($env.PW_CACHEDIR)/images | path exists) {
        mkdir -v ($env.PW_CACHEDIR)/images
    }
}

export def "token auth" [] {
    let verifier = (random chars --length 48)
    let challenge = ($verifier | hash sha256 --binary | encode base64 --url --nopad)
    let url = $"https://app-api.pixiv.net/web/v1/login?code_challenge=($challenge)&code_challenge_method=S256&client=pixiv-android"
    { verifier: $verifier url: $url }
}

export def "token refresh" [code: string, verifier: string] {
    let response = http post "https://oauth.secure.pixiv.net/auth/token" $"grant_type=authorization_code&code=($code)&client_id=MOBrBDS8blbauoSck0ZfDbtuzpyT&client_secret=lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj&code_verifier=($verifier)&redirect_uri=https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback" --headers { "Content-Type": "application/x-www-form-urlencoded" }
    { user_id: ($response.user.id | into int), refresh_token: $response.refresh_token }
}

# update cached access token if needed and then fetch it from cache
export def "token access" [refresh_token: string] {
    let token_file = ($env.PW_CACHEDIR)/access_token.json

    if (try { (date now | into int) - (open $token_file | get time) > 3600000000000 } catch { true }) {
        let token_file = ($env.PW_CACHEDIR)/access_token.json
        let token = (http post "https://oauth.secure.pixiv.net/auth/token" $"grant_type=refresh_token&refresh_token=($refresh_token)&client_id=MOBrBDS8blbauoSck0ZfDbtuzpyT&client_secret=lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj" --headers { "Content-Type": "application/x-www-form-urlencoded" })
        {
            token: $token.access_token
            time: (date now | into int)
        } | save -f $token_file
    }

    open $token_file | get token
}

# fetch bookmarks from pixiv and cache them
export def "update-bookmarks" [user_id: int, access_token: string] {
    let $bookmarks_file = ($env.PW_CACHEDIR)/bookmarks-list.json

    def requestBookmarks [url: string] {
        http get $url --headers { Authorization: $"Bearer ($access_token)" }
    }

    mut response = {
        next_url: $"https://app-api.pixiv.net/v1/user/bookmarks/illust?user_id=($user_id)&restrict=public&filter=for_ios&tag=wallpaper"
    }

    mut toSave = []

    loop {
        $response = requestBookmarks $response.next_url
        $toSave ++= $response.illusts
        if $response.next_url == null { break }
    }

    $toSave | save -f $bookmarks_file

    let bookmarks = ( 
        getBookmarkUrls |
        each { url parse |
        get path |
        path basename }
    )

    let images = (
        ls -s ($env.PW_CACHEDIR)/images |
        get name
    )
    
    # clear images no longer in bookmarks from cache
    $images | where { |i|
        not ($bookmarks |
        any { |b| $b == $i}) 
    } |
    each { |i|
        rm ($env.PW_CACHEDIR)/images/($i)
    }
}

# pick url from cached bookmarks list
export def "pick-wallpaper" [] {
    getBookmarkUrls |
    shuffle |
    first
}

# fetch pixiv wallpaper at specified url
export def "get-wallpaper" [wallpaper_url: string, access_token: string] {
    mut file = ""

    if ($wallpaper_url | url parse).scheme == file {
        $file = ($wallpaper_url | url parse).path
    } else {
        $file = ($env.PW_CACHEDIR)/images/($wallpaper_url | url parse | get path | path basename)
    }
    
    mut fetched = false

    # fetch image if it hasn't already been downloaded
    if not ($file | path exists) {
        if ($wallpaper_url | url parse).host == i.pximg.net {
            http get $wallpaper_url --headers {
                Authorization: $"Bearer ($access_token)"
                Referer: "https://app-api.pixiv.net/"
            } --raw | save $file
        } else {
            http get $wallpaper_url --raw | save $file
        }

        $fetched = true
    }

    {image: ($file | path basename) path: $file fetched: $fetched}
}
