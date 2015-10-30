exports.config =
    files:
        javascripts:
            defaultExtension: 'coffee'
            joinTo:
                'js/app.js': /^(vendor|bower_components|app)/
            order:
                before: [
                    'bower_components/jquery/dist/jquery.js',
                    'bower_components/underscore/underscore.js',
                    'bower_components/backbone/backbone.js',
                    'bower_components/backbone.marionette/lib/backbone.marionette.js',
                    'bower_components/backbone.babysitter/lib/backbone.babysitter.js',
                    'bower_components/backbone.wreqr/lib/backbone.wreqr.js'
                ]
                after: [
                    'bower_components/swag/lib/swag.js'
                ]
            pluginHelpers: 'js/app.js'
        stylesheets:
            joinTo:
                'css/app.css': /^(vendor|bower_components|app)/
        templates:
            joinTo: 'js/app.js'
    plugins:
        autoReload:
            enabled:
                js: on
                css: on
                assets: off
        coffeelint:
            pattern: /^app\/.*\.coffee$/
            options:
                indentation:
                    value: 4
                    level: "warn"
                max_line_length:
                    level: "ignore"
                no_trailing_semicolons:
                    level: "ignore"
    conventions:
        assets: /(assets|vendor\/assets|font)/
    overrides:
        production:
            sourceMaps:yes
            optimize:yes
            plugins:
                autoReload:
                    enabled:false
