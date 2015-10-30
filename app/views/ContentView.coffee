AbstractItemView = require 'base/AbstractItemView'

class ContentView extends AbstractItemView
    className: 'Content'
    template : require 'views/templates/Content'
    renderWidth: window.innerWidth
    renderHeight: window.innerHeight
    menuBarWidth: 120
    positionX: 0
    velocityX: 0
    friction: 0.95
    isDragging: false

    onRender:()=>
        @container = @.$el
        # For zoomed-in pixel art, we want crisp pixels instead of fuzziness
        PIXI.SCALE_MODES.DEFAULT = PIXI.SCALE_MODES.NEAREST
        # @Tilemap.prototype = new PIXI.Container()
        # @Tilemap.prototype.constructor = @Tilemap()
        # Create the stage. This will be used to add sprites (or sprite containers) to the screen.
        @stage = new PIXI.Container()
        @stage.interactive = true
        # Create the renderer and add it to the page.
        # (autoDetectRenderer will choose hardware accelerated if possible)
        @renderer = PIXI.autoDetectRenderer(@renderWidth, @renderHeight)
        @container.append( @renderer.view)
        #document.body.appendChild(renderer.view);
        # Set up the asset loader for sprite images with the .json data and a callback
        tiles = ['./img/tiles.json']
        loader = PIXI.loader
        loader.add 'tilesjson', './img/tiles.json'
        loader.load(@onLoaded)
        # @texture = PIXI.Texture.fromImage './img/tiles.png'
        @renderer.view
    onLoaded:()=>
        console.log 'loaded'
        # @tilemap = new Tilemap 64, 50, @renderWidth, @renderHeight
        # @tilemap.position.x = 0
        # console.log @tilemap
        # @stage.addChild @tilemap
        # @menu = new Menu @menuBarWidth, @tilemap
        # @stage.addChild @menu
        # zoom in on the starting tile
        # @tilemap.selectTile @tilemap.startLocation.x, @tilemap.startLocation.y
        # @tilemap.zoomIn()
        # @tilingSprite = new PIXI.extras.TilingSprite(@texture, @renderer.width, @renderer.height)
        # @stage.addChild(@tilingSprite)

        @startTiledMap()

        # begin drawing
        @animate()
        return
    animate:()=>
        # @tilingSprite.tilePosition.x += 1
        # @tilingSprite.tilePosition.y += 1
        @renderer.render @stage
        requestAnimationFrame(@animate)
        return

    applyForce:(force)=>
        @velocityX += force
        return

    applyRightBoundForce:()=>
        if @isDragging or @positionX < @rightBound
            return
        # bouncing past bound
        distance = @rightBound - (@positionX)
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

    applyDragForce:()=>
        if !@isDragging
            return
        @dragVelocity = @tilemap.position.x - @positionX
        @dragForce = @dragVelocity - @velocityX
        @applyForce @dragForce
        return


    startTiledMap:()=>
        @tilemap = new PIXI.Container()
        # PIXI.Container.call(@tilemap)
        @tilemap.interactive = true
        @tilemap.tilesWidth = 64
        @tilemap.tilesHeight = 50
        @tilemap.tileSize = 16
        @tilemap.zoom = 2
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
        # @tilemap.addChild @selectedGraphics
        # @tilemap.addChild @mouseoverGraphics
        @stage.addChild @tilemap
        @zoomIn()

        @stage.mousedown = (event) =>
            # @dragging = true
            # @tilemap.mousePressPoint[0] = event.data.getLocalPosition(@tilemap.parent).x - (@tilemap.position.x)
            # @tilemap.mousePressPoint[1] = event.data.getLocalPosition(@tilemap.parent).y - (@tilemap.position.y)
            # @selectTile Math.floor(@tilemap.mousePressPoint[0] / (@tilemap.tileSize * @tilemap.zoom)), Math.floor(@tilemap.mousePressPoint[1] / (@tilemap.tileSize * @tilemap.zoom))
            @dragging = true
            @mousedownX = event.data.originalEvent.pageX
            console.log @mousedownX
            @dragStartPositionX = @positionX
            @setDragPosition event
            return

        @stage.mouseupoutside = @stage.mouseup = (event) =>
            # @dragging = false
            return

        @stage.mousemove = (event) =>
            # if @dragging
            #     position = event.data.getLocalPosition(@tilemap.parent)
            #     @tilemap.position.x = position.x - (@tilemap.mousePressPoint[0])
            #     @tilemap.position.y = position.y - (@tilemap.mousePressPoint[1])
            #     @constrainTilemap()
            return

    setDragPosition:(event)->
        moveX = event.pageX - @mousedownX
        @dragPositionX = @dragStartPositionX + moveX
        # event.preventDefault()
        return

    onMouseup:()->
        @dragging = false
        window.removeEventListener 'mousemove', setDragPosition
        window.removeEventListener 'mouseup', onMouseup
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
        # fill with ocean
        i = 0
        o = 0
        while i < @tilemap.tilesWidth
            currentRow = []
            j = 0
            while j < @tilemap.tilesHeight
                o = 0 if o is 10
                @addTile i, j, o
                j++
            o++
            ++i
        # spawn some landmasses
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
