# https://github.com/buberdds/angular-bootstrap-colorpicker/blob/master/js/bootstrap-colorpicker-module.js
#https://developer.mozilla.org/en-US/docs/Web/CSS/Tools/ColorPicker_Tool

picker = angular.module("color-picker", [])

picker.factory "Helper", ->
  closestSlider: (elem) ->
    matchesSelector = elem.matches or elem.webkitMatchesSelector or elem.mozMatchesSelector or elem.msMatchesSelector
    return elem.parentNode if matchesSelector.bind(elem)("I")
    elem

  getOffset: (elem) ->
    x = 0
    y = 0
    scrollX = 0
    scrollY = 0
    while elem and not isNaN(elem.offsetLeft) and not isNaN(elem.offsetTop)
      x += elem.offsetLeft
      y += elem.offsetTop
      scrollX += elem.scrollLeft
      scrollY += elem.scrollTop
      elem = elem.offsetParent
    top: y
    left: x
    scrollX: scrollX
    scrollY: scrollY


  # a set of RE's that can match strings and generate color tuples. https://github.com/jquery/jquery-color/
  stringParsers: [
    {
      re: /rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/
      parse: (execResult) ->
        [
          execResult[1]
          execResult[2]
          execResult[3]
          execResult[4]
        ]
    }
    {
      re: /rgba?\(\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*,\s*(\d+(?:\.\d+)?)\%\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)/
      parse: (execResult) ->
        [
          2.55 * execResult[1]
          2.55 * execResult[2]
          2.55 * execResult[3]
          execResult[4]
        ]
    }
    {
      re: /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/
      parse: (execResult) ->
        [
          parseInt(execResult[1], 16)
          parseInt(execResult[2], 16)
          parseInt(execResult[3], 16)
        ]
    }
    {
      re: /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/
      parse: (execResult) ->
        [
          parseInt(execResult[1] + execResult[1], 16)
          parseInt(execResult[2] + execResult[2], 16)
          parseInt(execResult[3] + execResult[3], 16)
        ]
    }
  ]
picker.factory "Slider", [
  "Helper"
  (Helper) ->
    slider =
      maxLeft: 0
      maxTop: 0
      callLeft: null
      callTop: null
      knob:
        top: 0
        left: 0

    pointer = {}
    return (
      getSlider: ->
        slider

      getLeftPosition: (event) ->
        Math.max 0, Math.min(slider.maxLeft, slider.left + ((event.pageX or pointer.left) - pointer.left))

      getTopPosition: (event) ->
        Math.max 0, Math.min(slider.maxTop, slider.top + ((event.pageY or pointer.top) - pointer.top))

      setSlider: (event) ->
        target = Helper.closestSlider(event.target)
        targetOffset = Helper.getOffset(target)
        slider.knob = target.children[0].style
        slider.left = event.pageX - targetOffset.left - window.pageXOffset + targetOffset.scrollX
        slider.top = event.pageY - targetOffset.top - window.pageYOffset + targetOffset.scrollY
        pointer =
          left: event.pageX
          top: event.pageY
        return

      setSaturation: (event, cb) ->
        slider =
          maxLeft: 100
          maxTop: 100
          callLeft: cb.left
          callTop: cb.top
        @setSlider event
        return

      setHue: (event, cb) ->
        slider =
          maxLeft: 0
          maxTop: 100
          callLeft: false
          callTop: cb.top

        @setSlider event
        return

      setAlpha: (event) ->
        slider =
          maxLeft: 0
          maxTop: 100
          callLeft: false
          callTop: "setAlpha"

        @setSlider event
        return

      setKnob: (top, left) ->
        slider.knob.top = top + "px"
        slider.knob.left = left + "px"
        return
    )
]

picker.directive "gradientPicker", ($document, $timeout, Helper, Slider)->

picker.directive "colorPicker", ["$document", "$timeout", "Helper", "Slider", ($document, $timeout, Helper, Slider)->

  HSVtoRGB = (h, s, v) ->
    i = Math.floor(h * 6)
    f = h * 6 - i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)
    switch i % 6
      when 0 then r = v; g = t; b = p
      when 1 then r = q; g = v; b = p
      when 2 then r = p; g = v; b = t
      when 3 then r = p; g = q; b = v
      when 4 then r = t; g = p; b = v
      when 5 then r = v; g = p; b = q
    R = ("0" + Math.floor(r * 255).toString(16)).substr -2
    G = ("0" + Math.floor(g * 255).toString(16)).substr -2
    B = ("0" + Math.floor(b * 255).toString(16)).substr -2
    """
    ##{R}#{G}#{B}
    """

  RGBtoHSV = (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255
    max = Math.max(r, g, b)
    min = Math.min(r, g, b)
    h = undefined
    s = undefined
    v = max
    d = max - min
    s = (if max is 0 then 0 else d / max)
    if max is min
      h = 0 # achromatic
    else
      switch max
        when r
          h = (g - b) / d + ((if g < b then 6 else 0))
        when g
          h = (b - r) / d + 2
        when b
          h = (r - g) / d + 4
      h /= 6
    h: h, s: s, v: v

  HEXtoRGB = (hex)-> ['0x' + hex[1] + hex[2] | 0, '0x' + hex[3] + hex[4] | 0, '0x' + hex[5] + hex[6] | 0]


  bindMouseEvents = ->
    $document.on('mousemove', mousemove)
    $document.on('mouseup', mouseup)

  mouseup = ->
    $document.off('mousemove', mousemove)
    $document.off('mouseup', mouseup)

  mousemove = (event) ->
    left = Slider.getLeftPosition(event)
    top = Slider.getTopPosition(event)
    slider = Slider.getSlider()
    Slider.setKnob top, left
    slider.callLeft left if slider.callLeft
    slider.callTop top if slider.callTop
    # if slider.callTop is "setHue"
    #   H = 1 - top / 100
    #   sliderSaturation.css "background-color": HSVtoRGB H, 1, 1
    # else
    #   V = 1 - top / 100
    # S = left / 100 if slider.callLeft
    # applyChnages HSVtoRGB H, S, V

    false
  return {
    restrict: 'A'
    require: '?ngModel'
    scope: {ngModel: "="}
    replace: true
    priority: -100
    template:
      """
      <div class="colorPicker">
          <input type="text" readonly="true" ng-style="{background:ngModel}" ng-model="ngModel" ng-click="open = !open" />
          <div style="position:absolute" ng-show="open">
              <colorpicker-saturation><i></i></colorpicker-saturation>
              <colorpicker-hue><i></i></colorpicker-hue>
          </div>
      </div>
      """
    link: (scope, elem, attrs, ngModel)->

        sliderHue = elem.find "colorpicker-hue"
        sliderSaturation = elem.find('colorpicker-saturation')


        H = 1
        S = 0
        V = 1

        insideUpdate = false
        scope.$watch "ngModel", ->
          if ngModel.$modelValue
            if not insideUpdate
              {h: H, v: V, s: S} =  RGBtoHSV.apply null, HEXtoRGB ngModel.$modelValue
              sliderHue.find("i").css "top": "#{100 - H * 100}px"
              sliderSaturation.find("i").css "top": "#{100 - V * 100}px", "left": "#{S * 100}px"
            sliderSaturation.css "background-color": HSVtoRGB H, 1, 1
            insideUpdate = false


        sliderHueTop = (top)->
          H = 1 - top / 100
          insideUpdate = true
          scope.$apply -> scope.ngModel = HSVtoRGB H, S, V


        sliderSaturationTop = (top)->
          V = 1 - top / 100
          insideUpdate = true
          scope.$apply -> scope.ngModel = HSVtoRGB H, S, V

        sliderSaturationLeft = (left)->
          S = left / 100
          insideUpdate = true
          scope.$apply -> scope.ngModel = HSVtoRGB H, S, V



        sliderHue
          .on 'click', (event)->
            Slider.setHue event, top: sliderHueTop
            mousemove(event)
          .on 'mousedown', (event)->
            Slider.setHue event, top: sliderHueTop
            bindMouseEvents()

        sliderSaturation
          .on 'click', (event)->
            Slider.setSaturation event, top: sliderSaturationTop, left: sliderSaturationLeft
            mousemove(event)
          .on 'mousedown', (event)->
            Slider.setSaturation event, top: sliderSaturationTop, left: sliderSaturationLeft
            bindMouseEvents()

        sliderSaturation.css "background-color": "#f00"
        # scope.$apply -> scope.model = color;
  }
]