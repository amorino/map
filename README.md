## Languages

- [CoffeeScript](http://coffeescript.org/)
- [Sass/Compass](http://sass-lang.com/)
- [Handlebars](http://handlebarsjs.com/)

## Features

- [.editorconfig] (http://editorconfig.org/)
- [jQuery](https://github.com/jquery/jquery)
- [Lodash](https://github.com/bestiejs/lodash)
- [Backbone](https://github.com/jashkenas/backbone)
- [Marionette](http://marionettejs.com/)
- [Swag](https://github.com/elving/swag)
- [Font Awesome](https://github.com/FortAwesome/Font-Awesome)
- [HTML5 Boilerplate Helpers](https://github.com/h5bp/html5-boilerplate)

## Plugins

- [Brunch Auto-Reload](https://github.com/brunch/auto-reload-brunch)
- [Coffeelint](https://github.com/ilkosta/coffeelint-brunch)


## Getting started

    $ npm install
    $ bower install
    $ brunch w -s

## Animated Regions
[Animated Region](AnimatedRegion.md)


## Generators

First install [scaffolt](https://github.com/paulmillr/scaffolt#readme):

    npm install -g scaffolt

Then you can use the following commands to generate files:

    scaffolt itemView <name>
        → app/views/name.coffee
        → test/views/name_test.coffee

    scaffolt compositeView <name>
        → app/views/name.coffee
        → test/views/name_test.coffee

    scaffolt collectionView <name>
        → app/views/name.coffee
        → test/views/name_test.coffee

    scaffolt model <name>
        → app/models/name.coffee
        → test/models/name_test.coffee

    scaffolt style <name>
        → app/views/styles/name.styl

    scaffolt template <name>
        → app/views/templates/name.hbs

    scaffolt layout <name>
            → app/views/layouts/name.coffee

    scaffolt collection <name>
        → app/collections/name.coffee
        → test/collections/name_test.coffee

    scaffolt module <name>
        → app/viewsItem/name.coffee
        → test/viewsItem/name_test.coffee
        → app/models/name.coffee
        → test/models/name_test.coffee
        → app/views/styles/name.styl
        → app/views/templates/name.hbs

## Testing

To run your tests using [Karma](https://github.com/karma-runner) you will need to install [phantomjs](https://github.com/ariya/phantomjs):

    brew update && brew install phantomjs

Run the tests:

    cake test

Build and test your app:

    cake build:test

You can change Karma's configuration by editing `test/karma.conf.coffee` and add any test helpers by editing `test/helpers.coffee`.


