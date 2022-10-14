const express = require('express');
const app = express();
var walletsdk = require('./walletSdk.js');

var gapSdk = require('./gapSdk');
var assetsdk = require('./assetSdk.js');

var receiptsdk = require('./receiptSdk.js');
var path = require('path');

require('./Controller.js')(app);

var port = process.env.PORT || 8080;
var HOST = 'localhost';

app.listen(port,function(){
  console.log(`Live on port: http://${HOST}:${port}`);
});