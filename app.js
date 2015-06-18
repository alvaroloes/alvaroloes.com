
/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , path = require('path')
  , Mincer = require('mincer')
  , ConnectMincer = require('connect-mincer')
  , nib = require('nib')
  , i18next = require('i18next');

global.APP_ROOT = __dirname;

var app = express();

// all environments

app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(express.cookieParser('your secret here'));
app.use(express.session());


var connectMincer = new ConnectMincer({
  root: __dirname,
  mincer: Mincer,
  production: app.get('env') === 'production',
  manifestFile: __dirname + '/public/assets/manifest.json',
  paths: [
    'assets/css',
    'assets/js',
    'assets'
  ]
});

//Use nib library in stylus and other custom functions
connectMincer.Mincer.StylusEngine.configure(function(style){
  style.use(nib());
//  style.use(require('./modules/stylus-extensions').functions);
});

app.use(connectMincer.assets());

if( 'production' != app.get('env')){
    app.use('/assets', connectMincer.createServer());
    app.use(express.errorHandler());
}

app.use(express.static(path.join(__dirname, 'public'),{maxAge: 36000000}));
app.use(app.router);

//To serve the clientside script and needed routes for resources and missing keys:
i18next.serveClientScript(app)
      .serveDynamicResources(app)
      .serveMissingKeyRoute(app);

app.get('/*', routes.index);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

