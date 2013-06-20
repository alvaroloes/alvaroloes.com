
var appRoot = process.env.APP_ROOT || process.argv[2] || '../';
var filters = (process.env.FILTERS || process.argv[3] || "img/**,*").split(',');

var Mincer = require('connect-mincer/node_modules/mincer'),
    env = new Mincer.Environment(appRoot),
    uglifyjs = require('uglify-js'),
    csso = require('csso'),
    fs = require('fs'),
    wrench = require('wrench');

// Remove existing assets
if (fs.existsSync(appRoot + '/public/assets')) {
  wrench.rmdirSyncRecursive(appRoot + '/public/assets');
}
/**
 * This minifies Javascript using the UglifyJS2 default compression settings.
 */
env.jsCompressor = function(context, data, next) {
  try {
    var min = uglifyjs.minify(data, {
      fromString: true
    });
    next(null, min.code);
  } catch (err) {
    console.err(err);
    next(err);
  }
};

/**
 * This minifies CSS using the Csso default compression options.
 */
env.cssCompressor = function(context, data, next) {
  try {
    next(null, csso.justDoIt(data));
  } catch (err) {
    console.err(err);
    next(err);
  }
};

env.appendPath('assets');
env.appendPath('assets/js');
env.appendPath('assets/css');

var manifest = new Mincer.Manifest(env, appRoot + '/public/assets');
manifest.compile(filters, function(err, data) {
  console.info('Finished precompile');
});