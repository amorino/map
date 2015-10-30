AppLayoutView = require 'views/AppLayout'

describe 'AppLayoutView', ->
    beforeEach ->
        @view = new AppLayoutView()

    it 'should exist', ->
        expect(@view).to.be.ok
