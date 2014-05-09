#TESTs
http://www.yearofmoo.com/2013/01/full-spectrum-testing-with-angularjs-and-karma.html
http://karma-runner.github.io/0.8/plus/Travis-CI.html
https://github.com/angular/protractor


#Usage

```
npm install
npm start
```

* converts all `.static.jade` - `.html`
* uses `initialize.coffee` as enter point for [browserify](http://browserify.org/)
  * to use any dependency just install it `npm install backbone --save` via npm and use it like in any node project `Backbone = require "backbone"`
* enabled [preprocessor](https://github.com/jsoverson/preprocess) for jade and coffeescript files (need deep recheck)
* enabled file serve (connfigurable via package.json)
* enabled page auto-reload basen on [tiny-lr](https://github.com/mklabs/tiny-lr) in whatch mode

#TODO:
* add googlefonts api (need to [read](https://developers.google.com/fonts/docs/developer_api))
* add jade-configs to package.json-configs
* ~~add jade-runtime~~ (ugly but works)
* add [stylus](http://learnboost.github.io/stylus/)
* browserify to through2
* ~~enable watch mode with browserify and jade~~
* add `gulp-newer` for watch mode 
* create special build for develop - separate vendor an app files (in production concatinate)
* need to find way how to create different bundles)
* embed jade (`.jade` not `.static.jade`) into browserify
* lintes / tests / logs)




#usefull links


####retangle canculation
http://www.codeproject.com/Articles/210979/Fast-optimizing-rectangle-packing-algorithm-for-bu#basic

####file download

http://stackoverflow.com/questions/2897619/using-html5-javascript-to-generate-and-save-a-file


####savedSession:

https://www.dropbox.com/developers/datastore/tutorial/js

##### disign
http://www.andysowards.com/blog/2012/40-best-web-ui-interface-framework-kits/


####gulp-plugins

https://github.com/jas/gulp-preprocess

https://github.com/hughsk/vinyl-source-stream


http://www.100percentjs.com/just-like-grunt-gulp-browserify-now/

### http://topcoat.io/



