Layout = require '../views/layouts/AppLayout'
MainRouter = require 'routers/main'
Facebook = require 'lib/facebook'
Data = require 'Data'
Share = require 'lib/share'
Breakpoint = require 'lib/breakpoints'
AuthManager = require 'lib/AuthManager'
AudioManager = require 'lib/audioManager'

class App extends Marionette.Application
    debug: true
    views: null
    data: null
    width: window.innerWidth
    height: window.innerHeight
    objReady: 0

    initialize:(options)->
        if @debug
            console.info 'App options:', options
        require 'lib/helpers'
        @addListeners()
        null

    addListeners:=>
        $(window).on 'resize', @resize
        null

    onBeforeStart:(options)=>
        if @debug
            console.info("before:start", options)
        null

    onStart:(options)=>
        if @debug
            console.info("start:", options)
        @data = new Data @objectComplete
        @breakPoints = new Breakpoint @objectComplete
        # If audioManager is loader objReady must be 3
        # @audioManager = new AudioManager @objectComplete
        # @audioManager.load()
        null


    resize:=>
        @width = window.innerWidth
        @height = window.innerHeight

        null

    objectComplete: =>
        @objReady++
        if @objReady >= 2
            @initApp()
        null

    initApp: ()=>
        if @debug and bowser.name is 'Chrome'
            @stats = new MemoryStats()
            @renderStats()

        @auth = new AuthManager()
        @share = new Share
        @sections = new MainRouter
        @breakPoints = new Breakpoint

        @rootView = new Layout
        @rootView.render()

        if Backbone.history
            Backbone.history.start()

        @initSDKs()
        @animate()

        null

    initSDKs:()->
        ##Facebook.load()
        #askPermissions()
        null

    animate:()=>
        requestAnimationFrame(@animate)
        if(@debug)
            @stats.update()

        null

    renderStats: ()=>
        @stats.domElement.style.position = 'fixed'
        @stats.domElement.style.right = '0px'
        @stats.domElement.style.bottom = '0px'
        document.body.appendChild(@stats.domElement)

        null

module.exports = App
