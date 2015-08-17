

var appRoot = process.env.APP_ROOT || process.argv[2] || '../';
var filters = (process.env.FILTERS || process.argv[3] || "img/**,fonts/**,*").split(',');

var Mincer = require('mincer'),
    env = new Mincer.Environment(appRoot),
    nib = require('nib'),
    uglifyjs = require('uglify-js'),
    csso = require('csso'),
    fs = require('fs'),
    wrench = require('wrench');

// Remove existing assets
if (fs.existsSync(appRoot + '/public/assets')) {
  wrench.rmdirSyncRecursive(appRoot + '/public/assets');
}

//env.jsCompressor = 'uglify';
//env.cssCompressor = 'csso';
env.appendPath('assets/css');
env.appendPath('assets/js');
env.appendPath('assets');

Mincer.StylusEngine.configure(function(style){
    style.use(nib());
});

console.info(appRoot + 'public/assets');

var manifest = new Mincer.Manifest(env, appRoot + 'public/assets');
manifest.compile(filters, function(err, data) {
    console.error(err);
    console.info('Finished precompile');
    console.dir(data)
});