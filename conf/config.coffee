env = 'prod'

if env is 'prod' or env is 'production'
  address = 'http://snappy-foos.herokuapp.com'
  port = 80
else
  address = 'http://localhost'
  port = 3000

module.exports =
  ENVIRONMENT: env
  PORT: port
  API_URL: '/api/'
  LOCAL_STORAGE_PREFIX: 'epzilla'
  ADDRESS: address
  DEV_DB_ADDRESS: 'mongodb://localhost:27017/foos'
  PROD_DB_ADDRESS: 'mongodb://snappycat:synapsefoosball@ds061661.mongolab.com:61661/heroku_app35867326'