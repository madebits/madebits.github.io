#!/usr/bin/env node

var vm = require('vm');
var fs = require('fs');
var path = require('path');
var prefix = 'U2FsdGVkX1';

if (typeof String.prototype.startsWith != 'function') {
	String.prototype.startsWith = function (str){
		return this.slice(0, str.length) == str;
	};
}

var readFileText = function(path) {
	var data = fs.readFileSync(path, { encoding: 'utf8' });
	data.replace(/^\uFEFF/, '');
	return data;
};

var loadJs = function(path, ctx) {
	ctx = ctx || {};
	var data = readFileText(path);
	vm.runInNewContext(data, ctx, path);
	return ctx;  
};

var CryptoJS = loadJs(path.join(__dirname, '../scripts/cryptojs/aes.js')).CryptoJS;

var beautify = function(d) {
	if(!d) return '';
	var temp = '', lineLength = 64;
	for(var i = 0; i < d.length; i+= lineLength) {
		temp += d.substr(i, lineLength) + '\n';
	}
	return temp;
};

// http://stackoverflow.com/questions/29432506/how-to-get-digest-representation-of-cryptojs-hmacsha256-in-js
var toInput = function(buffer) {
	if(!buffer) return null;
	var words = [];
	for(var i = 0; i < buffer.length; i++) {
		words[i >>> 2] |= (buffer[i] & 0xff) << (24 - (i % 4) * 8);
	}
	return CryptoJS.lib.WordArray.create(words, buffer.length);
};

var toOutput = function(wordArray) {
	var words = wordArray.words;
    var len = +wordArray.sigBytes;
    var buffer = new Buffer(len);
    for (var i = 0; i < len; i++) {
        var byte = (words[i >>> 2] >>> (24 - (i % 4) * 8)) & 0xff;
        buffer[i]=byte;
    }
    return buffer;
};
	
var encrypt = function (path, outPath, pass) {
	//var data = readFileText(path);
	var data = toInput(fs.readFileSync(path));
	var wa = CryptoJS.AES.encrypt(data, pass);
	var res = wa.toString();
	if(res.startsWith(prefix)) {
		res = res.substr(prefix.length);
	}
	//console.log(beautify(res));
	fs.writeFileSync(outPath, beautify(res));
};

var decrypt = function (path, outPath, pass) {
	var data = readFileText(path);
	data = data.replace(/[\t\s\r\n]/g, '');
	if(!data.startsWith(prefix)) {
		data = prefix + data;
	}
	var decrypted = CryptoJS.AES.decrypt(data, pass);
	//res = decrypted.toString(CryptoJS.enc.Utf8);
	//console.log(res);
	fs.writeFileSync(outPath, toOutput(decrypted));
};

///////////////////////////////////////////

var fileIn = process.argv[2];
var fileOut = process.argv[3];
var pass = process.argv[4];
var d = process.argv[5] && (process.argv[5] == 'd');

if(fileIn && fileOut && pass) {
	if(d) {
		decrypt(fileIn, fileOut, pass);
	}
	else { 
		encrypt(fileIn, fileOut, pass);
	}
}
