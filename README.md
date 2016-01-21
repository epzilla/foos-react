Foos React
==========

Live site: http://snappy-foos.herokuapp.com

# Installation
### Prerequisites
- NodeJS and npm
- MongoDB
- Bower `npm install -g bower`
- Gulp `npm install -g gulp`

### Steps
- `git clone https://github.com/epzilla/foos-react.git`
- `cd` into the repo
- `npm install`
- `bower install`
- `gulp` to start server (make sure in `/server/conf/config.coffee`, that `ENVIRONMENT` is set to `"dev"`)

### Production Build
- Inside `/server/conf/config.coffee`, change `ENVIRONMENT` to either `"prod"` or `"production"`.
- Run `gulp build`
- After build, everything you need should be in the `/dist` directory, and you can just run `node dist/server.js` to run.

## TODOs
- Improve profile pic uploading
- Make announcer sounds more configurable
- Add more in-depth stats (head-to-head between players/teams in particular)
