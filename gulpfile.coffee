gulp = require "gulp"
gutil = require "gulp-util"
livereload = require "gulp-livereload"
nodemon = require "gulp-nodemon"
plumber = require "gulp-plumber"
gwebpack = require "gulp-webpack"
stylus = require "gulp-stylus"
postcss = require "gulp-postcss"
open = require "gulp-open"
run = require "gulp-run"
autoprefixer = require "autoprefixer-core"
del = require "del"
clientPath = "client"
serverPath = "server"
usemin = require "gulp-usemin"
uglify = require "gulp-uglify"
componentsPath = "bower_components"
nodeModules = "node_modules"
runSequence = require "run-sequence"
modulesPath = "node_modules"
tmpPath = ".tmp"
buildPath = "build"
coffee = require "gulp-coffee"

err = (x...) -> gutil.log(x...); gutil.beep(x...)

webpack = (name, ext, watch, destPath) ->
  options =
#    bail: true
    watch: watch
    cache: true
    devtool: "source-map"
    output:
      filename: "#{name}.js"
      sourceMapFilename: "[file].map"
    resolve:
      extensions: ["", ".webpack.js", ".web.js", ".js", ".jsx", ".coffee", ".cjsx"]
      modulesDirectories: [componentsPath, modulesPath, clientPath]
    module:
      loaders: [
        {
          test: /\.coffee$/
          loader: "coffee-loader"
        }
        {
          test: /\.cjsx$/
          loader: "transform?coffee-reactify"
        }
        {
          test: /\.jsx$/
          loader: "transform?reactify"
        }
      ]

  gulp.src("#{clientPath}/**/#{name}.#{ext}")
  .pipe(gwebpack(options))
  .pipe(gulp.dest(destPath))


js = (watch, destPath) -> webpack("client", "cjsx", watch, destPath)
gulp.task "js", -> js(false, buildPath)

gulp.task "js-dev", -> js(true, tmpPath)

gulp.task "css", ->
  gulp.src("#{clientPath}/styles/styles.styl")
  .pipe(plumber())
  .pipe(stylus())
  .on("error", err)
  .pipe(postcss([autoprefixer(browsers: ["last 2 versions", "ie 8", "ie 9"])]))
  .pipe(gulp.dest("#{tmpPath}/styles"))

gulp.task "css-build", ->
  gulp.src("#{clientPath}/styles/styles.styl")
  .pipe(plumber())
  .pipe(stylus())
  .on("error", err)
  .pipe(postcss([autoprefixer(browsers: ["last 2 versions", "ie 8", "ie 9"])]))
  .pipe(gulp.dest("#{buildPath}/styles"))

gulp.task "usemin", ->
  gulp.src("#{tmpPath}/index.html").pipe(usemin(
    js: [
      uglify()
    ])).pipe gulp.dest("#{tmpPath}")

openFunc = ->
  gulp.src("./dist/index.html").pipe open("",
    url: "http://localhost:3000"
    app: "google chrome")

gulp.task "open", ->
  setTimeout openFunc, 9000

gulp.task "clean", ->
  del.sync [
    "#{tmpPath}/**/*"
    "!#{tmpPath}/.git/**"
  ]

gulp.task "clean-build", ->
  del.sync [
    "#{buildPath}/**/*"
    "!#{buildPath}/**/.git/**"
  ]

gulp.task "server-js", ->
  gulp.src("#{serverPath}/**/*.coffee")
    .pipe(coffee())
    .pipe(gulp.dest("#{tmpPath}"))
  gulp.src("server.coffee")
    .pipe(coffee())
    .pipe(gulp.dest(tmpPath))
  gulp.src("conf/**/*.coffee")
    .pipe(coffee())
    .pipe(gulp.dest("#{tmpPath}/conf"))

gulp.task "server-js-build", ->
  gulp.src("#{serverPath}/**/*.coffee")
    .pipe(coffee())
    .pipe(gulp.dest("#{buildPath}/"))
  gulp.src("server.coffee")
    .pipe(coffee())
    .pipe(gulp.dest(buildPath))
  gulp.src("conf/**/*.coffee")
    .pipe(coffee())
    .pipe(gulp.dest("#{buildPath}/conf"))

gulp.task "copy", ->
  gulp.src(["#{serverPath}/**/*", "!#{serverPath}/**/*.coffee"]).pipe(gulp.dest("#{tmpPath}/"))
  gulp.src("#{clientPath}/*.html").pipe(gulp.dest(tmpPath))
  gulp.src("#{clientPath}/styles/*.css").pipe(gulp.dest("#{tmpPath}/styles/"))
  gulp.src("#{clientPath}/images/**").pipe(gulp.dest("#{tmpPath}/images/"))
  gulp.src("#{clientPath}/favicon.ico").pipe(gulp.dest(tmpPath))
  gulp.src("#{clientPath}/sounds/**").pipe(gulp.dest("#{tmpPath}/sounds/"))
  gulp.src(["package.json", "bower.json"]).pipe(gulp.dest("#{tmpPath}"))
  gulp.src("templates/**").pipe(gulp.dest("#{tmpPath}/templates/"))
  gulp.src(["conf/**", "!conf/**/*.coffee"]).pipe(gulp.dest("#{tmpPath}/conf/"))
  gulp.src("#{componentsPath}/**/*").pipe(gulp.dest("#{tmpPath}/#{componentsPath}"))

gulp.task "copy-build", ->
  gulp.src(["#{serverPath}/**/*", "!#{serverPath}/**/*.coffee"]).pipe(gulp.dest("#{buildPath}/"))
  gulp.src("#{clientPath}/*.html").pipe(gulp.dest(buildPath))
  gulp.src("#{clientPath}/styles/*.css").pipe(gulp.dest("#{buildPath}/styles/"))
  gulp.src("#{clientPath}/images/**").pipe(gulp.dest("#{buildPath}/images/"))
  gulp.src("#{clientPath}/favicon.ico").pipe(gulp.dest(buildPath))
  gulp.src("#{clientPath}/sounds/**").pipe(gulp.dest("#{buildPath}/sounds/"))
  gulp.src(["package.json", "bower.json"]).pipe(gulp.dest("#{buildPath}"))
  gulp.src("templates/**").pipe(gulp.dest("#{buildPath}/templates/"))
  gulp.src(["conf/**", "!conf/**/*.coffee"]).pipe(gulp.dest("#{buildPath}/conf/"))
  gulp.src("#{componentsPath}/**/*").pipe(gulp.dest("#{buildPath}/#{componentsPath}"))

gulp.task "no-livereload", ->
  run('sed -i".bak" "/livereload/d" build/index.html').exec()
  run('rm build/index.html.bak').exec()

gulp.task "build", ->
  runSequence("clean-build", "server-js-build", ["copy-build", "css-build", "js"], "no-livereload")

server_main = "#{tmpPath}/server.js"
gulp.task "server", ["server-js", "copy", "css"], ->
  setTimeout(->
    nodemon
      script: server_main
      watch: [server_main, "#{serverPath}/**/*"]
      nodeArgs: ['--debug']
      env:
        PORT: process.env.PORT or 3000
  , 5000)

gulp.task "default", ->
  runSequence("clean", ["server-js", "copy", "css"], "server", "watch", "js-dev", "usemin", "open")

gulp.task "watch", ->
  livereload.listen()
  gulp.watch(["#{tmpPath}/**/*"]).on("change", livereload.changed)
  gulp.watch ["#{clientPath}/**/*.styl"], ["css"]
  gulp.watch ["#{clientPath}/**/*.html"], ["copy"]
