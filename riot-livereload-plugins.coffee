class RiotJSReloader
    @identifier = 'riotjs'
    @version = '1.0'

    constructor: (@window, @host) ->

    reload: (path, options) ->
        if @window.riot and @window.riot.reload
            if path.match(/\.tag\.js$/i)
                return @reloadRiotJS(path)

            if path.match(/\.js$/i)
                # disable normal Javascript reload
                # by doing nothing
                return yes
        return no
        
    reloadRiotJS: (path) ->
        scripts = (script for script in document.getElementsByTagName('script') \
            when script.src and script.src.indexOf(path) != -1)
        if scripts.length is 0
            console.warn "No script match #{path}"
        for script in scripts
            tagdef = script.getAttribute('data-tagdef')

            if tagdef
                new_script = document.createElement 'script'
                new_script.onload = ( ->
                    console.log "riotjs reloaded #{this}"
                    for def in this.split ','
                        riot.reload def
                ).bind tagdef
                new_script.src = @host.generateCacheBustUrl(script.src)
                document.body.appendChild new_script

            else
                src = @host.generateCacheBustUrl(script.src)
                xhr = new XMLHttpRequest()
                xhr.addEventListener "load", ->
                    # single tag reload
                    tagdef = eval @responseText
                    riot.reload tagdef
                xhr.open "GET", src
                xhr.send()

        return yes

window.LiveReloadPluginRiotjs = RiotJSReloader
