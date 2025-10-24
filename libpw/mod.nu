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
    } | flatten
}

export def "main" [] {
    (
        print 
        "use this as a library"
        "subcommands are:"
        ([
            init
            get-access-token
            update-bookmarks
            pick-wallpaper
            get-wallpaper
        ] | grid)
    )
}

export def "init" [] {
    if not (($env.PW_CACHEDIR)/images | path exists) {
        mkdir -v ($env.PW_CACHEDIR)/images
    }
}

# update cached access token if needed and then fetch it from cache
export def "get-access-token" [refresh_token: string] {
    let token_file = ($env.PW_CACHEDIR)/access_token.json

    if (try { ([(date now | into int), -3600000000000] | math sum ) > (open $token_file | get time) } catch { true }) {
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

    mut response = (
        requestBookmarks $"https://app-api.pixiv.net/v1/user/bookmarks/illust?user_id=($user_id)&restrict=public&filter=for_ios&tag=wallpaper"
    )

    mut toSave = $response.illusts

    loop {
        $response = requestBookmarks $response.next_url
        $toSave = $toSave | append $response.illusts
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
    ( $bookmarks |
    append $images |
    uniq -d |
    append $images |
    uniq -u |
    each { |file|
        rm ($env.PW_CACHEDIR)/images/($file)
    } )
}

# pick url from cached bookmarks list
export def "pick-wallpaper" [] {
    getBookmarkUrls |
    shuffle |
    first
}

# fetch pixiv wallpaper at specified url
export def "get-wallpaper" [wallpaper_url: string, access_token: string] {
    let bookmarks_file = ($env.PW_CACHEDIR)/bookmarks-list.json

    # update list if arg was passed
    
    let file = ($env.PW_CACHEDIR)/images/($wallpaper_url | url parse | get path | path basename)
    mut fetched = false

    # fetch image if it hasn't already been downloaded
    if not ($file | path exists) {
        http get $wallpaper_url --headers {
            Authorization: $"Bearer ($access_token)"
            Referer: "https://app-api.pixiv.net/"
        } --raw | save $file

        $fetched = true
    }

    {image: ($file | path basename) path: $file fetched: $fetched}
}
