App = require './App'

options = {}

options.IS_LIVE = do -> return if window.location.host.indexOf('localhost') > -1 or window.location.search is '?d' then false else true
# IS_LIVE = false

#Initialize fastclick
FastClick.attach(document.body)

#Raven initialize
# Raven.config('https://db420a4eee384d5ab4fd5dc890e87775@app.getsentry.com/42782').install()

view = (window or document)

#Marionette Behaviors initialize
window.Behaviors = {}
Marionette.Behaviors.behaviorsLookup = ()->
    return window.Behaviors;

view.App = new App (options)
view.App.start()
