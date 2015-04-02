gulp = require "gulp"
gutil = require "gulp-util"
livereload = require "gulp-livereload"
nodemon = require "gulp-nodemon"
plumber = require "gulp-plumber"
gwebpack = require "gulp-webpack"
stylus = require "gulp-stylus"
postcss = require "gulp-postcss"
open = require "gulp-open"
autoprefixer = require "autoprefixer-core"
rimraf = require "rimraf"
srcPath = "src"
usemin = require "gulp-usemin"
uglify = require "gulp-uglify"
componentsPath = "bower_components"
runSequence = require "run-sequence"
modulesPath = "node_modules"
distPath = "dist"

err = (x...) -> gutil.log(x...); gutil.beep(x...)

webpack = (name, ext, watch) ->
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
      modulesDirectories: [componentsPath, modulesPath, srcPath]
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

  gulp.src("#{srcPath}/**/#{name}.#{ext}")
  .pipe(gwebpack(options))
  .pipe(gulp.dest(distPath))


js = (watch) -> webpack("client", "cjsx", watch)
gulp.task "js", -> js(false)

gulp.task "js-dev", -> js(true)

gulp.task "css", ->
  gulp.src("#{srcPath}/styles/styles.styl")
  .pipe(plumber())
  .pipe(stylus())
  .on("error", err)
  .pipe(postcss([autoprefixer(browsers: ["last 2 versions", "ie 8", "ie 9"])]))
  .pipe(gulp.dest("#{distPath}/styles"))

gulp.task "usemin", ->
  gulp.src("#{distPath}/index.html").pipe(usemin(
    js: [
      uglify()
    ])).pipe gulp.dest("#{distPath}")

openFunc = ->
  gulp.src("./dist/index.html").pipe open("",
    url: "http://localhost:3000"
    app: "google chrome")

gulp.task "open", ->
  setTimeout openFunc, 9000

gulp.task "clean", ->
  rimraf.sync(distPath)

gulp.task "copy", ->
  gulp.src("#{srcPath}/*.html").pipe(gulp.dest(distPath))
  gulp.src("#{srcPath}/styles/*.css").pipe(gulp.dest("#{distPath}/styles/"))
  gulp.src("#{srcPath}/images/**").pipe(gulp.dest("#{distPath}/images/"))
  gulp.src("#{srcPath}/favicon.ico").pipe(gulp.dest(distPath))
  gulp.src("#{srcPath}/sounds/**").pipe(gulp.dest("#{distPath}/sounds/"))
  gulp.src("#{componentsPath}/**/*").pipe(gulp.dest("#{distPath}/#{componentsPath}"))

gulp.task "build", ["clean", "copy", "css", "js"]

server_main = "#{srcPath}/server.coffee"
gulp.task "server", ->
  nodemon
    script: server_main
    watch: [server_main]
    nodeArgs: ['--nodejs','--debug']
    env:
      PORT: process.env.PORT or 3000

gulp.task "default", ->
  runSequence("clean", ["copy", "css", "server", "js-dev", "usemin", "watch", "open"])

gulp.task "watch", ["copy"], ->
  livereload.listen()
  gulp.watch(["#{distPath}/**/*"]).on("change", livereload.changed)
  gulp.watch ["#{srcPath}/**/*.styl"], ["css"]
  gulp.watch ["#{srcPath}/**/*.html"], ["copy"]
