var express = require("express");
var engine = require('ejs-locals');

var app = express();
// Configuration
app.use(express.static(__dirname + '/dist'));
app.use(express.static(__dirname + '/vendor'));
app.use(express.static(__dirname + '/views'));


// app.configure(function(){
//   //app.set('view engine', 'jade');

//   app.use(app.router);
// });

app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html')

app.get('/', function(request, response,next) {
  response.redirect('/normal')
});
app.get('/normal', function(request, response) {
  response.render('normal.html')
});
app.get('/normal/view1', function(request, response) {
  response.render('normal.html')
});
app.get('/normal/view2', function(request, response) {
  response.render('normal.html')
});

app.get('/requireJS', function(request, response) {
  response.render('require.html')
});
app.get('/requireJS/view1', function(request, response) {
  response.render('require.html')
});
app.get('/requireJS/view2', function(request, response) {
  response.render('require.html')
});

var port = process.env.PORT || 5000;
app.listen(port, function() {
  console.log("Listening on " + port);
});
