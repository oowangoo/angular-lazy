var express = require("express");
var engine = require('ejs-locals');

var app = express();

// Configuration

app.use(express.static(__dirname + '/app'));
app.use(express.static(__dirname + '/dist'));
app.use(express.static(__dirname + '/vendor'));
app.use(express.static(__dirname + '/views'));


// app.configure(function(){
//   //app.set('view engine', 'jade');

//   app.use(app.router);
// });

app.get('/', function(request, response) {
  response.render('views/index.html')
});

var port = process.env.PORT || 5000;
app.listen(port, function() {
  console.log("Listening on " + port);
});
