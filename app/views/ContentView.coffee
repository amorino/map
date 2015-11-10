AbstractItemView = require 'base/AbstractItemView'

class ContentView extends AbstractItemView
    className: 'Content'
    template : require 'views/templates/Content'
    renderWidth: window.innerWidth
    renderHeight: window.innerHeight
    menuBarWidth: 120
    velocityX: 0
    velocityY: 0
    friction: 0.94
    dragging: false
    positionX: 0
    dragPositionX: 0
    positionY: 0
    dragPositionY: 0
    rightBound: -200
    leftBound: 0
    topBound: -200
    bottomBound: 0
    zoom: 0.5
    boundFactor: 200
    # tilesWidth: 64
    # tilesHeight: 50
    # tilesSize: 16
    tilesWidth: 1
    tilesHeight: 1
    tilesSize: 10052
    tilesH: 4521

    onRender:()=>
        App.vent.on "renderer:resize", @resize
        @container = @.$el
        # For zoomed-in pixel art, we want crisp pixels instead of fuzziness
        # PIXI.SCALE_MODES.DEFAULT = PIXI.SCALE_MODES.NEAREST
        # Create the stage. This will be used to add sprites (or sprite containers) to the screen.
        @stage = new PIXI.Container()
        @stage.interactive = true
        # Create the renderer and add it to the page.
        # (autoDetectRenderer will choose hardware accelerated if possible)

        @renderer = PIXI.autoDetectRenderer(@renderWidth, @renderHeight)
        @container.append( @renderer.view)
        #document.body.appendChild(renderer.view);
        # Set up the asset loader for sprite images with the .json data and a callback
        tiles = ['./sprites/distrital_sprite.json']
        loader = PIXI.loader
        loader.add 'tilesjson', './sprites/distrital_sprite.json'
        loader.load(@onLoaded)
        # @texture = PIXI.Texture.fromImage './img/tiles.png'
        @renderer.view

    onLoaded:()=>
        @startTiledMap()
        # begin drawing
        @animate()
        return

    resize:()=>
        console.log 'resize'
        @renderWidth = window.innerWidth
        @renderHeight = window.innerHeight
        #this part resizes the canvas but keeps ratio the same
        @renderer.view.style.width = @renderWidth + 'px'
        @renderer.view.style.height = @renderHeight + 'px'
        #this part adjusts the ratio:
        @renderer.resize @renderWidth, @renderHeight

    animate:()=>
        @update()
        @rend()
        @renderer.render @stage
        requestAnimationFrame(@animate)
        return

    applyForceX:(force)=>
        @velocityX += force
        return

    applyForceY:(force)=>
        @velocityY += force
        return

    rend:()=>
        if @tilemap isnt undefined
            @tilemap.position.x = Math.floor(@positionX)
            @tilemap.position.y = Math.floor(@positionY)
        return

    update:()=>
        @applyDragForceX()
        @applyDragForceY()
        @applyBoundForceX @rightBound, true
        @applyBoundForceX @leftBound, false
        @applyBoundForceY @topBound, true
        @applyBoundForceY @bottomBound, false
        @velocityX *= @friction
        @velocityY *= @friction
        @positionX += @velocityX
        @positionY += @velocityY
        return

    applyRightBoundForce:()=>
        if @dragging or @positionX < @rightBound
            return
        # bouncing past bound
        distance = @rightBound - ( @positionX )
        force = distance * 0.1
        # calculate resting position with this force
        restX = @positionX + (@velocityX + force) / (1 - @friction)
        # apply force if resting position is out of bounds
        if restX > @rightBound
            @applyForce force
            return
        # if in bounds, apply force to align at bounds
        force = distance * 0.1 - @velocityX
        @applyForce force
        return

    applyBoundForceX:(bound, isForward) =>
        isInside = if isForward then @positionX < bound else @positionX > bound
        if @dragging or isInside
            return
        # bouncing past bound
        distance = bound - @positionX
        force = distance * 0.1
        restX = @positionX + (@velocityX + force) * @friction / (1 - @friction)
        isRestOutside = if isForward then restX > bound else restX < bound
        if isRestOutside
            @applyForceX force
            return
        # bounce back
        force = distance * 0.1 - (@velocityX)
        @applyForceX force
        return

    applyBoundForceY:(bound, isForward) =>
        isInside = if isForward then @positionY < bound else @positionY > bound
        if @dragging or isInside
            return
        # bouncing past bound
        distance = bound - @positionY
        force = distance * 0.1
        restX = @positionY + (@velocityY + force) * @friction / (1 - @friction)
        isRestOutside = if isForward then restX > bound else restX < bound
        if isRestOutside
            @applyForceY force
            return
        # bounce back
        force = distance * 0.1 - (@velocityY)
        @applyForceY force
        return

    applyDragForceX:()=>
        if !@dragging
            return
        @dragVelocityX = @dragPositionX - @positionX
        @dragForceX = @dragVelocityX - @velocityX
        @applyForceX @dragForceX
        return

    applyDragForceY:()=>
        if !@dragging
            return
        @dragVelocityY = @dragPositionY - @positionY
        @dragForceY = @dragVelocityY - @velocityY
        @applyForceY @dragForceY
        return


    startTiledMap:()=>
        @tilemap = new PIXI.Container()
        rightBound =  -(@boundFactor * @zoom)
        topBound =  -(@boundFactor * @zoom)
        @leftBound = window.innerWidth - (@tilesWidth * @tilesSize * @zoom) + (@boundFactor * @zoom)
        # @bottomBound = window.innerHeight - (@tilesHeight * @tilesSize * @zoom) + 200
        @bottomBound = window.innerHeight - (@tilesHeight * @tilesH * @zoom) + (@boundFactor * @zoom)
        @tilemap.interactive = true
        @tilemap.tilesWidth = @tilesWidth
        @tilemap.tilesHeight = @tilesHeight
        @tilemap.tileSize = @tilesSize
        @tilemap.zoom = @zoom
        @tilemap.scale.x = @tilemap.scale.y = @tilemap.zoom
        @tilemap.startLocation =
            x: 0
            y: 0
        # fill the map with tiles
        @generateMap()
        # variables and functions for moving the map
        @tilemap.mouseoverTileCoords = [
            0
            0
        ]
        @tilemap.selectedTileCoords = [
            0
            0
        ]
        @tilemap.mousePressPoint = [
            0
            0
        ]

        @tilemap.selectedGraphics = new PIXI.Graphics
        @tilemap.mouseoverGraphics = new PIXI.Graphics
        @stage.addChild @tilemap
        # @zoomIn()

        @stage.mousedown = (event) =>
            # @dragging = true
            # @tilemap.mousePressPoint[0] = event.data.getLocalPosition(@tilemap.parent).x - (@tilemap.position.x)
            # @tilemap.mousePressPoint[1] = event.data.getLocalPosition(@tilemap.parent).y - (@tilemap.position.y)
            # @selectTile Math.floor(@tilemap.mousePressPoint[0] / (@tilemap.tileSize * @tilemap.zoom)), Math.floor(@tilemap.mousePressPoint[1] / (@tilemap.tileSize * @tilemap.zoom))
            @dragging = true
            @mousedownX = event.data.originalEvent.pageX
            @mousedownY = event.data.originalEvent.pageY
            @dragStartPositionX = @positionX
            @dragStartPositionY = @positionY
            @setDragPosition event
            return

        @stage.mouseupoutside = @stage.mouseup = (event) =>
            @dragging = false
        #     return

        @stage.mousemove = (event) =>
            if @dragging
                moveX = event.data.originalEvent.pageX - @mousedownX
                @dragPositionX = @dragStartPositionX + moveX
                moveY = event.data.originalEvent.pageY - @mousedownY
                @dragPositionY = @dragStartPositionY + moveY
                if @dragPositionX > 0 or @dragPositionX < @leftBound - (@boundFactor * @zoom) or @dragPositionY > 0 or @dragPositionY < @bottomBound - (@boundFactor * @zoom)
                    @dragging = false
            #     position = event.data.getLocalPosition(@tilemap.parent)
            #     @tilemap.position.x = position.x - (@tilemap.mousePressPoint[0])
            #     @tilemap.position.y = position.y - (@tilemap.mousePressPoint[1])
            #     @constrainTilemap()
            return

    setDragPosition:(event)=>
        # console.log event
        moveX = event.data.originalEvent.pageX - @mousedownX
        moveY = event.data.originalEvent.pageY - @mousedownY
        @dragPositionX = @dragStartPositionX + moveX
        @dragPositionY = @dragStartPositionY + moveY
        # console.log @dragPositionX, @dragPositionY
        # event.preventDefault()
        return

    onMouseup:()->
        @dragging = false
        return

    addTile:(x, y, terrain)=>
        tile = PIXI.Sprite.fromFrame(terrain)
        tile.position.x = x * @tilemap.tileSize
        tile.position.y = y * @tilemap.tileSize
        tile.tileX = x
        tile.tileY = y
        tile.terrain = terrain
        @tilemap.addChildAt tile, x * @tilemap.tilesHeight + y
        return
    changeTile:(x, y, terrain)=>
        @tilemap.removeChild @getTile(x, y)
        @addTile x, y, terrain
        return
    getTile:(x, y)=>
        @tilemap.getChildAt x * @tilemap.tilesHeight + y
    generateMap:()=>
        i = 0
        o = 0
        @addTile 0, 0, 0
        # while i < @tilemap.tilesWidth
        #     currentRow = []
        #     j = 0
        #     while j < @tilemap.tilesHeight
        #         o = 0 if o is 10
        #         @addTile i, j, o
        #         j++
        #     o++
        #     ++i
        # j = 0
        # while j < 25
        #     # number of landmasses
        #     i = 0
        #     while i < 12
        #         # size seed of landmasses
        #         @spawnLandmass Math.floor(i / 2) + 1, Math.floor(Math.random() * @tilemap.tilesWidth), Math.floor(Math.random() * @tilemap.tilesHeight)
        #         i++
        #     j++
        # starting location
        # found = false
        # while !found
        #     x = Math.floor(Math.random() * @tilemap.tilesWidth)
        #     y = Math.floor(Math.random() * @tilemap.tilesHeight)
        #     tile = @getTile(x, y)
        #     if tile.terrain == 2
        #         @changeTile x, y, 5
        #         @tilemap.startLocation.x = x
        #         @tilemap.startLocation.y = y
        #         found = true

    spawnLandmass:(size, x, y)=>
        x = Math.max(x, 0)
        x = Math.min(x, @tilemap.tilesWidth - 1)
        y = Math.max(y, 0)
        y = Math.min(y, @tilemap.tilesHeight - 1)
        # console.log @getTile(x, y)
        if @getTile(x, y).terrain < size
            @changeTile x, y, Math.min(4, Math.max(1, Math.floor(size / (Math.random() + 0.9))))
        i = 0
        while i < size
            horiz = Math.floor(Math.random() * 3) - 1
            vert = Math.floor(Math.random() * 3) - 1
            @spawnLandmass size - 1, x + horiz, y + vert
            i++
        return
    selectTile:(x, y)=>
        @selectedTileCoords = [
            x
            y
        ]
        # menu.selectedTileText.setText("Selected Tile: " + this.selectedTileCoords);
        @tilemap.selectedGraphics.clear()
        @tilemap.selectedGraphics.lineStyle 2, 0xFFFF00, 1
        @tilemap.selectedGraphics.beginFill 0x000000, 0
        @tilemap.selectedGraphics.drawRect @tilemap.selectedTileCoords[0] * @tilemap.tileSize, @tilemap.selectedTileCoords[1] * @tilemap.tileSize, @tilemap.tileSize, @tilemap.tileSize
        @tilemap.selectedGraphics.endFill()
        return
    zoomIn:()=>
        @tilemap.zoom = Math.min(@tilemap.zoom * 2, 8)
        @tilemap.scale.x = @tilemap.scale.y = @tilemap.zoom
        @centerOnSelectedTile()
        @constrainTilemap()
        return
    zoomOut:()=>
        @tilemap.mouseoverGraphics.clear()
        @tilemap.zoom = Math.max(@tilemap.zoom / 2, 1)
        @tilemap.scale.x = @tilemap.scale.y = @tilemap.zoom
        @centerOnSelectedTile()
        @constrainTilemap()
        return
    centerOnSelectedTile:()=>
        @tilemap.position.x = @renderWidth / 2 - (@tilemap.selectedTileCoords[0] * @tilemap.zoom * @tilemap.tileSize) - (@tilemap.tileSize * @tilemap.zoom / 2)
        @tilemap.position.y = @renderHeight / 2 - (@tilemap.selectedTileCoords[1] * @tilemap.zoom * @tilemap.tileSize) - (@tilemap.tileSize * @tilemap.zoom / 2)
        return
    constrainTilemap:()=>
        @tilemap.position.x = Math.max(@tilemap.position.x, -1 * @tilemap.tileSize * @tilemap.tilesWidth * @tilemap.zoom + @renderWidth)
        @tilemap.position.x = Math.min(@tilemap.position.x, 0)
        @tilemap.position.y = Math.max(@tilemap.position.y, -1 * @tilemap.tileSize * @tilemap.tilesHeight * @tilemap.zoom + @renderHeight)
        @tilemap.position.y = Math.min(@tilemap.position.y, 0)
        return




module.exports = ContentView
