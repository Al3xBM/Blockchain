'use strict';

var express = require('express');

/*********************General settings***************************/

var app = express();

/*********************Server's IP********************************/ 
var os = require('os');

var interfaces = os.networkInterfaces();
var addresses = [];
for (var k in interfaces) {
    for (var k2 in interfaces[k]) {
        var address = interfaces[k][k2];
        if (address.family === 'IPv4' && !address.internal) {
            addresses.push(address.address);
        }
    }
}

var IP=addresses[0];
var http_port=9000;


/************first action*****************************************/
var path = require("path");
app.use(express.static(path.join(__dirname )));//Now, you can load the files that are in the views directory:

app.get('/',function(req,res){
       
   res.sendFile(path.join(__dirname+'/index.html'));

});

/*********************** Node server *****************************/
app.listen(http_port, function(){
    console.log("-http Server listening on :"+IP+":"+ http_port);
});

/**/ 