Controller = require 'controllers/main'

class MainRouter extends Marionette.AppRouter
    controller: new Controller
    appRoutes:
        '': 'index',
        'dashboard': 'dashboard'

module.exports = MainRouter
