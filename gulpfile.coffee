






# http://viget.com/extend/gulp-browserify-starter-faq
#TODO add https://github.com/thlorenz/browserify-shim





#server
connect = require "connect"

##gulp
gulp = require "gulp"
newer = require "gulp-newer"
concat = require "gulp-concat" #change it to

#helper to auto reload page
livereload = require "gulp-livereload"



#TODO move all that to configuration file!! with fallback to default values
BUILD_FOLDER = "public"
LIVERELOAD_PORT = 35729
SERVER_PORT = process.env.npm_package_config_port
BUNDLE_ENTER = './app/initialize.coffee'
RESULT_BUNDLE = "app.js"


###
Start static files server
###

gulp.task "startDevServer", ->
  app = connect()
    #inject to all HTML files liveReload scriptTag
    .use require("connect-livereload") port: LIVERELOAD_PORT
    .use connect.static BUILD_FOLDER #forward all static files
    .use connect.static "node_modules/panda.js" #TODO move me to configuration as serveFolder
  #create HTTP server based and attach connect instance to it
  http = require("http").createServer(app).listen(SERVER_PORT)




source = require "vinyl-source-stream"
streamify = require "gulp-streamify"
browserify = require "browserify"
coffee = require "coffee-script"
through = require "through"
through2 = require "through2"
jade = require "jade"


###

browserify BUILD

###
pp = require "preprocess" ## C++ style build comment variables


###
add support for ngmin https://github.com/btford/ngmin
###

# TODO REREAD !!!https://github.com/robrich/gulp-ignore
gulp.task 'browserify', ->
  bundleStream = browserify entries: BUNDLE_ENTER, extensions: [".js", ".coffee", ".jade"]

  bundleStream.transform (file)->
    data = ""
    if /\.((lit)?coffee|coffee\.md)$/.test file
      write = (buf)->
        data += buf
        return
      end = ->
        data = pp.preprocess data, process.env, "coffee"
        try
          this.queue coffee.compile data
        catch e
          console.log e.toString()
        this.queue null
      return through write, end
    else if /\.jade$/.test(file) # check for static jade..
      write = (buf)->
        data += buf
        return
      end = ->
        #Adding runtime ugly but works
        jade_path = require.resolve('jade');
        path = require "path"
        runtime = path.relative path.dirname(file), path.join(jade_path, '../lib/runtime.js')
        # use js comments style in preprocess to be able use ENV variables in it
        data = pp.preprocess data, process.env, "js"
        this.queue "jade = require('#{runtime}'); module.exports = " + jade.compileClient(data, filename: file).toString()
        this.queue null
      return through write, end
    else
      return do through #TODO add preprocessor to JS files
  bundleStream
    .bundle()
    .pipe source BUNDLE_ENTER
    .pipe streamify concat RESULT_BUNDLE #TODO find better way to rename stream file
    .pipe gulp.dest BUILD_FOLDER



###

STATIC JADE BUILD

###
gulp.task "staticJade", ->
  gulp.src "app/**/*.static.jade"
    .pipe do ->
      through2.obj (file, enc, cb)->
        content = String(file.contents)
        content = pp.preprocess content, process.env, "js"
        file.contents = new Buffer do jade.compile content
        file.path = file.path.replace ".static.jade", '.html'
        this.push file
        do cb
    .pipe gulp.dest BUILD_FOLDER

###
Assets copy
###

rename = require "gulp-rename"

gulp.task "staticCopy", ->
    gulp.src "app/assets/**/*"
      .pipe newer BUILD_FOLDER #change to gulp-change
      .pipe rename (path)->
        path.dirname = path.dirname.replace /^assets/, ""
        console.log "file #{path.dirname}/#{path.basename}#{path.extname} copy to #{BUILD_FOLDER}/#{path.dirname}/#{path.basename}#{path.extname} ..."
      .pipe gulp.dest BUILD_FOLDER


stylus = require('stylus')

gulp.task 'stylus', ->
  gulp.src 'app/**/*.styl'
    .pipe do ->
      through2.obj (file, enc, cb)->
        opts.paths ?= [];
        opts.filename ?= file.path;
        opts.paths ?= opts.paths.concat([path.dirname(file.path)]);
        try
          css = stylus.render(file.contents.toString('utf8'), opts)
          file.contents = new Buffer css
          file.path = file.path.replace ".styl", '.css'
          @push file
        catch e
          console.log do e.toString
        do cb
    .pipe gulp.dest BUILD_FOLDER

###

Lint

###

coffeelint = require 'gulp-coffeelint'

gulp.task 'coffeelint', ->
    gulp.src "app/**/*.coffee"
        .pipe coffeelint "coffeelint.json"
        .pipe do coffeelint.reporter


###

WHATCH TASK

###
gulp.task "watch", ->
  server = livereload()
  gulp.watch("app/**/*.styl", ["stylus"]).on "change", (file)-> server.changed file.path
  gulp.watch("app/**/*.static.jade", ["staticJade"]).on "change", (file)-> server.changed file.path

  gulp.watch(["app/**/*.coffee"],["coffeelint"])
  gulp.watch(["app/**/*.jade", "app/**/*.js", "app/**/*.coffee"], ["browserify"]).on "change", (file)-> server.changed file.path
  gulp.watch(["app/assets/**/*"], ["staticCopy"]).on "change", (file)-> server.changed file.path

gulp.task "default", ["coffeelint", "staticCopy", "stylus", "staticJade", 'browserify', "startDevServer", "watch"]

gulp.task "build", ["coffeelint", "staticCopy", "stylus", "staticJade", 'browserify']