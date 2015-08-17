
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Universo de Álvaro López Espinosa' });
};