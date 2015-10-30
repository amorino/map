HeaderView = require 'views/Header'

describe 'HeaderView', ->
    beforeEach ->
        @view = new HeaderView()

    it 'should exist', ->
        expect(@view).to.be.ok
