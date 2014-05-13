# $ = require('jquery')(window)
# Backbone = require('backbone')
# Backbone.$ = $

# @ifdef DEBUG
# someDebuggingCall()
# require "./template"
# require "./template"
# require "./template"
# require "./template"
# require "./template"
# require "./template"
# test = require "./test"
# test1 = require "./test1"
# @endif


#http://docs.angularjs.org/tutorial/step_7

###
http://ethanway.com/angular-and-browserify/
###

require "angular/angular"
require "angular-route/angular-route"
require "angular-resource/angular-resource"
require "angular-animate/angular-animate"
require "angular-scrollevents/angular-scrollevents"
require "./widgets/colorpicker"
require "./widgets/fontPainter"
angular = window.angular #TODO need find a way how to fix it




fontBuilderApp = angular.module "fontBuilderApp", ['ngRoute', 'ngAnimate', 'fontLoaderService', 'fontBuilderControllers', 'color-picker', "font-painter", "ngScrollEvent"]


###
MAIN DATA SERVICE TO PROVIDE CROSS ALL CONTROLLERS AND MODULES!
###

fontBuilderApp.factory "Data", ->
  fontSize: 30
  fontFamily: "Sans-serif"
  glyphs: """!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"""

  fill: true #check-box of filling
  fillType: "color" #fill type
  fillColor: "#ca16Fa"

  stroke: false
  strokeType: "color"
  strokeWidth: 3
  strokeColor: "#F00000"

  canvasWidth: 512
  canvasHeight: 512
  retina: window.devicePixelRatio > 1

# angular.module("scroll", []).directive "whenScrolledEnd", ->
#   (scope, elm, attr) ->
#     raw = elm[0]
#     elm.bind "scroll", ->
#       scope.$apply attr.whenScrolledEnd if raw.scrollTop + raw.offsetHeight >= raw.scrollHeight
#       return
#     return



  # # transclude: false,
  # replace: false,
  # link: (scope, element, attr)->

  #   console.log "uraaa"
  #   #   scope.$apply attr.whenScrolledEnd if raw.scrollTop + raw.offsetHeight >= raw.scrollHeight
  #   #   return
  #   # return

fontBuilderApp.config ($routeProvider)->
  $routeProvider
    .when '/',
      templateUrl: 'edit-view.html',
      controller: 'EditView'

    #   # .when '/phones/:phoneId',
    #   #   templateUrl: 'phone-detail.html',
    #   #   controller: 'PhoneDetailCtrl'
    #   .otherwise redirectTo: '/'


fontLoaderService = angular.module 'fontLoaderService', ['ngResource']

fontLoaderService.factory 'Fonts', ($resource)->
  $resource 'data/:fontId.json', {},
    query:
      method: 'GET',
      params:
        fontId: 'fonts'
      # responseType: 'json'
      transformResponse: (data, headersGetter)->
        try
          data = JSON.parse data
        catch e
          console.log error
        data.items
      isArray: true



fontBuilderControllers = angular.module 'fontBuilderControllers', []

# https://egghead.io/lessons/angularjs-sharing-data-between-controllers


JSZip = require "jszip"
saveAs = require "filesaver.js"


fontBuilderControllers.controller 'EditView', ($scope, $document, Fonts, Data)->
  $scope.workData = Data


  $scope.saveAs = ->
    #TODO fix this to something nicer
    canvas = $document.find("canvas")[0]

    zip = new JSZip()
    imgData = canvas.toDataURL()
    console.log imgData
    # zip.file "Hello.txt", "Hello World\n"
    # img = zip.folder "images"
    zip.file "font.png", imgData.replace("data:image/png;base64,",""), {base64: true}

    blob = zip.generate {type:"blob"}
    saveAs blob, "hello.zip"

    return
  $scope.updateOnScrollEvents = ->
    console.log "add dynamic loading of font for preview"

  $scope.itemSelected = (item)->
    WebFont.load
      google:
        families: [item.family]
      active: -> $scope.$apply -> $scope.workData.fontFamily = item.family
    $scope.selectedItem = item

  $scope.fonts = do Fonts.query
  $scope.orderProp = 'family'
  $scope.Math = window.Math

# fontBuilderControllers.controller 'FontEditParams', ($scope, Fonts)->


