Template = require 'views/layouts/templates/AppLayout'
HeaderView = require 'views/HeaderView'
FooterView = require 'views/FooterView'
ContentView = require 'views/ContentView'

class AppLayout extends Marionette.LayoutView
    el: 'main'
    template : Template
    regions:{
        # header:'header',
        content:'#content',
        # footer:'footer'
    }

    # se supone que debe de funciona onShow
    onRender:=>
        # @header.show new HeaderView()
        @content.show new ContentView()
        # @footer.show new FooterView()


module.exports = AppLayout
