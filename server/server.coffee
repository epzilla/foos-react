express = require 'express'
bodyParser = require 'body-parser'
app = express()
morgan = require 'morgan'
path = require 'path'
conf = require './conf/config'
routes = require './routes/api'
server = require('http').createServer(app)

port = process.env.PORT or conf.PORT or 3000
env = conf.ENVIRONMENT or 'dev'

# configure app
app.use morgan('dev')

# configure body parser
app.use bodyParser()
app.engine 'html', require('ejs').renderFile
app.set 'view engine', 'html'
app.use express.static(path.join(__dirname, '../dist'))
app.set 'views', path.join(__dirname, '../dist')
app.all '*', (req, res, next) ->
  res.header("Access-Control-Allow-Origin", "*")
  res.header("Access-Control-Allow-Headers", "X-Requested-With")
  next()

# CONNECT TO DATABASE ====================================
mongoose = require('mongoose')
mongoose.connect conf.DB_ADDRESS

# REGISTER ROUTES ========================================
app.use '/api', routes.router
app.set 'port', port

app.get '/*', (req, res) ->
  console.log 'loading index file'
  if env is 'prod' or env is 'production'
    res.render './index.html'
  else
    res.render '../dist/index.html'
  return

# SET UP SOCKETS AND SEED DATABASE IF EMPTY ==============
io = require('socket.io').listen(server)
routes.init io

server.listen app.get('port'), ->
  console.info 'server listening on port ' + port
  return
