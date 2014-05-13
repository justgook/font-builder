fontPainter = angular.module("font-painter", [])

# FontBuilder
fontPainter.factory "Packer", ->
  # https://github.com/jakesgordon/bin-packing
  Packer: class Packer
    constructor: (w, h)->
      @root = x: 0, y: 0, w: w, h: h
    fit: (blocks)->
      for block in blocks
        if node = @findNode @root, block.w, block.h
          block.fit = @splitNode node, block.w, block.h
      # console.log blocks
      return
    findNode: (root, w, h)->
      if root.used
        @findNode(root.right, w, h) or @findNode(root.down, w, h)
      else if (w <= root.w) and (h <= root.h)
        root
      else
        null
    splitNode: (node, w, h) ->
      node.used = true
      node.down  =
        x: node.x
        y: node.y + h
        w: node.w
        h: node.h - h
      node.right =
        x: node.x + w
        y: node.y
        w: node.w - w
        h: h
      return node

  # GrowingPacker: class GrowingPacker

fontPainter.directive "fontPainter", (Packer)->

  clearCanvas = (ctx)->
    ctx.save()
    # // Use the identity matrix while clearing the canvas
    ctx.setTransform(1, 0, 0, 1, 0, 0)
    ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height)
    #  Restore the transform
    ctx.restore()


  class DrawGlypsFill
    constructor: (ctx, glyph, options)->
      options ?= {}
      glyph ?= {}
      glyph.glyph ?= "a"
      glyph.fit ?= {}
      glyph.fit.x = if glyph.fit.x? then +glyph.fit.x else 0
      glyph.fit.y = if glyph.fit.y? then +glyph.fit.y else 0

  class DrawGlypsFillSolid extends DrawGlypsFill
    constructor: (ctx, glyph, options)->
      super
      options.color ?= "#000"
      options.alpha ?= 1
      do ctx.save
      ctx.globalAlpha = options.alpha
      ctx.fillStyle = options.color
      ctx.fillText glyph.glyph, glyph.fit.x, glyph.fit.y
      do ctx.restore
      return

  class DrawGlypsFillGradient extends DrawGlypsFill
    constructor: (ctx, glyph, options)->
      super
  class DrawGlypsFillImage extends DrawGlypsFill
    constructor: (ctx, glyph, options)->
      #http://www.w3schools.com/tags/canvas_createpattern.asp
      "#00FFFF"
      super

  class DrawGlypsShadow
    constructor: (ctx, glyph, options)->
  class DrawGlypsShadowOuter extends DrawGlypsShadow
    constructor: (ctx, glyph, options)->
      super
  class DrawGlypsShadowInner extends DrawGlypsShadow
    constructor: (ctx, glyph, options)->
      super

  class DrawGlypsStoke
    constructor: (ctx, glyph, options)->
  class DrawGlypsStokeCenter extends DrawGlypsStoke
    constructor: (ctx, glyph, options)-> super
  class DrawGlypsStokeOuter extends DrawGlypsStoke
    constructor: (ctx, glyph, options)-> super
  class DrawGlypsStokeInner extends DrawGlypsStoke
    constructor: (ctx, glyph, options)-> super

  drawGlyps = (ctx, blocks, fontFamily = "Sans-serif", fontSize = 10, fill = {enabled: false, fillOptions: null}, stroke = {enabled: true}, strokeStyle = "red", strokeWidth = 0, strokeType = "center")->
    unfit = []
    do ctx.save
    ctx.font = "#{fontSize}px #{fontFamily}"
    ctx.textBaseline = "top"

    if strokeWidth > 0

      # https://developer.mozilla.org/samples/canvas-tutorial/6_1_canvas_composite.html

      # http://stackoverflow.com/questions/13627111/drawing-text-with-an-outer-stroke-with-html5s-canvas
      # http://jsfiddle.net/hwG42/3/
      #ctx.lineJoin="miter"; //Experiment with "bevel" & "round" for the effect you want!
      #ctx.miterLimit=3;

      ctx.lineWidth = strokeWidth
      ctx.strokeStyle = strokeStyle

    for block in blocks
      if block.fit?
        if fill.enabled
          fillClass = switch fill.fillType
            when "color" then DrawGlypsFillSolid
            when "gradient" then DrawGlypsFillGradient
            when "image" then DrawGlypsFillImage
            else Object
          new fillClass(ctx, block, fill.fillOptions)
        if stroke.enabled
          if strokeWidth > 0
            ctx.strokeText block.glyph, block.fit.x, block.fit.y

        ctx.rect block.fit.x, block.fit.y, block.w, block.h
        ctx.stroke()
      else
        unfit.push block.glyph
    do ctx.restore

    return unfit

  # TODO check when height is greater than width, to is point of maxWidthHeight
  # dynamically changes only width, height for all glyphs is same
  _sortFunction = (a,b)-> b.w - a.w



  recanculateBlocks = (ctx, glyphs = "a", fontFamily = "Sans-serif", fontSize = 10)->
    blocks = []

    #This will insert a hair space (http://www.fileformat.info/info/unicode/char/200a/index.htm) between every letter.
    #Using 8201 (instead of 8202) will insert the slightly wider thin space (http://www.fileformat.info/info/unicode/char/2009/index.htm)
    #For more white space options, see this list of Unicode Spaces (http://www.fileformat.info/info/unicode/category/Zs/list.htm)

    #TODO - set kerning props, and fix with by adding space after and before - and then remove with of that

    do ctx.save
    ctx.font = "#{fontSize}px #{fontFamily}"
    for glyph in glyphs
      # TODO check it for better calculation http://mudcu.be/journal/2011/01/html5-typographic-metrics/#bboxUnicode
      glyphBox =
        glyph: glyph
        h: +fontSize
      glyphBox.w = ctx.measureText(glyph).width
      blocks.push glyphBox
    do ctx.restore
    blocks.sort _sortFunction
    return blocks


  _wrapText = (context, text, x, y, maxWidth, lineHeight) ->
    words = text.split " "
    line = ""
    n = 0

    while n < words.length
      testLine = line + words[n] + " "
      metrics = context.measureText testLine
      testWidth = metrics.width
      if testWidth > maxWidth and n > 0
        context.fillText line, x, y
        line = words[n] + " "
        y += lineHeight
      else
        line = testLine
      n += 1
    context.fillText line, x, y
    return


  _drawUnfitedAlertSign = (ctx)->
    do ctx.save

    ctx.textAlign = "center"
    ctx.font = "#{ctx.canvas.height / 20}px Arial"

    ctx.lineWidth = 5
    ctx.strokeStyle = "#d63301"


    grd = ctx.createRadialGradient 25, ctx.canvas.height / 4 + 30 ,5, 25, ctx.canvas.height / 4 + 30, 100
    grd.addColorStop 0, "#ef824e"
    grd.addColorStop 0.5, "#d8412b"
    grd.addColorStop 1, "#efbbb8"
    ctx.fillStyle = grd

    do ctx.beginPath
    ctx.arc 25, ctx.canvas.height / 4, 20, 0, 2 * Math.PI
    do ctx.stroke
    do ctx.fill
    ctx.fillStyle = "#FFF"
    ctx.fillText "!", 25, ctx.canvas.height / 4 + 10
    do ctx.restore
    return


  drawUnfited = (ctx, unfited)->
    do ctx.save
    ctx.fillStyle = "#ffccba"
    ctx.strokeStyle = "#d63301"

    ctx.fillRect 20, ctx.canvas.height / 4, ctx.canvas.width - 40, ctx.canvas.height / 2
    ctx.strokeRect 20, ctx.canvas.height / 4, ctx.canvas.width - 40, ctx.canvas.height / 2
    ctx.fillStyle = "#FFFFFF"
    ctx.textAlign = "center"
    ctx.font = "#{ctx.canvas.height / 20}px Arial"
    _wrapText ctx, "Not all glyphs fit (#{unfited.join ', '})", ctx.canvas.width / 2, ctx.canvas.width / 4 + 10 + ctx.canvas.height / 20, ctx.canvas.width - 60, ctx.canvas.height / 20
    do ctx.restore
    _drawUnfitedAlertSign ctx
    return

  packBlocks = (blocks, width = 512, height = 512)->

    # TODO refactor to singletone of Packer
    packer = new Packer.Packer width, height
    packer.fit blocks
    return blocks

  restrict: 'A'
  require: '?ngModel'
  scope: {}
  template: "<canvas></canvas>"
  replace: true

  compile: (tElement, tAttrs)->
    canvas = tElement[0]
    ctx = canvas.getContext "2d"
    blocks = []
    #TODO make it dynamically change
    # canvas.width  = 800
    # canvas.height = 800
    ctx.scale(0,0)
    (scope, element, attrs, ngModel)->
      # ngModel.$render = ->
      scope.$watch (scope)->
        return ngModel.$modelValue
      ,(d, oldValue, scope)->
        console.log d
        #TODO add loading phase while image is generating..
        #TODO check what what was changed to not recalculate all each time
        canvas.width = d.canvasWidth
        canvas.height = d.canvasHeight

        if d.retina
          canvas.style.width = "#{d.canvasWidth / 2}px"
          canvas.style.height = "#{d.canvasHeight / 2}px"
        else
          canvas.style.width = "#{d.canvasWidth}px"
          canvas.style.height = "#{d.canvasHeight}px"
        fillOptions = null
        if d.fill
          fillOptions = switch d.fillType
            when "color" then color: d.fillColor
            when "gradient" then "#FFFF00"
            when "image"
              #http://www.w3schools.com/tags/canvas_createpattern.asp
              "#00FFFF"
        else
          fillStyle = "transparent"


        strokeWidth = 0
        if d.stroke
          strokeWidth = d.strokeWidth
          strokeStyle = switch d.strokeType
            when "color" then d.strokeColor
            when "gradient" then "#FFFF00"
            when "image" then "#00FFFF"

        # calcualte glyphs sizes
        # TODO add sizes of stroke / shadow
        # TODO for stroke - add just to width an height stroke width
        blocks = recanculateBlocks ctx, d.glyphs, d.fontFamily, d.fontSize

        #pack block to fit in
        blocks = packBlocks blocks, d.canvasWidth, d.canvasHeight

        clearCanvas ctx

        #TODO reduce argument count / spit to subFunction or pass as few objects
        unfited = drawGlyps ctx,
          blocks, d.fontFamily, d.fontSize,
          {enabled: d.fill, fillType: d.fillType, fillOptions: fillOptions},
          {enabled: d.stroke}
          strokeStyle, strokeWidth, d.strokeType
        if unfited.length
          drawUnfited ctx, unfited

        return true
      ,true
