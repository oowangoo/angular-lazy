var express = require("express");
var engine = require('ejs-locals');

var app = express();
// Configuration
app.use(express.static(__dirname + '/.compiled'));


// app.configure(function(){
//   //app.set('view engine', 'jade');

//   app.use(app.router);
// });

app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html')

var port = process.env.PORT || 5000;
app.listen(port, function() {
  console.log("Listening on " + port);
});
